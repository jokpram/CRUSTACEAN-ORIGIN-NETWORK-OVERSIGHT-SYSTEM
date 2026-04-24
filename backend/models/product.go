package models
import (
	"time"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type Product struct {
	ID          uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	UserID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	BatchID     *uuid.UUID     `gorm:"type:uuid;index" json:"batch_id"`
	Name        string         `gorm:"type:varchar(255);not null" json:"name" validate:"required,min=2,max=255"`
	Description string         `gorm:"type:text" json:"description"`
	Price       float64        `gorm:"type:decimal(15,2);not null" json:"price" validate:"required,gt=0"`
	Stock       int            `gorm:"not null;default:0" json:"stock"`
	ShrimpType  string         `gorm:"type:varchar(100)" json:"shrimp_type"`
	Size        string         `gorm:"type:varchar(50)" json:"size"`
	Unit        string         `gorm:"type:varchar(20);default:'kg'" json:"unit"`
	IsAvailable bool           `gorm:"default:true" json:"is_available"`
	RatingAvg   float64        `gorm:"type:decimal(3,2);default:0" json:"rating_avg"`
	RatingCount int            `gorm:"default:0" json:"rating_count"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
	User    User           `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Batch   *Batch         `gorm:"foreignKey:BatchID" json:"batch,omitempty"`
	Images  []ProductImage `gorm:"foreignKey:ProductID" json:"images,omitempty"`
	Reviews []Review       `gorm:"foreignKey:ProductID" json:"reviews,omitempty"`
}
func (p *Product) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}
type ProductImage struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key" json:"id"`
	ProductID uuid.UUID      `gorm:"type:uuid;not null;index" json:"product_id"`
	ImageURL  string         `gorm:"type:varchar(500);not null" json:"image_url"`
	IsPrimary bool           `gorm:"default:false" json:"is_primary"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
func (pi *ProductImage) BeforeCreate(tx *gorm.DB) error {
	if pi.ID == uuid.Nil {
		pi.ID = uuid.New()
	}
	return nil
}
