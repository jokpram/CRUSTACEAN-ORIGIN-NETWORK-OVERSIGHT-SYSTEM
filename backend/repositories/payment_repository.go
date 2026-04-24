package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type PaymentRepository struct {
	DB *gorm.DB
}
func NewPaymentRepository(db *gorm.DB) *PaymentRepository {
	return &PaymentRepository{DB: db}
}
func (r *PaymentRepository) Create(payment *models.Payment) error {
	return r.DB.Create(payment).Error
}
func (r *PaymentRepository) FindByOrderID(orderID uuid.UUID) (*models.Payment, error) {
	var payment models.Payment
	err := r.DB.Where("order_id = ?", orderID).Preload("MidtransTransaction").First(&payment).Error
	return &payment, err
}
func (r *PaymentRepository) FindByID(id uuid.UUID) (*models.Payment, error) {
	var payment models.Payment
	err := r.DB.Preload("MidtransTransaction").Preload("Order").First(&payment, id).Error
	return &payment, err
}
func (r *PaymentRepository) Update(payment *models.Payment) error {
	return r.DB.Save(payment).Error
}
func (r *PaymentRepository) CreateMidtransTransaction(tx *models.MidtransTransaction) error {
	return r.DB.Create(tx).Error
}
func (r *PaymentRepository) FindMidtransByOrderID(orderIDMidtrans string) (*models.MidtransTransaction, error) {
	var mt models.MidtransTransaction
	err := r.DB.Where("order_id_midtrans = ?", orderIDMidtrans).Preload("Payment").First(&mt).Error
	return &mt, err
}
func (r *PaymentRepository) UpdateMidtransTransaction(tx *models.MidtransTransaction) error {
	return r.DB.Save(tx).Error
}
