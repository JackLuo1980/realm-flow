package repository

import (
	"realm-flow/internal/model"
	"realm-flow/pkg/utils"

	"gorm.io/gorm"
)

type NodeRepository struct {
	db *gorm.DB
}

func NewNodeRepository(db *gorm.DB) *NodeRepository {
	return &NodeRepository{db: db}
}

func (r *NodeRepository) Create(node *model.Node) error {
	if node.APIKey == "" {
		node.APIKey = utils.GenerateAPIKey()
	}
	return r.db.Create(node).Error
}

func (r *NodeRepository) GetByID(id uint) (*model.Node, error) {
	var node model.Node
	err := r.db.First(&node, id).Error
	if err != nil {
		return nil, err
	}
	return &node, nil
}

func (r *NodeRepository) GetByAPIKey(apiKey string) (*model.Node, error) {
	var node model.Node
	err := r.db.Where("api_key = ?", apiKey).First(&node).Error
	if err != nil {
		return nil, err
	}
	return &node, nil
}

func (r *NodeRepository) List(page, pageSize int) ([]model.Node, int64, error) {
	var nodes []model.Node
	var total int64

	r.db.Model(&model.Node{}).Count(&total)
	err := r.db.Offset((page - 1) * pageSize).Limit(pageSize).Find(&nodes).Error
	return nodes, total, err
}

func (r *NodeRepository) Update(node *model.Node) error {
	return r.db.Save(node).Error
}

func (r *NodeRepository) Delete(id uint) error {
	return r.db.Delete(&model.Node{}, id).Error
}

func (r *NodeRepository) UpdateStatus(id uint, status string) error {
	return r.db.Model(&model.Node{}).Where("id = ?", id).Update("status", status).Error
}

func (r *NodeRepository) GetDB() *gorm.DB {
	return r.db
}
