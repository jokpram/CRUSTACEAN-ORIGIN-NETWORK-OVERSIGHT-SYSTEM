package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type User struct {
	ID         uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	Name       string         `gorm:"type:varchar(255);not null" json:"name" validate:"required,min=2,max=255"`
	Email      string         `gorm:"type:varchar(255);uniqueIndex;not null" json:"email" validate:"required,email"`
	Password   string         `gorm:"type:varchar(255);not null" json:"-"`
	Phone      string         `gorm:"type:varchar(20)" json:"phone"`
	Role       string         `gorm:"type:varchar(20);not null;default:'konsumen'" json:"role" validate:"required,oneof=admin petambak logistik konsumen"`
	IsVerified bool           `gorm:"default:false" json:"is_verified"`
	Address    string         `gorm:"type:text" json:"address"`
	Avatar     string         `gorm:"type:varchar(500)" json:"avatar"`
	Balance    float64        `gorm:"type:decimal(15,2);default:0" json:"balance"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
	Farms       []Farm       `gorm:"foreignKey:UserID" json:"farms,omitempty"`
	Products    []Product    `gorm:"foreignKey:UserID" json:"products,omitempty"`
	Orders      []Order      `gorm:"foreignKey:UserID" json:"orders,omitempty"`
	Reviews     []Review     `gorm:"foreignKey:UserID" json:"reviews,omitempty"`
	Withdrawals []Withdrawal `gorm:"foreignKey:UserID" json:"withdrawals,omitempty"`
}
func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
}
type RegisterRequest struct {
	Name     string `json:"name" validate:"required,min=2,max=255"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
	Phone    string `json:"phone"`
	Role     string `json:"role" validate:"required,oneof=konsumen"`
}
type CreateUserRequest struct {
	Name     string `json:"name" validate:"required,min=2,max=255"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
	Phone    string `json:"phone"`
	Role     string `json:"role" validate:"required,oneof=petambak logistik admin"`
}
type UpdateProfileRequest struct {
	Name    string `json:"name" validate:"omitempty,min=2,max=255"`
	Phone   string `json:"phone"`
	Address string `json:"address"`
	Avatar  string `json:"avatar"`
}
type UserResponse struct {
	ID         uuid.UUID `json:"id"`
	Name       string    `json:"name"`
	Email      string    `json:"email"`
	Phone      string    `json:"phone"`
	Role       string    `json:"role"`
	IsVerified bool      `json:"is_verified"`
	Address    string    `json:"address"`
	Avatar     string    `json:"avatar"`
	Balance    float64   `json:"balance"`
	CreatedAt  time.Time `json:"created_at"`
}
func (u *User) ToResponse() UserResponse {
	return UserResponse{
		ID:         u.ID,
		Name:       u.Name,
		Email:      u.Email,
		Phone:      u.Phone,
		Role:       u.Role,
		IsVerified: u.IsVerified,
		Address:    u.Address,
		Avatar:     u.Avatar,
		Balance:    u.Balance,
		CreatedAt:  u.CreatedAt,
	}
}
