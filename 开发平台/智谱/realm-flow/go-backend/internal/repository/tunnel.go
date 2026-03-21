package repository

import (
	"realm-flow/internal/model"

	"gorm.io/gorm"
)

type TunnelRepository struct {
	db *gorm.DB
}

func NewTunnelRepository(db *gorm.DB) *TunnelRepository {
	return &TunnelRepository{db: db}
}

func (r *TunnelRepository) Create(tunnel *model.Tunnel) error {
	return r.db.Create(tunnel).Error
}

func (r *TunnelRepository) GetByID(id uint) (*model.Tunnel, error) {
	var tunnel model.Tunnel
	err := r.db.Preload("User").Preload("Node").First(&tunnel, id).Error
	if err != nil {
		return nil, err
	}
	return &tunnel, nil
}

func (r *TunnelRepository) ListByUser(userID uint, page, pageSize int) ([]model.Tunnel, int64, error) {
	var tunnels []model.Tunnel
	var total int64

	query := r.db.Model(&model.Tunnel{}).Where("user_id = ?", userID)
	query.Count(&total)
	err := query.Preload("Node").Offset((page - 1) * pageSize).Limit(pageSize).Find(&tunnels).Error
	return tunnels, total, err
}

func (r *TunnelRepository) ListAll(page, pageSize int) ([]model.Tunnel, int64, error) {
	var tunnels []model.Tunnel
	var total int64

	r.db.Model(&model.Tunnel{}).Count(&total)
	err := r.db.Preload("User").Preload("Node").Offset((page - 1) * pageSize).Limit(pageSize).Find(&tunnels).Error
	return tunnels, total, err
}

func (r *TunnelRepository) Update(tunnel *model.Tunnel) error {
	return r.db.Save(tunnel).Error
}

func (r *TunnelRepository) Delete(id uint) error {
	return r.db.Delete(&model.Tunnel{}, id).Error
}

func (r *TunnelRepository) GetByNodeID(nodeID uint) ([]model.Tunnel, error) {
	var tunnels []model.Tunnel
	err := r.db.Where("node_id = ?", nodeID).Find(&tunnels).Error
	return tunnels, err
}

func (r *TunnelRepository) GetDB() *gorm.DB {
	return r.db
}
