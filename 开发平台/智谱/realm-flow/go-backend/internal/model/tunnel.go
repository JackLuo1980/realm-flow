package model

import (
	"time"

	"gorm.io/gorm"
)

type Tunnel struct {
	ID            uint           `json:"id" gorm:"primaryKey"`
	UserID        uint           `json:"user_id" gorm:"index;not null"`
	NodeID        uint           `json:"node_id" gorm:"index;not null"`
	Name          string         `json:"name" gorm:"not null"`
	RemoteAddr    string         `json:"remote_addr"`
	RemotePort    int            `json:"remote_port"`
	Quota         int64          `json:"quota" gorm:"default:0"`
	UsedTraffic   int64          `json:"used_traffic" gorm:"default:0"`
	DefaultEngine string         `json:"default_engine" gorm:"default:nftables"`
	Status        string         `json:"status" gorm:"default:active"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	User User `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Node Node `json:"node,omitempty" gorm:"foreignKey:NodeID"`
}

func (Tunnel) TableName() string {
	return "tunnels"
}
