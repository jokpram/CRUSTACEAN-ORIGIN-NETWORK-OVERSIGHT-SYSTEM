package services
import (
	"errors"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type ReviewService struct {
	ReviewRepo  *repositories.ReviewRepository
	ProductRepo *repositories.ProductRepository
}
func NewReviewService(reviewRepo *repositories.ReviewRepository, productRepo *repositories.ProductRepository) *ReviewService {
	return &ReviewService{ReviewRepo: reviewRepo, ProductRepo: productRepo}
}
func (s *ReviewService) CreateReview(userID uuid.UUID, review *models.Review) error {
	existing, _ := s.ReviewRepo.FindByUserAndProduct(userID, review.ProductID)
	if existing != nil && existing.ID != uuid.Nil {
		return errors.New("you have already reviewed this product")
	}
	review.UserID = userID
	if err := s.ReviewRepo.Create(review); err != nil {
		return errors.New("failed to create review")
	}
	s.ProductRepo.UpdateRating(review.ProductID)
	return nil
}
func (s *ReviewService) GetProductReviews(productID uuid.UUID) ([]models.Review, error) {
	return s.ReviewRepo.FindByProductID(productID)
}
