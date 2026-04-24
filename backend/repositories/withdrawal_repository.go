package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type WithdrawalRepository struct {
	DB *gorm.DB
}
func NewWithdrawalRepository(db *gorm.DB) *WithdrawalRepository {
	return &WithdrawalRepository{DB: db}
}
func (r *WithdrawalRepository) Create(withdrawal *models.Withdrawal) error {
	return r.DB.Create(withdrawal).Error
}
func (r *WithdrawalRepository) FindByUserID(userID uuid.UUID) ([]models.Withdrawal, error) {
	var withdrawals []models.Withdrawal
	err := r.DB.Where("user_id = ?", userID).Order("created_at DESC").Find(&withdrawals).Error
	return withdrawals, err
}
func (r *WithdrawalRepository) FindAll() ([]models.Withdrawal, error) {
	var withdrawals []models.Withdrawal
	err := r.DB.Preload("User").Order("created_at DESC").Find(&withdrawals).Error
	return withdrawals, err
}
func (r *WithdrawalRepository) FindByID(id uuid.UUID) (*models.Withdrawal, error) {
	var withdrawal models.Withdrawal
	err := r.DB.Preload("User").First(&withdrawal, id).Error
	return &withdrawal, err
}
func (r *WithdrawalRepository) Update(withdrawal *models.Withdrawal) error {
	return r.DB.Save(withdrawal).Error
}
