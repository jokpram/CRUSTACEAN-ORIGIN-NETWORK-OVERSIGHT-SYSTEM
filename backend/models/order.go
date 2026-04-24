package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Order struct {
	ID              uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	UserID          uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	TotalAmount     float64        `gorm:"type:decimal(15,2);not null" json:"total_amount"`
	Status          string         `gorm:"type:varchar(50);default:'pending'" json:"status"`
	ShippingAddress string         `gorm:"type:text" json:"shipping_address"`
	Notes           string         `gorm:"type:text" json:"notes"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
	User       User        `gorm:"foreignKey:UserID" json:"user,omitempty"`
	OrderItems []OrderItem `gorm:"foreignKey:OrderID" json:"order_items,omitempty"`
	Payment    *Payment    `gorm:"foreignKey:OrderID" json:"payment,omitempty"`
	Shipment   *Shipment   `gorm:"foreignKey:OrderID" json:"shipment,omitempty"`
}
func (o *Order) BeforeCreate(tx *gorm.DB) error {
	if o.ID == uuid.Nil {
		o.ID = uuid.New()
	}
	return nil
}
type OrderItem struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	OrderID   uuid.UUID      `gorm:"type:uuid;not null;index" json:"order_id"`
	ProductID uuid.UUID      `gorm:"type:uuid;not null;index" json:"product_id"`
	Quantity  int            `gorm:"not null" json:"quantity" validate:"required,gt=0"`
	Price     float64        `gorm:"type:decimal(15,2);not null" json:"price"`
	Subtotal  float64        `gorm:"type:decimal(15,2);not null" json:"subtotal"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Order   Order   `gorm:"foreignKey:OrderID" json:"order,omitempty"`
	Product Product `gorm:"foreignKey:ProductID" json:"product,omitempty"`
}
func (oi *OrderItem) BeforeCreate(tx *gorm.DB) error {
	if oi.ID == uuid.Nil {
		oi.ID = uuid.New()
	}
	return nil
}
