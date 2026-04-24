package repositories
import (
	"cronos-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type HarvestRepository struct {
	DB *gorm.DB
}
func NewHarvestRepository(db *gorm.DB) *HarvestRepository {
	return &HarvestRepository{DB: db}
}
func (r *HarvestRepository) CreateHarvest(harvest *models.Harvest) error {
	return r.DB.Create(harvest).Error
}
func (r *HarvestRepository) FindHarvestsByUserID(userID uuid.UUID) ([]models.Harvest, error) {
	var harvests []models.Harvest
	err := r.DB.Joins("JOIN cultivation_cycles ON cultivation_cycles.id = harvests.cultivation_cycle_id").
		Joins("JOIN ponds ON ponds.id = cultivation_cycles.pond_id").
		Joins("JOIN farms ON farms.id = ponds.farm_id").
		Where("farms.user_id = ?", userID).
		Preload("CultivationCycle").Preload("CultivationCycle.Pond").Preload("CultivationCycle.ShrimpType").
		Preload("Batches").
		Order("harvests.created_at DESC").Find(&harvests).Error
	return harvests, err
}
func (r *HarvestRepository) FindHarvestByID(id uuid.UUID) (*models.Harvest, error) {
	var harvest models.Harvest
	err := r.DB.Preload("CultivationCycle").Preload("CultivationCycle.Pond").Preload("CultivationCycle.ShrimpType").
		Preload("Batches").First(&harvest, id).Error
	return &harvest, err
}
func (r *HarvestRepository) CreateBatch(batch *models.Batch) error {
	return r.DB.Create(batch).Error
}
func (r *HarvestRepository) FindBatchesByUserID(userID uuid.UUID) ([]models.Batch, error) {
	var batches []models.Batch
	err := r.DB.Joins("JOIN harvests ON harvests.id = batches.harvest_id").
		Joins("JOIN cultivation_cycles ON cultivation_cycles.id = harvests.cultivation_cycle_id").
		Joins("JOIN ponds ON ponds.id = cultivation_cycles.pond_id").
		Joins("JOIN farms ON farms.id = ponds.farm_id").
		Where("farms.user_id = ?", userID).
		Preload("Harvest").Preload("Harvest.CultivationCycle").
		Order("batches.created_at DESC").Find(&batches).Error
	return batches, err
}
func (r *HarvestRepository) FindBatchByCode(code string) (*models.Batch, error) {
	var batch models.Batch
	err := r.DB.Where("batch_code = ?", code).
		Preload("Harvest").Preload("Harvest.CultivationCycle").Preload("Harvest.CultivationCycle.Pond").
		Preload("Harvest.CultivationCycle.Pond.Farm").Preload("Harvest.CultivationCycle.ShrimpType").
		First(&batch).Error
	return &batch, err
}
func (r *HarvestRepository) FindBatchByID(id uuid.UUID) (*models.Batch, error) {
	var batch models.Batch
	err := r.DB.Preload("Harvest").First(&batch, id).Error
	return &batch, err
}
func (r *HarvestRepository) GetNextBatchSerial() (int, error) {
	var count int64
	r.DB.Model(&models.Batch{}).Count(&count)
	return int(count) + 1, nil
}
func (r *HarvestRepository) CountHarvestsByUserID(userID uuid.UUID) (int64, error) {
	var count int64
	err := r.DB.Model(&models.Harvest{}).
		Joins("JOIN cultivation_cycles ON cultivation_cycles.id = harvests.cultivation_cycle_id").
		Joins("JOIN ponds ON ponds.id = cultivation_cycles.pond_id").
		Joins("JOIN farms ON farms.id = ponds.farm_id").
		Where("farms.user_id = ?", userID).Count(&count).Error
	return count, err
}
