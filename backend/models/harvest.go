package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Harvest struct {
	ID                 uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	CultivationCycleID uuid.UUID      `gorm:"type:uuid;not null;index" json:"cultivation_cycle_id"`
	HarvestDate        time.Time      `gorm:"not null" json:"harvest_date"`
	TotalWeight        float64        `gorm:"type:decimal(10,2);not null" json:"total_weight" validate:"required,gt=0"`
	ShrimpSize         string         `gorm:"type:varchar(50)" json:"shrimp_size"`
	QualityGrade       string         `gorm:"type:varchar(10)" json:"quality_grade"`
	Notes              string         `gorm:"type:text" json:"notes"`
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
	DeletedAt          gorm.DeletedAt `gorm:"index" json:"-"`
	CultivationCycle CultivationCycle `gorm:"foreignKey:CultivationCycleID" json:"cultivation_cycle,omitempty"`
	Batches          []Batch          `gorm:"foreignKey:HarvestID" json:"batches,omitempty"`
}
func (h *Harvest) BeforeCreate(tx *gorm.DB) error {
	if h.ID == uuid.Nil {
		h.ID = uuid.New()
	}
	return nil
}
type Batch struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	HarvestID uuid.UUID      `gorm:"type:uuid;not null;index" json:"harvest_id"`
	BatchCode string         `gorm:"type:varchar(50);uniqueIndex;not null" json:"batch_code"`
	Quantity  float64        `gorm:"type:decimal(10,2);not null" json:"quantity" validate:"required,gt=0"`
	Status    string         `gorm:"type:varchar(50);default:'available'" json:"status"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Harvest  Harvest   `gorm:"foreignKey:HarvestID" json:"harvest,omitempty"`
	Products []Product `gorm:"foreignKey:BatchID" json:"products,omitempty"`
}
func (b *Batch) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return nil
}
