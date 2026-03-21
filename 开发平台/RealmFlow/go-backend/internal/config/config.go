package config

import (
	"fmt"
	"os"
	"strings"
	"time"
)

type Config struct {
	Env         string
	HTTPPort    string
	DatabaseURL string
	JWTSecret   string
	JWTIssuer   string
	TokenTTL    time.Duration
	CORSOrigins []string
}

func Load() Config {
	return Config{
		Env:         getenv("APP_ENV", "development"),
		HTTPPort:    getenv("HTTP_PORT", "6365"),
		DatabaseURL: getenv("DATABASE_URL", "file:realmflow.db?_foreign_keys=on"),
		JWTSecret:   getenv("JWT_SECRET", "realmflow-development-secret"),
		JWTIssuer:   getenv("JWT_ISSUER", "realmflow"),
		TokenTTL:    24 * time.Hour,
		CORSOrigins: parseList(getenv("CORS_ORIGINS", "*")),
	}
}

func (c Config) Address() string {
	return fmt.Sprintf(":%s", c.HTTPPort)
}

func (c Config) DBDriver() string {
	if strings.HasPrefix(c.DatabaseURL, "postgres://") || strings.HasPrefix(c.DatabaseURL, "postgresql://") {
		return "postgres"
	}
	return "sqlite"
}

func getenv(key, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func parseList(value string) []string {
	if strings.TrimSpace(value) == "" {
		return []string{"*"}
	}

	parts := strings.Split(value, ",")
	result := make([]string, 0, len(parts))
	for _, part := range parts {
		item := strings.TrimSpace(part)
		if item != "" {
			result = append(result, item)
		}
	}
	if len(result) == 0 {
		return []string{"*"}
	}
	return result
}
