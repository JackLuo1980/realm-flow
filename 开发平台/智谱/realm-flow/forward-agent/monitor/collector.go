package monitor

import (
	"context"
	"time"
)

type SystemMetrics struct {
	CPUUsage    float64        `json:"cpu_usage"`
	MemoryUsage float64        `json:"memory_usage"`
	Network     NetworkMetrics `json:"network"`
	LoadAvg     []float64      `json:"load_avg"`
	Timestamp   time.Time      `json:"timestamp"`
}

type NetworkMetrics struct {
	BytesSent   uint64 `json:"bytes_sent"`
	BytesRecv   uint64 `json:"bytes_recv"`
	PacketsSent uint64 `json:"packets_sent"`
	PacketsRecv uint64 `json:"packets_recv"`
}

type TrafficMetrics struct {
	TunnelID  uint      `json:"tunnel_id"`
	ForwardID uint      `json:"forward_id"`
	Upload    uint64    `json:"upload"`
	Download  uint64    `json:"download"`
	Timestamp time.Time `json:"timestamp"`
}

type Collector struct {
	ctx              context.Context
	cancel           context.CancelFunc
	interval         time.Duration
	onSystemMetrics  func(SystemMetrics)
	onTrafficMetrics func(TrafficMetrics)
}

func NewCollector(interval time.Duration) *Collector {
	ctx, cancel := context.WithCancel(context.Background())
	return &Collector{
		ctx:      ctx,
		cancel:   cancel,
		interval: interval,
	}
}

func (c *Collector) OnSystemMetrics(fn func(SystemMetrics)) {
	c.onSystemMetrics = fn
}

func (c *Collector) OnTrafficMetrics(fn func(TrafficMetrics)) {
	c.onTrafficMetrics = fn
}

func (c *Collector) Start() {
	ticker := time.NewTicker(c.interval)
	defer ticker.Stop()

	for {
		select {
		case <-c.ctx.Done():
			return
		case <-ticker.C:
			c.collect()
		}
	}
}

func (c *Collector) Stop() {
	c.cancel()
}

func (c *Collector) collect() {
	c.collectSystemMetrics()
}

func (c *Collector) collectSystemMetrics() {
	metrics := SystemMetrics{
		CPUUsage:    0,
		MemoryUsage: 0,
		Network: NetworkMetrics{
			BytesSent:   0,
			BytesRecv:   0,
			PacketsSent: 0,
			PacketsRecv: 0,
		},
		LoadAvg:   []float64{0, 0, 0},
		Timestamp: time.Now(),
	}

	if c.onSystemMetrics != nil {
		c.onSystemMetrics(metrics)
	}
}

func (c *Collector) ReportTraffic(tunnelID, forwardID uint, upload, download uint64) {
	if c.onTrafficMetrics != nil {
		metrics := TrafficMetrics{
			TunnelID:  tunnelID,
			ForwardID: forwardID,
			Upload:    upload,
			Download:  download,
			Timestamp: time.Now(),
		}
		c.onTrafficMetrics(metrics)
	}
}
