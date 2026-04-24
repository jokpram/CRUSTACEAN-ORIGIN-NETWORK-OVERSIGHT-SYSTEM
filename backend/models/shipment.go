package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Shipment struct {
	ID                uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	OrderID           uuid.UUID      `gorm:"type:uuid;not null;index" json:"order_id"`
	CourierID         *uuid.UUID     `gorm:"type:uuid;index" json:"courier_id"`
	TrackingNumber    string         `gorm:"type:varchar(100)" json:"tracking_number"`
	Status            string         `gorm:"type:varchar(50);default:'pending'" json:"status"`
	EstimatedDelivery *time.Time     `json:"estimated_delivery"`
	ActualDelivery    *time.Time     `json:"actual_delivery"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
	Order        Order         `gorm:"foreignKey:OrderID" json:"order,omitempty"`
	Courier      *User         `gorm:"foreignKey:CourierID" json:"courier,omitempty"`
	ShipmentLogs []ShipmentLog `gorm:"foreignKey:ShipmentID" json:"shipment_logs,omitempty"`
}
func (s *Shipment) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}
type ShipmentLog struct {
	ID         uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	ShipmentID uuid.UUID      `gorm:"type:uuid;not null;index" json:"shipment_id"`
	Status     string         `gorm:"type:varchar(50);not null" json:"status"`
	Location   string         `gorm:"type:varchar(255)" json:"location"`
	Notes      string         `gorm:"type:text" json:"notes"`
	Timestamp  time.Time      `gorm:"not null" json:"timestamp"`
	CreatedAt  time.Time      `json:"created_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
	Shipment Shipment `gorm:"foreignKey:ShipmentID" json:"shipment,omitempty"`
}
func (sl *ShipmentLog) BeforeCreate(tx *gorm.DB) error {
	if sl.ID == uuid.Nil {
		sl.ID = uuid.New()
	}
	return nil
}
