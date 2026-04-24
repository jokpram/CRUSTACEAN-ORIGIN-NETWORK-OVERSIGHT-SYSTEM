package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type CultivationCycle struct {
	ID              uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	PondID          uuid.UUID      `gorm:"type:uuid;not null;index" json:"pond_id"`
	ShrimpTypeID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"shrimp_type_id"`
	StartDate       time.Time      `gorm:"not null" json:"start_date"`
	ExpectedEndDate *time.Time     `json:"expected_end_date"`
	ActualEndDate   *time.Time     `json:"actual_end_date"`
	Status          string         `gorm:"type:varchar(50);default:'active'" json:"status"`
	Density         float64        `gorm:"type:decimal(10,2)" json:"density"`
	Notes           string         `gorm:"type:text" json:"notes"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
	Pond             Pond              `gorm:"foreignKey:PondID" json:"pond,omitempty"`
	ShrimpType       ShrimpType        `gorm:"foreignKey:ShrimpTypeID" json:"shrimp_type,omitempty"`
	FeedLogs         []FeedLog         `gorm:"foreignKey:CultivationCycleID" json:"feed_logs,omitempty"`
	WaterQualityLogs []WaterQualityLog `gorm:"foreignKey:CultivationCycleID" json:"water_quality_logs,omitempty"`
	Harvests         []Harvest         `gorm:"foreignKey:CultivationCycleID" json:"harvests,omitempty"`
}
func (c *CultivationCycle) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}
type FeedLog struct {
	ID                 uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	CultivationCycleID uuid.UUID      `gorm:"type:uuid;not null;index" json:"cultivation_cycle_id"`
	FeedType           string         `gorm:"type:varchar(255);not null" json:"feed_type" validate:"required"`
	Quantity           float64        `gorm:"type:decimal(10,2);not null" json:"quantity" validate:"required,gt=0"`
	FeedingTime        time.Time      `gorm:"not null" json:"feeding_time"`
	Notes              string         `gorm:"type:text" json:"notes"`
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
	DeletedAt          gorm.DeletedAt `gorm:"index" json:"-"`
	CultivationCycle CultivationCycle `gorm:"foreignKey:CultivationCycleID" json:"cultivation_cycle,omitempty"`
}
func (f *FeedLog) BeforeCreate(tx *gorm.DB) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	return nil
}
type WaterQualityLog struct {
	ID                 uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	CultivationCycleID uuid.UUID      `gorm:"type:uuid;not null;index" json:"cultivation_cycle_id"`
	Temperature        float64        `gorm:"type:decimal(5,2)" json:"temperature"`
	PH                 float64        `gorm:"type:decimal(4,2)" json:"ph"`
	Salinity           float64        `gorm:"type:decimal(5,2)" json:"salinity"`
	DissolvedOxygen    float64        `gorm:"type:decimal(5,2)" json:"dissolved_oxygen"`
	RecordedAt         time.Time      `gorm:"not null" json:"recorded_at"`
	Notes              string         `gorm:"type:text" json:"notes"`
	CreatedAt          time.Time      `json:"created_at"`
	UpdatedAt          time.Time      `json:"updated_at"`
	DeletedAt          gorm.DeletedAt `gorm:"index" json:"-"`
	CultivationCycle CultivationCycle `gorm:"foreignKey:CultivationCycleID" json:"cultivation_cycle,omitempty"`
}
func (w *WaterQualityLog) BeforeCreate(tx *gorm.DB) error {
	if w.ID == uuid.Nil {
		w.ID = uuid.New()
	}
	return nil
}
