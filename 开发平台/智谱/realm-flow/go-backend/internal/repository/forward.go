package repository

import (
	"realm-flow/internal/model"

	"gorm.io/gorm"
)

type ForwardRepository struct {
	db *gorm.DB
}

func NewForwardRepository(db *gorm.DB) *ForwardRepository {
	return &ForwardRepository{db: db}
}

func (r *ForwardRepository) Create(forward *model.Forward) error {
	return r.db.Create(forward).Error
}

func (r *ForwardRepository) GetByID(id uint) (*model.Forward, error) {
	var forward model.Forward
	err := r.db.Preload("Tunnel").First(&forward, id).Error
	if err != nil {
		return nil, err
	}
	return &forward, nil
}

func (r *ForwardRepository) ListByTunnel(tunnelID uint) ([]model.Forward, error) {
	var forwards []model.Forward
	err := r.db.Where("tunnel_id = ?", tunnelID).Find(&forwards).Error
	return forwards, err
}

func (r *ForwardRepository) ListAll(page, pageSize int) ([]model.Forward, int64, error) {
	var forwards []model.Forward
	var total int64

	r.db.Model(&model.Forward{}).Count(&total)
	err := r.db.Preload("Tunnel").Offset((page - 1) * pageSize).Limit(pageSize).Find(&forwards).Error
	return forwards, total, err
}

func (r *ForwardRepository) Update(forward *model.Forward) error {
	return r.db.Save(forward).Error
}

func (r *ForwardRepository) Delete(id uint) error {
	return r.db.Delete(&model.Forward{}, id).Error
}

func (r *ForwardRepository) UpdateStatus(id uint, status string) error {
	return r.db.Model(&model.Forward{}).Where("id = ?", id).Update("status", status).Error
}

func (r *ForwardRepository) BatchUpdateStatus(ids []uint, status string) error {
	return r.db.Model(&model.Forward{}).Where("id IN ?", ids).Update("status", status).Error
}

func (r *ForwardRepository) BatchDelete(ids []uint) error {
	return r.db.Where("id IN ?", ids).Delete(&model.Forward{}).Error
}

func (r *ForwardRepository) GetDB() *gorm.DB {
	return r.db
}
