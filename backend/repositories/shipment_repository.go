package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type ShipmentRepository struct {
	DB *gorm.DB
}
func NewShipmentRepository(db *gorm.DB) *ShipmentRepository {
	return &ShipmentRepository{DB: db}
}
func (r *ShipmentRepository) Create(shipment *models.Shipment) error {
	return r.DB.Create(shipment).Error
}
func (r *ShipmentRepository) FindByOrderID(orderID uuid.UUID) (*models.Shipment, error) {
	var shipment models.Shipment
	err := r.DB.Where("order_id = ?", orderID).Preload("Courier").Preload("ShipmentLogs").First(&shipment).Error
	return &shipment, err
}
func (r *ShipmentRepository) FindByCourierID(courierID uuid.UUID) ([]models.Shipment, error) {
	var shipments []models.Shipment
	err := r.DB.Where("courier_id = ?", courierID).
		Preload("Order").Preload("Order.User").Preload("Order.OrderItems").Preload("Order.OrderItems.Product").
		Preload("ShipmentLogs").
		Order("created_at DESC").Find(&shipments).Error
	return shipments, err
}
func (r *ShipmentRepository) FindByID(id uuid.UUID) (*models.Shipment, error) {
	var shipment models.Shipment
	err := r.DB.Preload("Order").Preload("Order.User").Preload("Order.OrderItems").
		Preload("Courier").Preload("ShipmentLogs").First(&shipment, id).Error
	return &shipment, err
}
func (r *ShipmentRepository) Update(shipment *models.Shipment) error {
	return r.DB.Save(shipment).Error
}
func (r *ShipmentRepository) CreateLog(log *models.ShipmentLog) error {
	return r.DB.Create(log).Error
}
func (r *ShipmentRepository) FindLogsByShipmentID(shipmentID uuid.UUID) ([]models.ShipmentLog, error) {
	var logs []models.ShipmentLog
	err := r.DB.Where("shipment_id = ?", shipmentID).Order("timestamp DESC").Find(&logs).Error
	return logs, err
}
func (r *ShipmentRepository) FindAll() ([]models.Shipment, error) {
	var shipments []models.Shipment
	err := r.DB.Preload("Order").Preload("Order.User").Preload("Courier").Preload("ShipmentLogs").
		Order("created_at DESC").Find(&shipments).Error
	return shipments, err
}
func (r *ShipmentRepository) CountByCourierID(courierID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Shipment{}).Where("courier_id = ?", courierID).Count(&count).Error
	return count, err
}
func (r *ShipmentRepository) CountByStatus(courierID uuid.UUID) (map[string]int64, error) {
	type StatusCount struct {
		Status string
		Count  int64
	}
	var results []StatusCount
	query := r.DB.Model(&models.Shipment{})
	if courierID != uuid.Nil {
		query = query.Where("courier_id = ?", courierID)
	}
	err := query.Select("status, count(*) as count").Group("status").Find(&results).Error
	if err != nil {
		return nil, err
	}
	counts := make(map[string]int64)
	for _, rc := range results {
		counts[rc.Status] = rc.Count
	}
	return counts, nil
}
