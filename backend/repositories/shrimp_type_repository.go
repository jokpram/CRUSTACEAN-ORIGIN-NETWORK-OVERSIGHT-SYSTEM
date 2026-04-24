package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type ShrimpTypeRepository struct {
	DB *gorm.DB
}
func NewShrimpTypeRepository(db *gorm.DB) *ShrimpTypeRepository {
	return &ShrimpTypeRepository{DB: db}
}
func (r *ShrimpTypeRepository) Create(st *models.ShrimpType) error {
	return r.DB.Create(st).Error
}
func (r *ShrimpTypeRepository) FindAll() ([]models.ShrimpType, error) {
	var types []models.ShrimpType
	err := r.DB.Order("name ASC").Find(&types).Error
	return types, err
}
func (r *ShrimpTypeRepository) FindByID(id uuid.UUID) (*models.ShrimpType, error) {
	var st models.ShrimpType
	err := r.DB.First(&st, id).Error
	return &st, err
}
func (r *ShrimpTypeRepository) Update(st *models.ShrimpType) error {
	return r.DB.Save(st).Error
}
func (r *ShrimpTypeRepository) Delete(id uuid.UUID) error {
	return r.DB.Delete(&models.ShrimpType{}, id).Error
}
