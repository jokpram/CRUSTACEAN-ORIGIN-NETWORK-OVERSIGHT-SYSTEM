package services
import (
	"errors"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type ShrimpTypeService struct {
	ShrimpTypeRepo *repositories.ShrimpTypeRepository
}
func NewShrimpTypeService(repo *repositories.ShrimpTypeRepository) *ShrimpTypeService {
	return &ShrimpTypeService{ShrimpTypeRepo: repo}
}
func (s *ShrimpTypeService) Create(st *models.ShrimpType) error {
	return s.ShrimpTypeRepo.Create(st)
}
func (s *ShrimpTypeService) GetAll() ([]models.ShrimpType, error) {
	return s.ShrimpTypeRepo.FindAll()
}
func (s *ShrimpTypeService) Update(id uuid.UUID, req *models.ShrimpType) (*models.ShrimpType, error) {
	st, err := s.ShrimpTypeRepo.FindByID(id)
	if err != nil {
		return nil, errors.New("shrimp type not found")
	}
	if req.Name != "" {
		st.Name = req.Name
	}
	if req.Description != "" {
		st.Description = req.Description
	}
	if req.Image != "" {
		st.Image = req.Image
	}
	if err := s.ShrimpTypeRepo.Update(st); err != nil {
		return nil, errors.New("failed to update")
	}
	return st, nil
}
func (s *ShrimpTypeService) Delete(id uuid.UUID) error {
	return s.ShrimpTypeRepo.Delete(id)
}
