package services
import (
	"errors"
	"fmt"
	"time"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type HarvestService struct {
	HarvestRepo *repositories.HarvestRepository
	Ledger      *blockchain.Ledger
}
func NewHarvestService(harvestRepo *repositories.HarvestRepository, ledger *blockchain.Ledger) *HarvestService {
	return &HarvestService{HarvestRepo: harvestRepo, Ledger: ledger}
}
func (s *HarvestService) CreateHarvest(userID uuid.UUID, harvest *models.Harvest) error {
	if err := s.HarvestRepo.CreateHarvest(harvest); err != nil {
		return errors.New("failed to create harvest")
	}
	s.Ledger.RecordEvent("harvest_completed", userID, "harvest", harvest.ID, map[string]interface{}{
		"total_weight":  harvest.TotalWeight,
		"shrimp_size":   harvest.ShrimpSize,
		"quality_grade": harvest.QualityGrade,
	})
	return nil
}
func (s *HarvestService) GetMyHarvests(userID uuid.UUID) ([]models.Harvest, error) {
	return s.HarvestRepo.FindHarvestsByUserID(userID)
}
func (s *HarvestService) GetHarvest(id uuid.UUID) (*models.Harvest, error) {
	return s.HarvestRepo.FindHarvestByID(id)
}
func (s *HarvestService) CreateBatch(userID uuid.UUID, batch *models.Batch) error {
	serial, err := s.HarvestRepo.GetNextBatchSerial()
	if err != nil {
		return errors.New("failed to generate batch code")
	}
	year := time.Now().Year()
	batch.BatchCode = fmt.Sprintf("CRN-VNM-%d-%06d", year, serial)
	if err := s.HarvestRepo.CreateBatch(batch); err != nil {
		return errors.New("failed to create batch")
	}
	s.Ledger.RecordEvent("batch_created", userID, "batch", batch.ID, map[string]interface{}{
		"batch_code": batch.BatchCode,
		"quantity":   batch.Quantity,
	})
	return nil
}
func (s *HarvestService) GetMyBatches(userID uuid.UUID) ([]models.Batch, error) {
	return s.HarvestRepo.FindBatchesByUserID(userID)
}
func (s *HarvestService) GetBatchByCode(code string) (*models.Batch, error) {
	return s.HarvestRepo.FindBatchByCode(code)
}
