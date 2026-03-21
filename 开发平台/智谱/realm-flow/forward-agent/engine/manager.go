package engine

import (
	"fmt"
)

// Manager 引擎管理器
type Manager struct {
	engines map[EngineType]ForwardEngine
	active  EngineType
}

// NewManager 创建引擎管理器
func NewManager() *Manager {
	return &Manager{
		engines: make(map[EngineType]ForwardEngine),
		active:  EngineNftables,
	}
}

// RegisterEngine 注册引擎
func (m *Manager) RegisterEngine(engineType EngineType, engine ForwardEngine) {
	m.engines[engineType] = engine
}

// SetActiveEngine 设置活动引擎
func (m *Manager) SetActiveEngine(engineType EngineType) error {
	if _, exists := m.engines[engineType]; !exists {
		return fmt.Errorf("engine %s not registered", engineType)
	}
	m.active = engineType
	return nil
}

// GetActiveEngine 获取活动引擎
func (m *Manager) GetActiveEngine() ForwardEngine {
	return m.engines[m.active]
}

// GetEngine 获取指定引擎
func (m *Manager) GetEngine(engineType EngineType) (ForwardEngine, error) {
	engine, exists := m.engines[engineType]
	if !exists {
		return nil, fmt.Errorf("engine %s not found", engineType)
	}
	return engine, nil
}

// StartAll 启动所有引擎
func (m *Manager) StartAll() error {
	for _, engine := range m.engines {
		if err := engine.Start(); err != nil {
			return err
		}
	}
	return nil
}

// StopAll 停止所有引擎
func (m *Manager) StopAll() error {
	for _, engine := range m.engines {
		if err := engine.Stop(); err != nil {
			return err
		}
	}
	return nil
}
