package model

import (
	"time"

	"gorm.io/gorm"
)

type Forward struct {
	ID         uint           `json:"id" gorm:"primaryKey"`
	TunnelID   uint           `json:"tunnel_id" gorm:"index;not null"`
	Name       string         `json:"name"`
	ListenPort int            `json:"listen_port" gorm:"not null"`
	ListenIP   string         `json:"listen_ip" gorm:"default:0.0.0.0"`
	TargetAddr string         `json:"target_addr" gorm:"not null"`
	TargetPort int            `json:"target_port" gorm:"not null"`
	Protocol   string         `json:"protocol" gorm:"default:tcp"`
	Engine     string         `json:"engine" gorm:"default:nftables"`
	Enabled    bool           `json:"enabled" gorm:"default:true"`
	Status     string         `json:"status" gorm:"default:stopped"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	Tunnel Tunnel `json:"tunnel,omitempty" gorm:"foreignKey:TunnelID"`
}

func (Forward) TableName() string {
	return "forwards"
}
