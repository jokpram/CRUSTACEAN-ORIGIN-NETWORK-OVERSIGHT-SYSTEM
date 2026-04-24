//go:build ignore

package main

import (
	"cronos-backend/models"
	"cronos-backend/utils"
	"fmt"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	dsn := "host=localhost user=postgres password=joko1453 dbname=crony port=5433 sslmode=disable TimeZone=Asia/Jakarta"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}
	var admin models.User
	if err := db.Where("role = ?", "admin").First(&admin).Error; err != nil {
		fmt.Println("No admin found:", err)
		return
	}
	hashed, _ := utils.HashPassword("password")
	admin.Password = hashed
	db.Save(&admin)
	fmt.Println("Admin password reset to 'password'")
}
