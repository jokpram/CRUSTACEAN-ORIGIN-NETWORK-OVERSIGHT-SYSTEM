package services
import (
	"errors"
	"math"
	"strconv"
	"cronos-backend/models"
	"cronos-backend/repositories"
	"cronos-backend/utils"
	"github.com/google/uuid"
)
type UserService struct {
	UserRepo *repositories.UserRepository
}
func NewUserService(userRepo *repositories.UserRepository) *UserService {
	return &UserService{UserRepo: userRepo}
}
func (s *UserService) GetAllUsers(page, limit int, role, search string) ([]models.UserResponse, *utils.PaginationMeta, error) {
	users, total, err := s.UserRepo.FindAll(page, limit, role, search)
	if err != nil {
		return nil, nil, errors.New("failed to fetch users")
	}
	var responses []models.UserResponse
	for _, u := range users {
		responses = append(responses, u.ToResponse())
	}
	meta := &utils.PaginationMeta{
		CurrentPage: page,
		PerPage:     limit,
		Total:       total,
		TotalPages:  int(math.Ceil(float64(total) / float64(limit))),
	}
	return responses, meta, nil
}
func (s *UserService) VerifyUser(userID uuid.UUID) (*models.UserResponse, error) {
	user, err := s.UserRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}
	if user.Role != "petambak" && user.Role != "logistik" {
		return nil, errors.New("only petambak and logistik accounts need verification")
	}
	user.IsVerified = true
	if err := s.UserRepo.Update(user); err != nil {
		return nil, errors.New("failed to verify user")
	}
	resp := user.ToResponse()
	return &resp, nil
}
func (s *UserService) CreateUser(req models.CreateUserRequest) (*models.UserResponse, error) {
	existing, _ := s.UserRepo.FindByEmail(req.Email)
	if existing != nil && existing.ID != uuid.Nil {
		return nil, errors.New("email already registered")
	}
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, errors.New("failed to hash password")
	}
	user := &models.User{
		ID:         uuid.New(),
		Name:       req.Name,
		Email:      req.Email,
		Password:   hashedPassword,
		Phone:      req.Phone,
		Role:       req.Role,
		IsVerified: true, 
	}
	if err := s.UserRepo.Create(user); err != nil {
		return nil, errors.New("failed to create user")
	}
	resp := user.ToResponse()
	return &resp, nil
}
func (s *UserService) UpdateUserStatus(userID uuid.UUID, isVerified bool) (*models.UserResponse, error) {
	user, err := s.UserRepo.FindByID(userID)
	if err != nil {
		return nil, errors.New("user not found")
	}
	user.IsVerified = isVerified
	if err := s.UserRepo.Update(user); err != nil {
		return nil, errors.New("failed to update user status")
	}
	resp := user.ToResponse()
	return &resp, nil
}
func (s *UserService) ParsePagination(pageStr, limitStr string) (int, int) {
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}
	return page, limit
}
