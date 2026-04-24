package config

import (
	"cronos-backend/models"
	"cronos-backend/utils"
	"fmt"
	"log"

	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func ConnectDatabase() {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		AppConfig.DBHost,
		AppConfig.DBUser,
		AppConfig.DBPassword,
		AppConfig.DBName,
		AppConfig.DBPort,
	)
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	log.Println("Database connected successfully")
	err = DB.AutoMigrate(
		&models.User{},
		&models.Farm{},
		&models.Pond{},
		&models.ShrimpType{},
		&models.CultivationCycle{},
		&models.FeedLog{},
		&models.WaterQualityLog{},
		&models.Harvest{},
		&models.Batch{},
		&models.Product{},
		&models.ProductImage{},
		&models.Order{},
		&models.OrderItem{},
		&models.Payment{},
		&models.MidtransTransaction{},
		&models.Shipment{},
		&models.ShipmentLog{},
		&models.TraceabilityLog{},
		&models.Withdrawal{},
		&models.Review{},
		&models.ChatRoom{},
		&models.ChatMessage{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}
	log.Println("Database migrated successfully")
	seedAdmin()
}
func seedAdmin() {
	var count int64
	DB.Model(&models.User{}).Where("role = ?", "admin").Count(&count)
	if count > 0 {
		log.Println("Admin user already exists, skipping seed")
		return
	}
	hashedPassword, err := utils.HashPassword("Admin@123")
	if err != nil {
		log.Fatal("Failed to hash admin password:", err)
	}
	admin := models.User{
		ID:         uuid.New(),
		Name:       "Admin CRONOS",
		Email:      "admin@cronos.id",
		Password:   hashedPassword,
		Phone:      "081234567890",
		Role:       "admin",
		IsVerified: true,
	}
	if err := DB.Create(&admin).Error; err != nil {
		log.Fatal("Failed to seed admin user:", err)
	}
	log.Println("Admin user seeded successfully: admin@cronos.id / Admin@123")
}
