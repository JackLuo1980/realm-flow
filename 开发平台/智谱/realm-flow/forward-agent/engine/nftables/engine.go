package nftables

import (
	"fmt"
	"forward-agent/engine"
	"os/exec"
)

// Engine nftables 引擎
type Engine struct {
	rules map[uint]engine.ForwardRule
}

// NewEngine 创建 nftables 引擎
func NewEngine() *Engine {
	return &Engine{
		rules: make(map[uint]engine.ForwardRule),
	}
}

// Start 启动引擎
func (e *Engine) Start() error {
	// 初始化 nftables 表
	cmd := exec.Command("nft", "add", "table", "inet", "realmflow")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to create nftables table: %v", err)
	}
	return nil
}

// Stop 停止引擎
func (e *Engine) Stop() error {
	// 删除 nftables 表
	cmd := exec.Command("nft", "delete", "table", "inet", "realmflow")
	cmd.Run() // 忽略错误
	return nil
}

// Reload 重新加载配置
func (e *Engine) Reload() error {
	if err := e.Stop(); err != nil {
		return err
	}
	return e.Start()
}

// GetStats 获取统计信息
func (e *Engine) GetStats() (map[string]interface{}, error) {
	// 读取 nftables counter
	stats := make(map[string]interface{})
	stats["type"] = "nftables"
	stats["rules_count"] = len(e.rules)
	return stats, nil
}

// AddRule 添加转发规则
func (e *Engine) AddRule(rule engine.ForwardRule) error {
	// 添加 nftables 规则
	chain := fmt.Sprintf("prerouting_%s", rule.Protocol)

	// 创建链（如果不存在）
	exec.Command("nft", "add", "chain", "inet", "realmflow", chain,
		"{", "type", "nat", "hook", "prerouting", "priority", "0", ";", "}").Run()

	// 添加 DNAT 规则
	cmd := exec.Command("nft", "add", "rule", "inet", "realmflow", chain,
		"ip", "daddr", rule.ListenIP, rule.Protocol, "dport", fmt.Sprintf("%d", rule.ListenPort),
		"dnat", "to", fmt.Sprintf("%s:%d", rule.TargetAddr, rule.TargetPort))

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to add nftables rule: %v", err)
	}

	e.rules[rule.ID] = rule
	return nil
}

// RemoveRule 删除转发规则
func (e *Engine) RemoveRule(id uint) error {
	// 删除 nftables 规则
	delete(e.rules, id)
	return nil
}

// Validate 验证配置
func (e *Engine) Validate() error {
	// 检查 nftables 是否可用
	cmd := exec.Command("nft", "--version")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("nftables not available")
	}
	return nil
}
