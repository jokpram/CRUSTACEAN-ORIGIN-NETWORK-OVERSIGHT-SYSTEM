package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type TraceabilityLog struct {
	ID           uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	PreviousHash string         `gorm:"type:varchar(64);not null" json:"previous_hash"`
	CurrentHash  string         `gorm:"type:varchar(64);not null;uniqueIndex" json:"current_hash"`
	Timestamp    time.Time      `gorm:"not null" json:"timestamp"`
	EventType    string         `gorm:"type:varchar(100);not null;index" json:"event_type"`
	ActorID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"actor_id"`
	EntityType   string         `gorm:"type:varchar(100);not null" json:"entity_type"`
	EntityID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"entity_id"`
	DataPayload  string         `gorm:"type:jsonb" json:"data_payload"`
	CreatedAt    time.Time      `json:"created_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
	Actor User `gorm:"foreignKey:ActorID" json:"actor,omitempty"`
}
func (t *TraceabilityLog) BeforeCreate(tx *gorm.DB) error {
	if t.ID == uuid.Nil {
		t.ID = uuid.New()
	}
	return nil
}
