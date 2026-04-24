package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type FarmRepository struct {
	DB *gorm.DB
}
func NewFarmRepository(db *gorm.DB) *FarmRepository {
	return &FarmRepository{DB: db}
}
func (r *FarmRepository) Create(farm *models.Farm) error {
	return r.DB.Create(farm).Error
}
func (r *FarmRepository) FindByUserID(userID uuid.UUID) ([]models.Farm, error) {
	var farms []models.Farm
	err := r.DB.Where("user_id = ?", userID).Preload("Ponds").Order("created_at DESC").Find(&farms).Error
	return farms, err
}
func (r *FarmRepository) FindByID(id uuid.UUID) (*models.Farm, error) {
	var farm models.Farm
	err := r.DB.Preload("Ponds").Preload("User").First(&farm, id).Error
	return &farm, err
}
func (r *FarmRepository) Update(farm *models.Farm) error {
	return r.DB.Save(farm).Error
}
func (r *FarmRepository) Delete(id uuid.UUID) error {
	return r.DB.Delete(&models.Farm{}, id).Error
}
func (r *FarmRepository) CreatePond(pond *models.Pond) error {
	return r.DB.Create(pond).Error
}
func (r *FarmRepository) FindPondsByFarmID(farmID uuid.UUID) ([]models.Pond, error) {
	var ponds []models.Pond
	err := r.DB.Where("farm_id = ?", farmID).Order("created_at DESC").Find(&ponds).Error
	return ponds, err
}
func (r *FarmRepository) FindPondByID(id uuid.UUID) (*models.Pond, error) {
	var pond models.Pond
	err := r.DB.Preload("Farm").First(&pond, id).Error
	return &pond, err
}
func (r *FarmRepository) UpdatePond(pond *models.Pond) error {
	return r.DB.Save(pond).Error
}
func (r *FarmRepository) DeletePond(id uuid.UUID) error {
	return r.DB.Delete(&models.Pond{}, id).Error
}
func (r *FarmRepository) CountByUserID(userID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Farm{}).Where("user_id = ?", userID).Count(&count).Error
	return count, err
}
