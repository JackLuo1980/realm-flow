package repository

import (
	"realm-flow/internal/model"
	"time"

	"gorm.io/gorm"
)

type TrafficRepository struct {
	db *gorm.DB
}

func NewTrafficRepository(db *gorm.DB) *TrafficRepository {
	return &TrafficRepository{db: db}
}

func (r *TrafficRepository) Create(record *model.TrafficRecord) error {
	return r.db.Create(record).Error
}

func (r *TrafficRepository) CreateBatch(records []model.TrafficRecord) error {
	return r.db.CreateInBatches(records, 100).Error
}

func (r *TrafficRepository) GetUserTraffic(userID uint, from, to time.Time) (int64, int64, error) {
	var result struct {
		Upload   int64
		Download int64
	}
	err := r.db.Model(&model.TrafficRecord{}).
		Where("user_id = ? AND timestamp BETWEEN ? AND ?", userID, from, to).
		Select("COALESCE(SUM(upload), 0) as upload, COALESCE(SUM(download), 0) as download").
		Scan(&result).Error
	return result.Upload, result.Download, err
}

func (r *TrafficRepository) GetNodeTraffic(nodeID uint, from, to time.Time) (int64, int64, error) {
	var result struct {
		Upload   int64
		Download int64
	}
	err := r.db.Model(&model.TrafficRecord{}).
		Where("node_id = ? AND timestamp BETWEEN ? AND ?", nodeID, from, to).
		Select("COALESCE(SUM(upload), 0) as upload, COALESCE(SUM(download), 0) as download").
		Scan(&result).Error
	return result.Upload, result.Download, err
}

func (r *TrafficRepository) GetTunnelTraffic(tunnelID uint, from, to time.Time) (int64, int64, error) {
	var result struct {
		Upload   int64
		Download int64
	}
	err := r.db.Model(&model.TrafficRecord{}).
		Where("tunnel_id = ? AND timestamp BETWEEN ? AND ?", tunnelID, from, to).
		Select("COALESCE(SUM(upload), 0) as upload, COALESCE(SUM(download), 0) as download").
		Scan(&result).Error
	return result.Upload, result.Download, err
}

func (r *TrafficRepository) GetForwardTraffic(forwardID uint, from, to time.Time) (int64, int64, error) {
	var result struct {
		Upload   int64
		Download int64
	}
	err := r.db.Model(&model.TrafficRecord{}).
		Where("forward_id = ? AND timestamp BETWEEN ? AND ?", forwardID, from, to).
		Select("COALESCE(SUM(upload), 0) as upload, COALESCE(SUM(download), 0) as download").
		Scan(&result).Error
	return result.Upload, result.Download, err
}

func (r *TrafficRepository) SaveServerStatus(status *model.ServerStatus) error {
	return r.db.Create(status).Error
}

func (r *TrafficRepository) GetDB() *gorm.DB {
	return r.db
}
