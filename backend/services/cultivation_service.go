package services
import (
	"errors"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type CultivationService struct {
	CultivationRepo *repositories.CultivationRepository
	FarmRepo        *repositories.FarmRepository
	Ledger          *blockchain.Ledger
}
func NewCultivationService(cultRepo *repositories.CultivationRepository, farmRepo *repositories.FarmRepository, ledger *blockchain.Ledger) *CultivationService {
	return &CultivationService{CultivationRepo: cultRepo, FarmRepo: farmRepo, Ledger: ledger}
}
func (s *CultivationService) CreateCycle(userID uuid.UUID, cycle *models.CultivationCycle) error {
	pond, err := s.FarmRepo.FindPondByID(cycle.PondID)
	if err != nil {
		return errors.New("pond not found")
	}
	farm, err := s.FarmRepo.FindByID(pond.FarmID)
	if err != nil || farm.UserID != userID {
		return errors.New("unauthorized")
	}
	if err := s.CultivationRepo.Create(cycle); err != nil {
		return errors.New("failed to create cultivation cycle")
	}
	s.Ledger.RecordEvent("cultivation_started", userID, "cultivation", cycle.ID, map[string]interface{}{
		"pond_id":     cycle.PondID,
		"shrimp_type": cycle.ShrimpTypeID,
		"start_date":  cycle.StartDate,
	})
	return nil
}
func (s *CultivationService) GetMyCycles(userID uuid.UUID) ([]models.CultivationCycle, error) {
	return s.CultivationRepo.FindByUserID(userID)
}
func (s *CultivationService) GetCycle(id uuid.UUID) (*models.CultivationCycle, error) {
	return s.CultivationRepo.FindByID(id)
}
func (s *CultivationService) UpdateCycle(userID, cycleID uuid.UUID, req *models.CultivationCycle) (*models.CultivationCycle, error) {
	cycle, err := s.CultivationRepo.FindByID(cycleID)
	if err != nil {
		return nil, errors.New("cycle not found")
	}
	if req.Status != "" {
		cycle.Status = req.Status
	}
	if req.ActualEndDate != nil {
		cycle.ActualEndDate = req.ActualEndDate
	}
	if req.Notes != "" {
		cycle.Notes = req.Notes
	}
	if err := s.CultivationRepo.Update(cycle); err != nil {
		return nil, errors.New("failed to update cycle")
	}
	return cycle, nil
}
func (s *CultivationService) AddFeedLog(userID uuid.UUID, log *models.FeedLog) error {
	if err := s.CultivationRepo.CreateFeedLog(log); err != nil {
		return errors.New("failed to add feed log")
	}
	s.Ledger.RecordEvent("feed_logged", userID, "cultivation", log.CultivationCycleID, map[string]interface{}{
		"feed_type": log.FeedType,
		"quantity":  log.Quantity,
	})
	return nil
}
func (s *CultivationService) GetFeedLogs(cycleID uuid.UUID) ([]models.FeedLog, error) {
	return s.CultivationRepo.FindFeedLogs(cycleID)
}
func (s *CultivationService) AddWaterQualityLog(userID uuid.UUID, log *models.WaterQualityLog) error {
	if err := s.CultivationRepo.CreateWaterQualityLog(log); err != nil {
		return errors.New("failed to add water quality log")
	}
	s.Ledger.RecordEvent("water_quality_logged", userID, "cultivation", log.CultivationCycleID, map[string]interface{}{
		"temperature":      log.Temperature,
		"ph":               log.PH,
		"salinity":         log.Salinity,
		"dissolved_oxygen": log.DissolvedOxygen,
	})
	return nil
}
func (s *CultivationService) GetWaterQualityLogs(cycleID uuid.UUID) ([]models.WaterQualityLog, error) {
	return s.CultivationRepo.FindWaterQualityLogs(cycleID)
}
