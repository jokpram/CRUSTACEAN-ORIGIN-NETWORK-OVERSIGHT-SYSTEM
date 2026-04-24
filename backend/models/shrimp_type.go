package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type ShrimpType struct {
	ID          uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	Name        string         `gorm:"type:varchar(255);not null;uniqueIndex" json:"name" validate:"required,min=2,max=255"`
	Description string         `gorm:"type:text" json:"description"`
	Image       string         `gorm:"type:varchar(500)" json:"image"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}
func (s *ShrimpType) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}
