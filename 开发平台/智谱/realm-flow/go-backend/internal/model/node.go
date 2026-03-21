package model

import (
	"time"

	"gorm.io/gorm"
)

type Node struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Name      string         `json:"name" gorm:"uniqueIndex;not null"`
	Host      string         `json:"host" gorm:"not null"`
	Port      int            `json:"port" gorm:"default:6365"`
	APIKey    string         `json:"api_key" gorm:"uniqueIndex;not null"`
	Status    string         `json:"status" gorm:"default:offline"`
	LastSeen  time.Time      `json:"last_seen"`
	Version   string         `json:"version"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

func (Node) TableName() string {
	return "nodes"
}
