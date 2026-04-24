package controllers

import (
	"cronos-backend/config"
	"cronos-backend/models"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Client struct {
	ID    string
	Conn  *websocket.Conn
	Rooms []string
	mu    sync.Mutex
}

type Hub struct {
	clients map[string]*Client
	mu      sync.RWMutex
}

var ChatHub = &Hub{
	clients: make(map[string]*Client),
}

func (h *Hub) AddClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.clients[client.ID] = client
}

func (h *Hub) RemoveClient(id string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if client, ok := h.clients[id]; ok {
		client.Conn.Close()
		delete(h.clients, id)
	}
}

func (h *Hub) BroadcastToRoom(roomID string, message interface{}) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for _, client := range h.clients {
		for _, rID := range client.Rooms {
			if rID == roomID {
				client.mu.Lock()
				client.Conn.WriteJSON(message)
				client.mu.Unlock()
				break
			}
		}
	}
}

func HandleWebSocket(c *gin.Context) {
	userID := c.Query("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to upgrade to WebSocket: %v", err)
		return
	}

	client := &Client{
		ID:   userID,
		Conn: conn,
	}

	ChatHub.AddClient(client)

	// Auto-join all rooms for this user
	var userRooms []string
	config.DB.Table("chat_room_members").Where("user_id = ?", userID).Pluck("chat_room_id", &userRooms)
	client.mu.Lock()
	client.Rooms = userRooms
	client.mu.Unlock()

	defer func() {
		ChatHub.RemoveClient(userID)
		// services.SetUserOffline(userID) - Removed Redis
	}()

	for {
		var msg struct {
			Type    string `json:"type"`
			RoomID  string `json:"room_id"`
			Content string `json:"content"`
		}

		err := conn.ReadJSON(&msg)
		if err != nil {
			break
		}

		switch msg.Type {
		case "join":
			client.mu.Lock()
			found := false
			for _, r := range client.Rooms {
				if r == msg.RoomID {
					found = true
					break
				}
			}
			if !found {
				client.Rooms = append(client.Rooms, msg.RoomID)
				// services.SubscribeToRoom - Removed RabbitMQ
			}
			client.mu.Unlock()

		case "message":
			roomUUID, _ := uuid.Parse(msg.RoomID)
			senderUUID, _ := uuid.Parse(userID)

			chatMsg := models.ChatMessage{
				ID:        uuid.New(),
				RoomID:    roomUUID,
				SenderID:  senderUUID,
				Content:   msg.Content,
				CreatedAt: time.Now(),
			}

			if err := config.DB.Create(&chatMsg).Error; err != nil {
				log.Printf("Failed to save message: %v", err)
			}

			// Broadcast directly via Hub (In-Memory)
			ChatHub.BroadcastToRoom(msg.RoomID, chatMsg)
		}
	}
}

func GetRooms(c *gin.Context) {
	userID := c.Param("user_id")
	var rooms []models.ChatRoom

	err := config.DB.Preload("Members").
		Joins("JOIN chat_room_members ON chat_room_members.chat_room_id = chat_rooms.id").
		Where("chat_room_members.user_id = ?", userID).
		Find(&rooms).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": rooms})
}

func GetMessages(c *gin.Context) {
	roomID := c.Param("room_id")
	var messages []models.ChatMessage

	err := config.DB.Preload("Sender").Where("room_id = ?", roomID).Order("created_at asc").Limit(50).Find(&messages).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": messages, "source": "db"})
}

func CreateRoom(c *gin.Context) {
	var input struct {
		Name    string   `json:"name"`
		Type    string   `json:"type"`
		UserIDs []string `json:"user_ids"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// For private chats, check if a room already exists between these users
	if input.Type == "private" && len(input.UserIDs) == 2 {
		var existingRoom models.ChatRoom
		err := config.DB.Joins("JOIN chat_room_members cm1 ON cm1.chat_room_id = chat_rooms.id").
			Joins("JOIN chat_room_members cm2 ON cm2.chat_room_id = chat_rooms.id").
			Where("chat_rooms.type = ?", "private").
			Where("cm1.user_id = ? AND cm2.user_id = ?", input.UserIDs[0], input.UserIDs[1]).
			Preload("Members").
			First(&existingRoom).Error

		if err == nil {
			c.JSON(http.StatusOK, gin.H{"data": existingRoom})
			return
		}
	}

	room := models.ChatRoom{
		ID:   uuid.New(),
		Name: input.Name,
		Type: input.Type,
	}

	for _, uID := range input.UserIDs {
		var user models.User
		if err := config.DB.Where("id = ?", uID).First(&user).Error; err == nil {
			room.Members = append(room.Members, user)
		}
	}

	if err := config.DB.Create(&room).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create room"})
		return
	}

	// Update online clients synchronously
	ChatHub.mu.RLock()
	for _, uID := range input.UserIDs {
		if onlineClient, ok := ChatHub.clients[uID]; ok {
			onlineClient.mu.Lock()
			onlineClient.Rooms = append(onlineClient.Rooms, room.ID.String())
			onlineClient.mu.Unlock()
		}
	}
	ChatHub.mu.RUnlock()

	c.JSON(http.StatusCreated, gin.H{"data": room})
}

func GetChatUsers(c *gin.Context) {
	var users []models.User
	if err := config.DB.Select("id, name, role, email").Where("role != ?", "admin").Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": users})
}
