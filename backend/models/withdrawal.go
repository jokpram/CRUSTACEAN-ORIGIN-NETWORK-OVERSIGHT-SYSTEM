package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Withdrawal struct {
	ID            uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	UserID        uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	Amount        float64        `gorm:"type:decimal(15,2);not null" json:"amount" validate:"required,gt=0"`
	BankName      string         `gorm:"type:varchar(100);not null" json:"bank_name" validate:"required"`
	AccountNumber string         `gorm:"type:varchar(50);not null" json:"account_number" validate:"required"`
	AccountName   string         `gorm:"type:varchar(255);not null" json:"account_name" validate:"required"`
	Status        string         `gorm:"type:varchar(50);default:'pending'" json:"status"`
	Notes         string         `gorm:"type:text" json:"notes"`
	ProcessedAt   *time.Time     `json:"processed_at"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`
	User User `gorm:"foreignKey:UserID" json:"user,omitempty"`
}
func (w *Withdrawal) BeforeCreate(tx *gorm.DB) error {
	if w.ID == uuid.Nil {
		w.ID = uuid.New()
	}
	return nil
}
