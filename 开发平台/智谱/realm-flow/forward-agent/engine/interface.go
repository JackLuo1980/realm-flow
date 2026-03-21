package engine

// ForwardEngine 转发引擎接口
type ForwardEngine interface {
	// Start 启动引擎
	Start() error
	// Stop 停止引擎
	Stop() error
	// Reload 重新加载配置
	Reload() error
	// GetStats 获取统计信息
	GetStats() (map[string]interface{}, error)
	// AddRule 添加转发规则
	AddRule(rule ForwardRule) error
	// RemoveRule 删除转发规则
	RemoveRule(id uint) error
	// Validate 验证配置
	Validate() error
}
