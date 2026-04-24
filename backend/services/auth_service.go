package services
import (
	"errors"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"cronos-backend/utils"
	"github.com/google/uuid"
)
type AuthService struct {
	UserRepo *repositories.UserRepository
}
func NewAuthService(userRepo *repositories.UserRepository) *AuthService {
	return &AuthService{UserRepo: userRepo}
}
func (s *AuthService) Register(req models.RegisterRequest) (*models.UserResponse, string, error) {
	existing, _ := s.UserRepo.FindByEmail(req.Email)
	if existing != nil && existing.ID != uuid.Nil {
		return nil, "", errors.New("email already registered")
	}
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, "", errors.New("failed to hash password")
	}
	user := &models.User{
		ID:         uuid.New(),
		Name:       req.Name,
		Email:      req.Email,
		Password:   hashedPassword,
		Phone:      req.Phone,
		Role:       req.Role,
		IsVerified: req.Role == "konsumen", 
	}
	if err := s.UserRepo.Create(user); err != nil {
		return nil, "", errors.New("failed to create user")
	}
	token, err := utils.GenerateToken(user.ID, user.Email, user.Role)
	if err != nil {
		return nil, "", errors.New("failed to generate token")
	}
	resp := user.ToResponse()
	return &resp, token, nil
}
func (s *AuthService) Login(req models.LoginRequest) (*models.UserResponse, string, error) {
	user, err := s.UserRepo.FindByEmail(req.Email)
	if err != nil {
		return nil, "", errors.New("invalid email or password")
	}
	if !utils.CheckPassword(req.Password, user.Password) {
		return nil, "", errors.New("invalid email or password")
	}
	if !user.IsVerified && (user.Role == "petambak" || user.Role == "logistik") {
		return nil, "", errors.New("your account is pending verification by admin")
	}
	token, err := utils.GenerateToken(user.ID, user.Email, user.Role)
	if err != nil {
		return nil, "", errors.New("failed to generate token")
	}
	resp := user.ToResponse()
	return &resp, token, nil
}
func (s *AuthService) GetProfile(userID uuid.UUID) (*models.UserResponse, error) {
	user, err := s.UserRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}
	resp := user.ToResponse()
	return &resp, nil
}
func (s *AuthService) UpdateProfile(userID uuid.UUID, req models.UpdateProfileRequest) (*models.UserResponse, error) {
	user, err := s.UserRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}
	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Phone != "" {
		user.Phone = req.Phone
	}
	if req.Address != "" {
		user.Address = req.Address
	}
	if req.Avatar != "" {
		user.Avatar = req.Avatar
	}
	if err := s.UserRepo.Update(user); err != nil {
		return nil, errors.New("failed to update profile")
	}
	resp := user.ToResponse()
	return &resp, nil
}
