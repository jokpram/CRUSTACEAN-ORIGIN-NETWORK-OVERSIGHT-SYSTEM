package models

import (
	"time"

	"github.com/google/uuid"
)

type ChatRoom struct {
	ID        uuid.UUID     `gorm:"type:uuid;primaryKey" json:"id"`
	Type      string        `gorm:"type:varchar(20);not null" json:"type"` // "private", "group"
	Name      string        `gorm:"type:varchar(100)" json:"name"`
	CreatedAt time.Time     `json:"created_at"`
	UpdatedAt time.Time     `json:"updated_at"`
	Members   []User        `gorm:"many2many:chat_room_members;" json:"members"`
	Messages  []ChatMessage `gorm:"foreignKey:RoomID" json:"messages"`
}

type ChatMessage struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	RoomID    uuid.UUID `gorm:"type:uuid;not null;index" json:"room_id"`
	SenderID  uuid.UUID `gorm:"type:uuid;not null;index" json:"sender_id"`
	Content   string    `gorm:"type:text;not null" json:"content"`
	Type      string    `gorm:"type:varchar(20);default:'text'" json:"type"` // "text", "image", "file"
	IsRead    bool      `gorm:"default:false" json:"is_read"`
	CreatedAt time.Time `json:"created_at"`
	Sender    User      `gorm:"foreignKey:SenderID" json:"sender"`
}
