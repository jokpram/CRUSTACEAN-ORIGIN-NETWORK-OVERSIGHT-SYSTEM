package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type ReviewRepository struct {
	DB *gorm.DB
}
func NewReviewRepository(db *gorm.DB) *ReviewRepository {
	return &ReviewRepository{DB: db}
}
func (r *ReviewRepository) Create(review *models.Review) error {
	return r.DB.Create(review).Error
}
func (r *ReviewRepository) FindByProductID(productID uuid.UUID) ([]models.Review, error) {
	var reviews []models.Review
	err := r.DB.Where("product_id = ?", productID).Preload("User").
		Order("created_at DESC").Find(&reviews).Error
	return reviews, err
}
func (r *ReviewRepository) FindByUserAndProduct(userID, productID uuid.UUID) (*models.Review, error) {
	var review models.Review
	err := r.DB.Where("user_id = ? AND product_id = ?", userID, productID).First(&review).Error
	return &review, err
}
