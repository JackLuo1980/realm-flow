package model

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	Username     string         `json:"username" gorm:"uniqueIndex;not null"`
	PasswordHash string         `json:"-" gorm:"not null"`
	TelegramID   string         `json:"telegram_id"`
	Role         string         `json:"role" gorm:"default:user"`
	Quota        int64          `json:"quota" gorm:"default:0"`
	UsedTraffic  int64          `json:"used_traffic" gorm:"default:0"`
	NotifyConfig NotifyConfig   `json:"notify_config" gorm:"embedded"`
	Status       string         `json:"status" gorm:"default:active"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

type NotifyConfig struct {
	Enabled          bool     `json:"enabled" gorm:"default:false"`
	Events           []string `json:"events" gorm:"serializer:json"`
	TrafficThreshold int      `json:"traffic_threshold" gorm:"default:80"`
}

func (User) TableName() string {
	return "users"
}
