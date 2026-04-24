package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Farm struct {
	ID          uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	UserID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	Name        string         `gorm:"type:varchar(255);not null" json:"name" validate:"required,min=2,max=255"`
	Location    string         `gorm:"type:text" json:"location"`
	Area        float64        `gorm:"type:decimal(10,2)" json:"area"`
	Description string         `gorm:"type:text" json:"description"`
	Image       string         `gorm:"type:varchar(500)" json:"image"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
	User  User   `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Ponds []Pond `gorm:"foreignKey:FarmID" json:"ponds,omitempty"`
}
func (f *Farm) BeforeCreate(tx *gorm.DB) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	return nil
}
type Pond struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	FarmID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"farm_id"`
	Name      string         `gorm:"type:varchar(255);not null" json:"name" validate:"required,min=2,max=255"`
	Area      float64        `gorm:"type:decimal(10,2)" json:"area"`
	Depth     float64        `gorm:"type:decimal(5,2)" json:"depth"`
	Status    string         `gorm:"type:varchar(50);default:'active'" json:"status"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Farm              Farm               `gorm:"foreignKey:FarmID" json:"farm,omitempty"`
	CultivationCycles []CultivationCycle `gorm:"foreignKey:PondID" json:"cultivation_cycles,omitempty"`
}
func (p *Pond) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}
