package engine

// ForwardRule 转发规则
type ForwardRule struct {
	ID         uint   `json:"id"`
	ListenIP   string `json:"listen_ip"`
	ListenPort int    `json:"listen_port"`
	TargetAddr string `json:"target_addr"`
	TargetPort int    `json:"target_port"`
	Protocol   string `json:"protocol"`
}

// EngineType 引擎类型
type EngineType string

const (
	EngineNftables EngineType = "nftables"
	EngineRealm    EngineType = "realm"
)
