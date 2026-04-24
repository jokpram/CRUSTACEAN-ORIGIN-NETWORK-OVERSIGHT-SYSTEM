package services
import (
	"errors"
	"fmt"
	"time"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type ShipmentService struct {
	ShipmentRepo *repositories.ShipmentRepository
	OrderRepo    *repositories.OrderRepository
	Ledger       *blockchain.Ledger
}
func NewShipmentService(shipmentRepo *repositories.ShipmentRepository, orderRepo *repositories.OrderRepository, ledger *blockchain.Ledger) *ShipmentService {
	return &ShipmentService{ShipmentRepo: shipmentRepo, OrderRepo: orderRepo, Ledger: ledger}
}
type CreateShipmentRequest struct {
	OrderID           uuid.UUID  `json:"order_id" validate:"required"`
	CourierID         uuid.UUID  `json:"courier_id" validate:"required"`
	TrackingNumber    string     `json:"tracking_number"`
	EstimatedDelivery *time.Time `json:"estimated_delivery"`
}
func (s *ShipmentService) CreateShipment(req CreateShipmentRequest) (*models.Shipment, error) {
	order, err := s.OrderRepo.FindByID(req.OrderID)
	if err != nil {
		return nil, errors.New("order not found")
	}
	if order.Status != "paid" && order.Status != "processing" && order.Status != "pending" {
		return nil, errors.New("order must be paid or pending before shipping")
	}
	shipment := &models.Shipment{
		OrderID:           req.OrderID,
		CourierID:         &req.CourierID,
		TrackingNumber:    req.TrackingNumber,
		Status:            "pending",
		EstimatedDelivery: req.EstimatedDelivery,
	}
	if err := s.ShipmentRepo.Create(shipment); err != nil {
		return nil, errors.New("failed to create shipment")
	}
	order.Status = "processing"
	s.OrderRepo.Update(order)
	return s.ShipmentRepo.FindByID(shipment.ID)
}
func (s *ShipmentService) UpdateShipmentStatus(courierID, shipmentID uuid.UUID, status, location, notes string) (*models.Shipment, error) {
	shipment, err := s.ShipmentRepo.FindByID(shipmentID)
	if err != nil {
		return nil, errors.New("shipment not found")
	}
	if shipment.CourierID == nil || *shipment.CourierID != courierID {
		return nil, errors.New("unauthorized")
	}
	validTransitions := map[string][]string{
		"pending": {"pickup"},
		"pickup":  {"transit"},
		"transit": {"delivered"},
	}
	allowed, ok := validTransitions[shipment.Status]
	if !ok {
		return nil, errors.New("shipment already in final state")
	}
	valid := false
	for _, s := range allowed {
		if s == status {
			valid = true
			break
		}
	}
	if !valid {
		return nil, fmt.Errorf("invalid status transition from %s to %s", shipment.Status, status)
	}
	shipment.Status = status
	switch status {
	case "delivered":
		now := time.Now()
		shipment.ActualDelivery = &now
		order, _ := s.OrderRepo.FindByID(shipment.OrderID)
		order.Status = "delivered"
		s.OrderRepo.Update(order)
	case "pickup":
		order, _ := s.OrderRepo.FindByID(shipment.OrderID)
		order.Status = "shipped"
		s.OrderRepo.Update(order)
	}
	s.ShipmentRepo.Update(shipment)
	log := &models.ShipmentLog{
		ShipmentID: shipmentID,
		Status:     status,
		Location:   location,
		Notes:      notes,
		Timestamp:  time.Now(),
	}
	s.ShipmentRepo.CreateLog(log)
	eventType := "shipment_" + status
	s.Ledger.RecordEvent(eventType, courierID, "shipment", shipment.OrderID, map[string]interface{}{
		"status":   status,
		"location": location,
	})
	return s.ShipmentRepo.FindByID(shipmentID)
}
func (s *ShipmentService) GetMyShipments(courierID uuid.UUID) ([]models.Shipment, error) {
	return s.ShipmentRepo.FindByCourierID(courierID)
}
func (s *ShipmentService) GetShipment(id uuid.UUID) (*models.Shipment, error) {
	return s.ShipmentRepo.FindByID(id)
}
func (s *ShipmentService) GetShipmentLogs(shipmentID uuid.UUID) ([]models.ShipmentLog, error) {
	return s.ShipmentRepo.FindLogsByShipmentID(shipmentID)
}
func (s *ShipmentService) GetAllShipments() ([]models.Shipment, error) {
	return s.ShipmentRepo.FindAll()
}
