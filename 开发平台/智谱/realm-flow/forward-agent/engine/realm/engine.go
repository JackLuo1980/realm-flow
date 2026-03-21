package realm

import (
	"fmt"
	"forward-agent/engine"
	"os"
	"os/exec"
	"path/filepath"
)

// Engine realm 引擎
type Engine struct {
	rules   map[uint]engine.ForwardRule
	config  string
	process *os.Process
}

// NewEngine 创建 realm 引擎
func NewEngine() *Engine {
	return &Engine{
		rules:  make(map[uint]engine.ForwardRule),
		config: "/etc/realm/config.toml",
	}
}

// Start 启动引擎
func (e *Engine) Start() error {
	// 生成配置文件
	if err := e.generateConfig(); err != nil {
		return err
	}

	// 启动 realm 进程
	cmd := exec.Command("realm", "-c", e.config)
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start realm: %v", err)
	}

	e.process = cmd.Process
	return nil
}

// Stop 停止引擎
func (e *Engine) Stop() error {
	if e.process != nil {
		e.process.Kill()
		e.process = nil
	}
	return nil
}

// Reload 重新加载配置
func (e *Engine) Reload() error {
	// 生成新配置
	if err := e.generateConfig(); err != nil {
		return err
	}

	// realm 不支持热重载，需要重启
	if err := e.Stop(); err != nil {
		return err
	}
	return e.Start()
}

// GetStats 获取统计信息
func (e *Engine) GetStats() (map[string]interface{}, error) {
	stats := make(map[string]interface{})
	stats["type"] = "realm"
	stats["rules_count"] = len(e.rules)
	stats["running"] = e.process != nil
	return stats, nil
}

// AddRule 添加转发规则
func (e *Engine) AddRule(rule engine.ForwardRule) error {
	e.rules[rule.ID] = rule
	return e.Reload()
}

// RemoveRule 删除转发规则
func (e *Engine) RemoveRule(id uint) error {
	delete(e.rules, id)
	return e.Reload()
}

// Validate 验证配置
func (e *Engine) Validate() error {
	cmd := exec.Command("realm", "--version")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("realm not available")
	}
	return nil
}

// generateConfig 生成 realm 配置文件
func (e *Engine) generateConfig() error {
	// 确保配置目录存在
	dir := filepath.Dir(e.config)
	os.MkdirAll(dir, 0755)

	// 生成 TOML 配置
	content := "[network]\n"
	content += "use_udp = true\n\n"

	for _, rule := range e.rules {
		content += fmt.Sprintf("[[endpoints]]\n")
		content += fmt.Sprintf("listen = \"%s:%d\"\n", rule.ListenIP, rule.ListenPort)
		content += fmt.Sprintf("remote = \"%s:%d\"\n\n", rule.TargetAddr, rule.TargetPort)
	}

	return os.WriteFile(e.config, []byte(content), 0644)
}
