package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type OrderRepository struct {
	DB *gorm.DB
}
func NewOrderRepository(db *gorm.DB) *OrderRepository {
	return &OrderRepository{DB: db}
}
func (r *OrderRepository) Create(order *models.Order) error {
	return r.DB.Create(order).Error
}
func (r *OrderRepository) CreateOrderItem(item *models.OrderItem) error {
	return r.DB.Create(item).Error
}
func (r *OrderRepository) FindByUserID(userID uuid.UUID, page, limit int) ([]models.Order, int64, error) {
	var orders []models.Order
	var total int64
	query := r.DB.Model(&models.Order{}).Where("user_id = ?", userID)
	query.Count(&total)
	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").
		Preload("OrderItems").Preload("OrderItems.Product").Preload("OrderItems.Product.Images").
		Preload("Payment").Preload("Shipment").
		Find(&orders).Error
	return orders, total, err
}
func (r *OrderRepository) FindAll(page, limit int, status string) ([]models.Order, int64, error) {
	var orders []models.Order
	var total int64
	query := r.DB.Model(&models.Order{})
	if status != "" {
		query = query.Where("status = ?", status)
	}
	query.Count(&total)
	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").
		Preload("User").Preload("OrderItems").Preload("OrderItems.Product").
		Preload("Payment").Preload("Shipment").
		Find(&orders).Error
	return orders, total, err
}
func (r *OrderRepository) FindByID(id uuid.UUID) (*models.Order, error) {
	var order models.Order
	err := r.DB.Preload("User").Preload("OrderItems").Preload("OrderItems.Product").Preload("OrderItems.Product.Images").
		Preload("Payment").Preload("Payment.MidtransTransaction").
		Preload("Shipment").Preload("Shipment.ShipmentLogs").Preload("Shipment.Courier").
		First(&order, id).Error
	return &order, err
}
func (r *OrderRepository) Update(order *models.Order) error {
	return r.DB.Save(order).Error
}
func (r *OrderRepository) FindBySellerID(sellerID uuid.UUID) ([]models.Order, error) {
	var orders []models.Order
	err := r.DB.Joins("JOIN order_items ON order_items.order_id = orders.id").
		Joins("JOIN products ON products.id = order_items.product_id").
		Where("products.user_id = ?", sellerID).
		Preload("User").Preload("OrderItems").Preload("OrderItems.Product").
		Preload("Payment").Preload("Shipment").
		Group("orders.id").
		Order("orders.created_at DESC").Find(&orders).Error
	return orders, err
}
func (r *OrderRepository) CountByStatus() (map[string]int64, error) {
	type StatusCount struct {
		Status string
		Count  int64
	}
	var results []StatusCount
	err := r.DB.Model(&models.Order{}).Select("status, count(*) as count").Group("status").Find(&results).Error
	if err != nil {
		return nil, err
	}
	counts := make(map[string]int64)
	for _, rc := range results {
		counts[rc.Status] = rc.Count
	}
	return counts, nil
}
func (r *OrderRepository) SumTotalRevenue() (float64, error) {
	var total float64
	err := r.DB.Model(&models.Order{}).Where("status IN ?", []string{"paid", "processing", "shipped", "delivered", "completed"}).
		Select("COALESCE(SUM(total_amount), 0)").Scan(&total).Error
	return total, err
}
func (r *OrderRepository) SumRevenueBySellerID(sellerID uuid.UUID) (float64, error) {
	var total float64
	err := r.DB.Model(&models.OrderItem{}).
		Joins("JOIN products ON products.id = order_items.product_id").
		Joins("JOIN orders ON orders.id = order_items.order_id").
		Where("products.user_id = ? AND orders.status IN ?", sellerID, []string{"paid", "processing", "shipped", "delivered", "completed"}).
		Select("COALESCE(SUM(order_items.subtotal), 0)").Scan(&total).Error
	return total, err
}
