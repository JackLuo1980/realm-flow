package model

import "time"

type User struct {
	ID           uint         `json:"id" gorm:"primaryKey"`
	Username     string       `json:"username" gorm:"uniqueIndex;size:128;not null"`
	PasswordHash string       `json:"-" gorm:"size:255;not null"`
	TelegramID   string       `json:"telegram_id" gorm:"size:128"`
	Role         string       `json:"role" gorm:"size:32;not null;default:user"`
	Quota        int64        `json:"quota" gorm:"not null;default:0"`
	UsedTraffic  int64        `json:"used_traffic" gorm:"not null;default:0"`
	NotifyConfig NotifyConfig `json:"notify_config" gorm:"serializer:json"`
	Status       string       `json:"status" gorm:"size:32;not null;default:active"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}

type NotifyConfig struct {
	Enabled          bool     `json:"enabled"`
	Events           []string `json:"events"`
	TrafficThreshold int      `json:"traffic_threshold"`
}

type Node struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" gorm:"uniqueIndex;size:128;not null"`
	Host      string    `json:"host" gorm:"size:255;not null"`
	Port      int       `json:"port" gorm:"not null"`
	APIKey    string    `json:"api_key" gorm:"size:255"`
	Status    string    `json:"status" gorm:"size:32;not null;default:offline"`
	LastSeen  time.Time `json:"last_seen"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Tunnel struct {
	ID            uint      `json:"id" gorm:"primaryKey"`
	UserID        uint      `json:"user_id" gorm:"index;not null"`
	NodeID        uint      `json:"node_id" gorm:"index;not null"`
	Name          string    `json:"name" gorm:"uniqueIndex;size:128;not null"`
	RemoteAddr    string    `json:"remote_addr" gorm:"size:255;not null"`
	RemotePort    int       `json:"remote_port" gorm:"not null"`
	Quota         int64     `json:"quota" gorm:"not null;default:0"`
	UsedTraffic   int64     `json:"used_traffic" gorm:"not null;default:0"`
	DefaultEngine string    `json:"default_engine" gorm:"size:32;not null;default:gost"`
	Status        string    `json:"status" gorm:"size:32;not null;default:active"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type Forward struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	TunnelID   uint      `json:"tunnel_id" gorm:"index;not null"`
	Name       string    `json:"name" gorm:"uniqueIndex;size:128;not null"`
	ListenPort int       `json:"listen_port" gorm:"not null"`
	ListenIP   string    `json:"listen_ip" gorm:"size:64;not null;default:0.0.0.0"`
	TargetAddr string    `json:"target_addr" gorm:"size:255;not null"`
	TargetPort int       `json:"target_port" gorm:"not null"`
	Protocol   string    `json:"protocol" gorm:"size:16;not null;default:tcp"`
	Engine     string    `json:"engine" gorm:"size:32;not null;default:gost"`
	Enabled    bool      `json:"enabled" gorm:"not null;default:true"`
	Status     string    `json:"status" gorm:"size:32;not null;default:stopped"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}
