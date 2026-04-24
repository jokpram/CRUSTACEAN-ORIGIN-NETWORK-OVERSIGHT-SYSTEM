package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type ProductRepository struct {
	DB *gorm.DB
}
func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{DB: db}
}
func (r *ProductRepository) Create(product *models.Product) error {
	return r.DB.Create(product).Error
}
func (r *ProductRepository) FindAll(page, limit int, shrimpType, size, search, sortBy string, minPrice, maxPrice float64) ([]models.Product, int64, error) {
	var products []models.Product
	var total int64
	query := r.DB.Model(&models.Product{}).Where("is_available = ? AND stock > 0", true)
	if shrimpType != "" {
		query = query.Where("shrimp_type = ?", shrimpType)
	}
	if size != "" {
		query = query.Where("size = ?", size)
	}
	if search != "" {
		query = query.Where("name ILIKE ? OR description ILIKE ?", "%"+search+"%", "%"+search+"%")
	}
	if minPrice > 0 {
		query = query.Where("price >= ?", minPrice)
	}
	if maxPrice > 0 {
		query = query.Where("price <= ?", maxPrice)
	}
	query.Count(&total)
	orderClause := "created_at DESC"
	switch sortBy {
	case "price_asc":
		orderClause = "price ASC"
	case "price_desc":
		orderClause = "price DESC"
	case "rating":
		orderClause = "rating_avg DESC"
	case "newest":
		orderClause = "created_at DESC"
	}
	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order(orderClause).
		Preload("Images").Preload("User").Preload("Batch").
		Find(&products).Error
	return products, total, err
}
func (r *ProductRepository) FindByID(id uuid.UUID) (*models.Product, error) {
	var product models.Product
	err := r.DB.Preload("Images").Preload("User").Preload("Batch").Preload("Reviews").Preload("Reviews.User").
		First(&product, id).Error
	return &product, err
}
func (r *ProductRepository) FindByUserID(userID uuid.UUID) ([]models.Product, error) {
	var products []models.Product
	err := r.DB.Where("user_id = ?", userID).Preload("Images").Preload("Batch").
		Order("created_at DESC").Find(&products).Error
	return products, err
}
func (r *ProductRepository) Update(product *models.Product) error {
	return r.DB.Save(product).Error
}
func (r *ProductRepository) Delete(id uuid.UUID) error {
	return r.DB.Delete(&models.Product{}, id).Error
}
func (r *ProductRepository) CreateImage(image *models.ProductImage) error {
	return r.DB.Create(image).Error
}
func (r *ProductRepository) DeleteImages(productID uuid.UUID) error {
	return r.DB.Where("product_id = ?", productID).Delete(&models.ProductImage{}).Error
}
func (r *ProductRepository) CountByUserID(userID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Product{}).Where("user_id = ?", userID).Count(&count).Error
	return count, err
}
func (r *ProductRepository) UpdateRating(productID uuid.UUID) error {
	var result struct {
		AvgRating float64
		Count     int
	}
	r.DB.Model(&models.Review{}).Where("product_id = ?", productID).
		Select("COALESCE(AVG(rating), 0) as avg_rating, COUNT(*) as count").Scan(&result)
	return r.DB.Model(&models.Product{}).Where("id = ?", productID).
		Updates(map[string]interface{}{
			"rating_avg":   result.AvgRating,
			"rating_count": result.Count,
		}).Error
}
