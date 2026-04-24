package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Payment struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	OrderID   uuid.UUID      `gorm:"type:uuid;not null;uniqueIndex" json:"order_id"`
	Amount    float64        `gorm:"type:decimal(15,2);not null" json:"amount"`
	Method    string         `gorm:"type:varchar(50)" json:"method"`
	Status    string         `gorm:"type:varchar(50);default:'pending'" json:"status"`
	PaidAt    *time.Time     `json:"paid_at"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Order               Order                `gorm:"foreignKey:OrderID" json:"order,omitempty"`
	MidtransTransaction *MidtransTransaction `gorm:"foreignKey:PaymentID" json:"midtrans_transaction,omitempty"`
}
func (p *Payment) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}
type MidtransTransaction struct {
	ID                uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	PaymentID         uuid.UUID      `gorm:"type:uuid;not null;uniqueIndex" json:"payment_id"`
	OrderIDMidtrans   string         `gorm:"type:varchar(100);uniqueIndex" json:"order_id_midtrans"`
	SnapToken         string         `gorm:"type:varchar(500)" json:"snap_token"`
	SnapURL           string         `gorm:"type:varchar(500)" json:"snap_url"`
	TransactionStatus string         `gorm:"type:varchar(50)" json:"transaction_status"`
	PaymentType       string         `gorm:"type:varchar(50)" json:"payment_type"`
	FraudStatus       string         `gorm:"type:varchar(50)" json:"fraud_status"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
	Payment Payment `gorm:"foreignKey:PaymentID" json:"payment,omitempty"`
}
func (mt *MidtransTransaction) BeforeCreate(tx *gorm.DB) error {
	if mt.ID == uuid.Nil {
		mt.ID = uuid.New()
	}
	return nil
}
