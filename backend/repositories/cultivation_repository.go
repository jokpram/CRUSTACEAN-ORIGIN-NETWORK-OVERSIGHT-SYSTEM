package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type CultivationRepository struct {
	DB *gorm.DB
}
func NewCultivationRepository(db *gorm.DB) *CultivationRepository {
	return &CultivationRepository{DB: db}
}
func (r *CultivationRepository) Create(cycle *models.CultivationCycle) error {
	return r.DB.Create(cycle).Error
}
func (r *CultivationRepository) FindByPondID(pondID uuid.UUID) ([]models.CultivationCycle, error) {
	var cycles []models.CultivationCycle
	err := r.DB.Where("pond_id = ?", pondID).
		Preload("ShrimpType").Preload("Pond").
		Order("created_at DESC").Find(&cycles).Error
	return cycles, err
}
func (r *CultivationRepository) FindByUserID(userID uuid.UUID) ([]models.CultivationCycle, error) {
	var cycles []models.CultivationCycle
	err := r.DB.Joins("JOIN ponds ON ponds.id = cultivation_cycles.pond_id").
		Joins("JOIN farms ON farms.id = ponds.farm_id").
		Where("farms.user_id = ?", userID).
		Preload("ShrimpType").Preload("Pond").Preload("Pond.Farm").
		Order("cultivation_cycles.created_at DESC").Find(&cycles).Error
	return cycles, err
}
func (r *CultivationRepository) FindByID(id uuid.UUID) (*models.CultivationCycle, error) {
	var cycle models.CultivationCycle
	err := r.DB.Preload("ShrimpType").Preload("Pond").Preload("Pond.Farm").
		Preload("FeedLogs").Preload("WaterQualityLogs").Preload("Harvests").
		First(&cycle, id).Error
	return &cycle, err
}
func (r *CultivationRepository) Update(cycle *models.CultivationCycle) error {
	return r.DB.Save(cycle).Error
}
func (r *CultivationRepository) CreateFeedLog(log *models.FeedLog) error {
	return r.DB.Create(log).Error
}
func (r *CultivationRepository) FindFeedLogs(cycleID uuid.UUID) ([]models.FeedLog, error) {
	var logs []models.FeedLog
	err := r.DB.Where("cultivation_cycle_id = ?", cycleID).Order("feeding_time DESC").Find(&logs).Error
	return logs, err
}
func (r *CultivationRepository) CreateWaterQualityLog(log *models.WaterQualityLog) error {
	return r.DB.Create(log).Error
}
func (r *CultivationRepository) FindWaterQualityLogs(cycleID uuid.UUID) ([]models.WaterQualityLog, error) {
	var logs []models.WaterQualityLog
	err := r.DB.Where("cultivation_cycle_id = ?", cycleID).Order("recorded_at DESC").Find(&logs).Error
	return logs, err
}
func (r *CultivationRepository) CountByUserID(userID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.CultivationCycle{}).
		Joins("JOIN ponds ON ponds.id = cultivation_cycles.pond_id").
		Joins("JOIN farms ON farms.id = ponds.farm_id").
		Where("farms.user_id = ?", userID).Count(&count).Error
	return count, err
}
