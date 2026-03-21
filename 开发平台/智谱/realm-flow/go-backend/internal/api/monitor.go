package api

import (
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type MonitorHandler struct {
	repos *repository.Repositories
}

func NewMonitorHandler(repos *repository.Repositories) *MonitorHandler {
	return &MonitorHandler{repos: repos}
}

func (h *MonitorHandler) GetTraffic(c *gin.Context) {
	c.JSON(200, gin.H{
		"upload":   int64(0),
		"download": int64(0),
		"total":    int64(0),
		"records":  []interface{}{},
	})
}

func (h *MonitorHandler) GetUserTraffic(c *gin.Context) {
	userID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid user ID"})
		return
	}

	fromStr := c.DefaultQuery("from", time.Now().AddDate(0, -1, 0).Format("2006-01-02"))
	toStr := c.DefaultQuery("to", time.Now().Format("2006-01-02"))

	from, _ := time.Parse("2006-01-02", fromStr)
	to, _ := time.Parse("2006-01-02", toStr)

	upload, download, err := h.repos.Traffic.GetUserTraffic(uint(userID), from, to)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{
		"user_id":  userID,
		"upload":   upload,
		"download": download,
		"total":    upload + download,
	})
}

func (h *MonitorHandler) GetNodeTraffic(c *gin.Context) {
	nodeID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid node ID"})
		return
	}

	fromStr := c.DefaultQuery("from", time.Now().AddDate(0, -1, 0).Format("2006-01-02"))
	toStr := c.DefaultQuery("to", time.Now().Format("2006-01-02"))

	from, _ := time.Parse("2006-01-02", fromStr)
	to, _ := time.Parse("2006-01-02", toStr)

	upload, download, err := h.repos.Traffic.GetNodeTraffic(uint(nodeID), from, to)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{
		"node_id":  nodeID,
		"upload":   upload,
		"download": download,
		"total":    upload + download,
	})
}

func (h *MonitorHandler) GetTunnelTraffic(c *gin.Context) {
	tunnelID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid tunnel ID"})
		return
	}

	fromStr := c.DefaultQuery("from", time.Now().AddDate(0, -1, 0).Format("2006-01-02"))
	toStr := c.DefaultQuery("to", time.Now().Format("2006-01-02"))

	from, _ := time.Parse("2006-01-02", fromStr)
	to, _ := time.Parse("2006-01-02", toStr)

	upload, download, err := h.repos.Traffic.GetTunnelTraffic(uint(tunnelID), from, to)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{
		"tunnel_id": tunnelID,
		"upload":    upload,
		"download":  download,
		"total":     upload + download,
	})
}

func (h *MonitorHandler) GetForwardTraffic(c *gin.Context) {
	forwardID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid forward ID"})
		return
	}

	fromStr := c.DefaultQuery("from", time.Now().AddDate(0, -1, 0).Format("2006-01-02"))
	toStr := c.DefaultQuery("to", time.Now().Format("2006-01-02"))

	from, _ := time.Parse("2006-01-02", fromStr)
	to, _ := time.Parse("2006-01-02", toStr)

	upload, download, err := h.repos.Traffic.GetForwardTraffic(uint(forwardID), from, to)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{
		"forward_id": forwardID,
		"upload":     upload,
		"download":   download,
		"total":      upload + download,
	})
}

func (h *MonitorHandler) GetServerStatus(c *gin.Context) {
	var statuses []model.ServerStatus
	h.repos.Traffic.GetDB().Order("timestamp desc").Limit(100).Find(&statuses)
	c.JSON(200, statuses)
}

func (h *MonitorHandler) GetServerStatusByID(c *gin.Context) {
	nodeID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid node ID"})
		return
	}

	var statuses []model.ServerStatus
	h.repos.Traffic.GetDB().Where("node_id = ?", nodeID).Order("timestamp desc").Limit(100).Find(&statuses)
	c.JSON(200, statuses)
}

func (h *MonitorHandler) GetDashboard(c *gin.Context) {
	var totalNodes, onlineNodes int64
	h.repos.Node.GetDB().Model(&model.Node{}).Count(&totalNodes)
	h.repos.Node.GetDB().Model(&model.Node{}).Where("status = ?", "online").Count(&onlineNodes)

	var totalTunnels, activeTunnels int64
	h.repos.Tunnel.GetDB().Model(&model.Tunnel{}).Count(&totalTunnels)
	h.repos.Tunnel.GetDB().Model(&model.Tunnel{}).Where("status = ?", "active").Count(&activeTunnels)

	var totalUsers int64
	h.repos.User.GetDB().Model(&model.User{}).Count(&totalUsers)

	var todayTraffic int64
	today := time.Now().Truncate(24 * time.Hour)
	h.repos.Traffic.GetDB().Model(&model.TrafficRecord{}).
		Where("timestamp >= ?", today).
		Select("COALESCE(SUM(upload + download), 0)").
		Scan(&todayTraffic)

	c.JSON(200, gin.H{
		"total_nodes":    totalNodes,
		"online_nodes":   onlineNodes,
		"total_tunnels":  totalTunnels,
		"active_tunnels": activeTunnels,
		"total_users":    totalUsers,
		"today_traffic":  todayTraffic,
	})
}
