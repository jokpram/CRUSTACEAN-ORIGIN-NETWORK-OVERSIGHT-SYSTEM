package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	AppName              string
	AppEnv               string
	AppPort              string
	DBHost               string
	DBPort               string
	DBUser               string
	DBPassword           string
	DBName               string
	JWTSecret            string
	UploadDir            string
	MaxFileSize          int64
	MidtransMerchantID   string
	MidtransClientKey    string
	MidtransServerKey    string
	MidtransIsProduction bool
}

var AppConfig *Config

func LoadConfig() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found, using environment variables")
	}
	maxFileSize, _ := strconv.ParseInt(getEnv("MAX_FILE_SIZE", "5242880"), 10, 64)
	midtransIsProd, _ := strconv.ParseBool(getEnv("MIDTRANS_IS_PRODUCTION", "false"))
	AppConfig = &Config{
		AppName:              getEnv("APP_NAME", "CRONOS"),
		AppEnv:               getEnv("APP_ENV", "development"),
		AppPort:              getEnv("APP_PORT", "8080"),
		DBHost:               getEnv("DB_HOST", "localhost"),
		DBPort:               getEnv("DB_PORT", "5433"),
		DBUser:               getEnv("DB_USER", "postgres"),
		DBPassword:           getEnv("DB_PASSWORD", ""),
		DBName:               getEnv("DB_NAME", "cronossuper_db"),
		JWTSecret:            getEnv("JWT_SECRET", "secret"),
		UploadDir:            getEnv("UPLOAD_DIR", "uploads"),
		MaxFileSize:          maxFileSize,
		MidtransMerchantID:   getEnv("MIDTRANS_MERCHANT_ID", ""),
		MidtransClientKey:    getEnv("MIDTRANS_CLIENT_KEY", ""),
		MidtransServerKey:    getEnv("MIDTRANS_SERVER_KEY", ""),
		MidtransIsProduction: midtransIsProd,
	}
}
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
