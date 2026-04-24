package services
import (
	"errors"
	"time"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"github.com/google/uuid"
)
type WithdrawalService struct {
	WithdrawalRepo *repositories.WithdrawalRepository
	UserRepo       *repositories.UserRepository
}
func NewWithdrawalService(withdrawalRepo *repositories.WithdrawalRepository, userRepo *repositories.UserRepository) *WithdrawalService {
	return &WithdrawalService{WithdrawalRepo: withdrawalRepo, UserRepo: userRepo}
}
func (s *WithdrawalService) CreateWithdrawal(userID uuid.UUID, req *models.Withdrawal) error {
	user, err := s.UserRepo.FindByID(userID)
	if err != nil {
		return errors.New("user not found")
	}
	if user.Balance < req.Amount {
		return errors.New("insufficient balance")
	}
	req.UserID = userID
	req.Status = "pending"
	if err := s.WithdrawalRepo.Create(req); err != nil {
		return errors.New("failed to create withdrawal request")
	}
	return nil
}
func (s *WithdrawalService) GetMyWithdrawals(userID uuid.UUID) ([]models.Withdrawal, error) {
	return s.WithdrawalRepo.FindByUserID(userID)
}
func (s *WithdrawalService) GetAllWithdrawals() ([]models.Withdrawal, error) {
	return s.WithdrawalRepo.FindAll()
}
func (s *WithdrawalService) UpdateWithdrawal(withdrawalID uuid.UUID, status, notes string) (*models.Withdrawal, error) {
	withdrawal, err := s.WithdrawalRepo.FindByID(withdrawalID)
	if err != nil {
		return nil, errors.New("withdrawal not found")
	}
	if withdrawal.Status != "pending" && withdrawal.Status != "approved" {
		return nil, errors.New("withdrawal cannot be updated from current status")
	}
	validStatuses := map[string]bool{"approved": true, "rejected": true, "paid": true}
	if !validStatuses[status] {
		return nil, errors.New("invalid status")
	}
	oldStatus := withdrawal.Status
	withdrawal.Status = status
	withdrawal.Notes = notes
	now := time.Now()
	withdrawal.ProcessedAt = &now
	if (status == "approved" || status == "paid") && oldStatus == "pending" {
		user, _ := s.UserRepo.FindByID(withdrawal.UserID)
		if user.Balance < withdrawal.Amount {
			return nil, errors.New("user has insufficient balance")
		}
		user.Balance -= withdrawal.Amount
		s.UserRepo.Update(user)
	}
	if status == "rejected" && oldStatus == "approved" {
		user, _ := s.UserRepo.FindByID(withdrawal.UserID)
		user.Balance += withdrawal.Amount
		s.UserRepo.Update(user)
	}
	if err := s.WithdrawalRepo.Update(withdrawal); err != nil {
		return nil, errors.New("failed to update withdrawal")
	}
	return withdrawal, nil
}
