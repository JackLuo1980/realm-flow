package api

import (
	"net/http"
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type AgentHandler struct {
	repos *repository.Repositories
}

func NewAgentHandler(repos *repository.Repositories) *AgentHandler {
	return &AgentHandler{repos: repos}
}

type AgentHeartbeatRequest struct {
	NodeID  uint   `json:"node_id" binding:"required"`
	APIKey  string `json:"api_key" binding:"required"`
	Status  string `json:"status"`
	Version string `json:"version"`
}

type AgentTrafficRequest struct {
	NodeID  uint                 `json:"node_id" binding:"required"`
	APIKey  string               `json:"api_key" binding:"required"`
	Records []TrafficRecordInput `json:"records" binding:"required"`
}

type TrafficRecordInput struct {
	ForwardID uint  `json:"forward_id"`
	TunnelID  uint  `json:"tunnel_id"`
	Upload    int64 `json:"upload"`
	Download  int64 `json:"download"`
}

type AgentStatusRequest struct {
	NodeID     uint    `json:"node_id" binding:"required"`
	APIKey     string  `json:"api_key" binding:"required"`
	CPU        float64 `json:"cpu"`
	Memory     float64 `json:"memory"`
	Disk       float64 `json:"disk"`
	NetworkIn  int64   `json:"network_in"`
	NetworkOut int64   `json:"network_out"`
}

func (h *AgentHandler) validateAPIKey(nodeID uint, apiKey string) bool {
	node, err := h.repos.Node.GetByID(nodeID)
	if err != nil {
		return false
	}
	return node.APIKey == apiKey
}

func (h *AgentHandler) Heartbeat(c *gin.Context) {
	var req AgentHeartbeatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if !h.validateAPIKey(req.NodeID, req.APIKey) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid API key"})
		return
	}

	node, err := h.repos.Node.GetByID(req.NodeID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Node not found"})
		return
	}

	node.Status = req.Status
	node.LastSeen = time.Now()
	if req.Version != "" {
		node.Version = req.Version
	}

	if err := h.repos.Node.Update(node); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Heartbeat received"})
}

func (h *AgentHandler) Traffic(c *gin.Context) {
	var req AgentTrafficRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if !h.validateAPIKey(req.NodeID, req.APIKey) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid API key"})
		return
	}

	// 批量创建流量记录
	records := make([]model.TrafficRecord, len(req.Records))
	for i, r := range req.Records {
		records[i] = model.TrafficRecord{
			ForwardID: r.ForwardID,
			TunnelID:  r.TunnelID,
			NodeID:    req.NodeID,
			Upload:    r.Upload,
			Download:  r.Download,
			Timestamp: time.Now(),
		}

		// 获取转发信息，补充 UserID
		forward, err := h.repos.Forward.GetByID(r.ForwardID)
		if err == nil {
			tunnel, err := h.repos.Tunnel.GetByID(forward.TunnelID)
			if err == nil {
				records[i].UserID = tunnel.UserID
			}
		}
	}

	if err := h.repos.Traffic.CreateBatch(records); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Traffic data received"})
}

func (h *AgentHandler) Status(c *gin.Context) {
	var req AgentStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if !h.validateAPIKey(req.NodeID, req.APIKey) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid API key"})
		return
	}

	status := &model.ServerStatus{
		NodeID:     req.NodeID,
		CPU:        req.CPU,
		Memory:     req.Memory,
		Disk:       req.Disk,
		NetworkIn:  req.NetworkIn,
		NetworkOut: req.NetworkOut,
		Timestamp:  time.Now(),
	}

	if err := h.repos.Traffic.SaveServerStatus(status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Status data received"})
}

func (h *AgentHandler) GetConfig(c *gin.Context) {
	nodeID, _ := strconv.ParseUint(c.Param("node"), 10, 32)
	apiKey := c.Query("api_key")

	if !h.validateAPIKey(uint(nodeID), apiKey) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid API key"})
		return
	}

	// 获取节点的所有隧道和转发配置
	tunnels, err := h.repos.Tunnel.GetByNodeID(uint(nodeID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	type ConfigTunnel struct {
		ID            uint            `json:"id"`
		Name          string          `json:"name"`
		DefaultEngine string          `json:"default_engine"`
		Forwards      []model.Forward `json:"forwards"`
	}

	configTunnels := make([]ConfigTunnel, 0, len(tunnels))
	for _, tunnel := range tunnels {
		forwards, _ := h.repos.Forward.ListByTunnel(tunnel.ID)
		configTunnels = append(configTunnels, ConfigTunnel{
			ID:            tunnel.ID,
			Name:          tunnel.Name,
			DefaultEngine: tunnel.DefaultEngine,
			Forwards:      forwards,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"node_id": nodeID,
		"tunnels": configTunnels,
	})
}
