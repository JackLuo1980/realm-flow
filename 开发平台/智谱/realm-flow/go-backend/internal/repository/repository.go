package repository

import "gorm.io/gorm"

type Repositories struct {
	User    *UserRepository
	Node    *NodeRepository
	Tunnel  *TunnelRepository
	Forward *ForwardRepository
	Traffic *TrafficRepository
}

func NewRepositories(db *gorm.DB) *Repositories {
	return &Repositories{
		User:    NewUserRepository(db),
		Node:    NewNodeRepository(db),
		Tunnel:  NewTunnelRepository(db),
		Forward: NewForwardRepository(db),
		Traffic: NewTrafficRepository(db),
	}
}
