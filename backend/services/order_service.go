package services
import (
	"errors"
	"math"
	"strconv"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"cronos-backend/utils"
	"github.com/google/uuid"
)
type OrderService struct {
	OrderRepo   *repositories.OrderRepository
	ProductRepo *repositories.ProductRepository
	Ledger      *blockchain.Ledger
}
func NewOrderService(orderRepo *repositories.OrderRepository, productRepo *repositories.ProductRepository, ledger *blockchain.Ledger) *OrderService {
	return &OrderService{OrderRepo: orderRepo, ProductRepo: productRepo, Ledger: ledger}
}
type CreateOrderRequest struct {
	ShippingAddress string `json:"shipping_address" validate:"required"`
	Notes           string `json:"notes"`
	Items           []struct {
		ProductID uuid.UUID `json:"product_id" validate:"required"`
		Quantity  int       `json:"quantity" validate:"required,gt=0"`
	} `json:"items" validate:"required,min=1"`
}
func (s *OrderService) CreateOrder(userID uuid.UUID, req CreateOrderRequest) (*models.Order, error) {
	order := &models.Order{
		UserID:          userID,
		ShippingAddress: req.ShippingAddress,
		Notes:           req.Notes,
		Status:          "pending",
	}
	var totalAmount float64
	var orderItems []models.OrderItem
	for _, item := range req.Items {
		product, err := s.ProductRepo.FindByID(item.ProductID)
		if err != nil {
			return nil, errors.New("product not found: " + item.ProductID.String())
		}
		if product.Stock < item.Quantity {
			return nil, errors.New("insufficient stock for product: " + product.Name)
		}
		subtotal := product.Price * float64(item.Quantity)
		totalAmount += subtotal
		orderItems = append(orderItems, models.OrderItem{
			ProductID: item.ProductID,
			Quantity:  item.Quantity,
			Price:     product.Price,
			Subtotal:  subtotal,
		})
	}
	order.TotalAmount = totalAmount
	if err := s.OrderRepo.Create(order); err != nil {
		return nil, errors.New("failed to create order")
	}
	for i := range orderItems {
		orderItems[i].OrderID = order.ID
		if err := s.OrderRepo.CreateOrderItem(&orderItems[i]); err != nil {
			return nil, errors.New("failed to create order item")
		}
		product, _ := s.ProductRepo.FindByID(orderItems[i].ProductID)
		product.Stock -= orderItems[i].Quantity
		s.ProductRepo.Update(product)
	}
	s.Ledger.RecordEvent("order_created", userID, "order", order.ID, map[string]interface{}{
		"total_amount": totalAmount,
		"items_count":  len(orderItems),
	})
	return s.OrderRepo.FindByID(order.ID)
}
func (s *OrderService) GetMyOrders(userID uuid.UUID, pageStr, limitStr string) ([]models.Order, *utils.PaginationMeta, error) {
	page, _ := strconv.Atoi(pageStr)
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(limitStr)
	if limit < 1 {
		limit = 10
	}
	orders, total, err := s.OrderRepo.FindByUserID(userID, page, limit)
	if err != nil {
		return nil, nil, err
	}
	meta := &utils.PaginationMeta{
		CurrentPage: page,
		PerPage:     limit,
		Total:       total,
		TotalPages:  int(math.Ceil(float64(total) / float64(limit))),
	}
	return orders, meta, nil
}
func (s *OrderService) GetAllOrders(pageStr, limitStr, status string) ([]models.Order, *utils.PaginationMeta, error) {
	page, _ := strconv.Atoi(pageStr)
	if page < 1 {
		page = 1
	}
	limit, _ := strconv.Atoi(limitStr)
	if limit < 1 {
		limit = 10
	}
	orders, total, err := s.OrderRepo.FindAll(page, limit, status)
	if err != nil {
		return nil, nil, err
	}
	meta := &utils.PaginationMeta{
		CurrentPage: page,
		PerPage:     limit,
		Total:       total,
		TotalPages:  int(math.Ceil(float64(total) / float64(limit))),
	}
	return orders, meta, nil
}
func (s *OrderService) GetOrder(id uuid.UUID) (*models.Order, error) {
	return s.OrderRepo.FindByID(id)
}
func (s *OrderService) CancelOrder(userID, orderID uuid.UUID) error {
	order, err := s.OrderRepo.FindByID(orderID)
	if err != nil {
		return errors.New("order not found")
	}
	if order.UserID != userID {
		return errors.New("unauthorized")
	}
	if order.Status != "pending" {
		return errors.New("only pending orders can be cancelled")
	}
	order.Status = "cancelled"
	for _, item := range order.OrderItems {
		product, _ := s.ProductRepo.FindByID(item.ProductID)
		product.Stock += item.Quantity
		s.ProductRepo.Update(product)
	}
	return s.OrderRepo.Update(order)
}
func (s *OrderService) GetSellerOrders(sellerID uuid.UUID) ([]models.Order, error) {
	return s.OrderRepo.FindBySellerID(sellerID)
}
