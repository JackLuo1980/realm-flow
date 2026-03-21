package db

import (
	"fmt"
	"strings"

	"github.com/JackLuo1980/realm-flow/go-backend/internal/config"
	"github.com/JackLuo1980/realm-flow/go-backend/internal/model"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func Open(cfg config.Config) (*gorm.DB, error) {
	switch cfg.DBDriver() {
	case "postgres":
		return gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{})
	default:
		dsn := cfg.DatabaseURL
		if strings.TrimSpace(dsn) == "" {
			dsn = "file:realmflow.db?_foreign_keys=on"
		}
		return gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	}
}

func AutoMigrate(database *gorm.DB) error {
	if database == nil {
		return fmt.Errorf("database is nil")
	}
	return database.AutoMigrate(
		&model.User{},
		&model.Node{},
		&model.Tunnel{},
		&model.Forward{},
	)
}
