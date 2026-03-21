package database

import (
	"fmt"
	"realm-flow/pkg/config"

	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func Init(cfg config.DatabaseConfig) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	opts := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	}

	switch cfg.Driver {
	case "postgres":
		dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
			cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName, cfg.SSLMode)
		db, err = gorm.Open(postgres.Open(dsn), opts)
	case "sqlite":
		db, err = gorm.Open(sqlite.Open(cfg.DBName), opts)
	default:
		db, err = gorm.Open(sqlite.Open("realm-flow.db"), opts)
	}

	if err != nil {
		return nil, err
	}

	return db, nil
}
