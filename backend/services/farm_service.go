package services
import (
	"errors"
	"cronos-backend/blockchain"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type FarmService struct {
	FarmRepo *repositories.FarmRepository
	Ledger   *blockchain.Ledger
}
func NewFarmService(farmRepo *repositories.FarmRepository, ledger *blockchain.Ledger) *FarmService {
	return &FarmService{FarmRepo: farmRepo, Ledger: ledger}
}
func (s *FarmService) CreateFarm(userID uuid.UUID, farm *models.Farm) error {
	farm.UserID = userID
	if err := s.FarmRepo.Create(farm); err != nil {
		return errors.New("failed to create farm")
	}
	s.Ledger.RecordEvent("farm_created", userID, "farm", farm.ID, map[string]interface{}{
		"name":     farm.Name,
		"location": farm.Location,
	})
	return nil
}
func (s *FarmService) GetMyFarms(userID uuid.UUID) ([]models.Farm, error) {
	return s.FarmRepo.FindByUserID(userID)
}
func (s *FarmService) GetFarm(id uuid.UUID) (*models.Farm, error) {
	return s.FarmRepo.FindByID(id)
}
func (s *FarmService) UpdateFarm(userID, farmID uuid.UUID, req *models.Farm) (*models.Farm, error) {
	farm, err := s.FarmRepo.FindByID(farmID)
	if err != nil {
		return nil, errors.New("farm not found")
	}
	if farm.UserID != userID {
		return nil, errors.New("unauthorized")
	}
	farm.Name = req.Name
	farm.Location = req.Location
	farm.Area = req.Area
	farm.Description = req.Description
	if req.Image != "" {
		farm.Image = req.Image
	}
	if err := s.FarmRepo.Update(farm); err != nil {
		return nil, errors.New("failed to update farm")
	}
	return farm, nil
}
func (s *FarmService) DeleteFarm(userID, farmID uuid.UUID) error {
	farm, err := s.FarmRepo.FindByID(farmID)
	if err != nil {
		return errors.New("farm not found")
	}
	if farm.UserID != userID {
		return errors.New("unauthorized")
	}
	return s.FarmRepo.Delete(farmID)
}
func (s *FarmService) CreatePond(userID, farmID uuid.UUID, pond *models.Pond) error {
	farm, err := s.FarmRepo.FindByID(farmID)
	if err != nil {
		return errors.New("farm not found")
	}
	if farm.UserID != userID {
		return errors.New("unauthorized")
	}
	pond.FarmID = farmID
	return s.FarmRepo.CreatePond(pond)
}
func (s *FarmService) GetPonds(farmID uuid.UUID) ([]models.Pond, error) {
	return s.FarmRepo.FindPondsByFarmID(farmID)
}
func (s *FarmService) UpdatePond(userID, pondID uuid.UUID, req *models.Pond) (*models.Pond, error) {
	pond, err := s.FarmRepo.FindPondByID(pondID)
	if err != nil {
		return nil, errors.New("pond not found")
	}
	farm, err := s.FarmRepo.FindByID(pond.FarmID)
	if err != nil || farm.UserID != userID {
		return nil, errors.New("unauthorized")
	}
	pond.Name = req.Name
	pond.Area = req.Area
	pond.Depth = req.Depth
	pond.Status = req.Status
	if err := s.FarmRepo.UpdatePond(pond); err != nil {
		return nil, errors.New("failed to update pond")
	}
	return pond, nil
}
func (s *FarmService) DeletePond(userID, pondID uuid.UUID) error {
	pond, err := s.FarmRepo.FindPondByID(pondID)
	if err != nil {
		return errors.New("pond not found")
	}
	farm, err := s.FarmRepo.FindByID(pond.FarmID)
	if err != nil || farm.UserID != userID {
		return errors.New("unauthorized")
	}
	return s.FarmRepo.DeletePond(pondID)
}
