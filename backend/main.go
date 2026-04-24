package main

import (
	"cronos-backend/config"
	"cronos-backend/middleware"
	"cronos-backend/routes"
	"cronos-backend/utils"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	config.LoadConfig()
	utils.JWTSecret = config.AppConfig.JWTSecret
	config.ConnectDatabase()
	if err := os.MkdirAll(config.AppConfig.UploadDir, os.ModePerm); err != nil {
		log.Printf("Warning: Could not create upload directory: %v", err)
	}
	if config.AppConfig.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}
	r := gin.Default()
	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.RateLimitMiddleware())
	r.Static("/uploads", "./"+config.AppConfig.UploadDir)
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"name":    config.AppConfig.AppName,
			"version": "1.0.0",
			"status":  "running",
			"message": "CRONOS - Crustacean Origin Network Oversight System",
		})
	})
	routes.SetupRoutes(r, config.DB)
	port := config.AppConfig.AppPort
	log.Printf(" %s server starting on port %s", config.AppConfig.AppName, port)
	if err := r.Run(fmt.Sprintf(":%s", port)); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
