package repositories

import (
	"cronos-backend/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRepository struct {
	DB *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{DB: db}
}
func (r *UserRepository) Create(user *models.User) error {
	return r.DB.Create(user).Error
}
func (r *UserRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.DB.Where("email = ?", email).First(&user).Error
	return &user, err
}
func (r *UserRepository) FindByID(id uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.DB.First(&user, id).Error
	return &user, err
}
func (r *UserRepository) Update(user *models.User) error {
	return r.DB.Save(user).Error
}
func (r *UserRepository) Delete(id uuid.UUID) error {
	return r.DB.Delete(&models.User{}, id).Error
}
func (r *UserRepository) FindAll(page, limit int, role, search string) ([]models.User, int64, error) {
	var users []models.User
	var total int64
	query := r.DB.Model(&models.User{}).Where("role != ?", "admin")
	if role != "" {
		query = query.Where("role = ?", role)
	}
	if search != "" {
		query = query.Where("name ILIKE ? OR email ILIKE ?", "%"+search+"%", "%"+search+"%")
	}
	query.Count(&total)
	offset := (page - 1) * limit
	err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&users).Error
	return users, total, err
}
func (r *UserRepository) FindUnverified() ([]models.User, error) {
	var users []models.User
	err := r.DB.Where("is_verified = ? AND role IN ?", false, []string{"petambak", "logistik"}).
		Order("created_at DESC").Find(&users).Error
	return users, err
}
func (r *UserRepository) CountByRole() (map[string]int64, error) {
	type RoleCount struct {
		Role  string
		Count int64
	}
	var results []RoleCount
	err := r.DB.Model(&models.User{}).Select("role, count(*) as count").Group("role").Find(&results).Error
	if err != nil {
		return nil, err
	}
	counts := make(map[string]int64)
	for _, r := range results {
		counts[r.Role] = r.Count
	}
	return counts, nil
}
