package model

import (
	"time"
)

type TrafficRecord struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	ForwardID uint      `json:"forward_id" gorm:"index;not null"`
	TunnelID  uint      `json:"tunnel_id" gorm:"index;not null"`
	UserID    uint      `json:"user_id" gorm:"index;not null"`
	NodeID    uint      `json:"node_id" gorm:"index;not null"`
	Upload    int64     `json:"upload" gorm:"default:0"`
	Download  int64     `json:"download" gorm:"default:0"`
	Timestamp time.Time `json:"timestamp" gorm:"index;not null"`
}

func (TrafficRecord) TableName() string {
	return "traffic_records"
}

type ServerStatus struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	NodeID     uint      `json:"node_id" gorm:"index;not null"`
	CPU        float64   `json:"cpu"`
	Memory     float64   `json:"memory"`
	Disk       float64   `json:"disk"`
	NetworkIn  int64     `json:"network_in"`
	NetworkOut int64     `json:"network_out"`
	Timestamp  time.Time `json:"timestamp" gorm:"index;not null"`
}

func (ServerStatus) TableName() string {
	return "server_status"
}

type NotificationLog struct {
	ID      uint      `json:"id" gorm:"primaryKey"`
	UserID  uint      `json:"user_id" gorm:"index;not null"`
	Type    string    `json:"type" gorm:"not null"`
	Message string    `json:"message" gorm:"not null"`
	SentAt  time.Time `json:"sent_at"`
	Status  string    `json:"status" gorm:"default:sent"`
	Error   string    `json:"error,omitempty"`
}

func (NotificationLog) TableName() string {
	return "notification_logs"
}
