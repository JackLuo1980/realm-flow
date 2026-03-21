package api

import (
	"net/http"
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"strconv"

	"github.com/gin-gonic/gin"
)

type TunnelHandler struct {
	repos *repository.Repositories
}

func NewTunnelHandler(repos *repository.Repositories) *TunnelHandler {
	return &TunnelHandler{repos: repos}
}

type CreateTunnelRequest struct {
	UserID        uint   `json:"user_id" binding:"required"`
	NodeID        uint   `json:"node_id" binding:"required"`
	Name          string `json:"name" binding:"required"`
	RemoteAddr    string `json:"remote_addr"`
	RemotePort    int    `json:"remote_port"`
	Quota         int64  `json:"quota"`
	DefaultEngine string `json:"default_engine"`
}

type UpdateTunnelRequest struct {
	Name          string `json:"name"`
	RemoteAddr    string `json:"remote_addr"`
	RemotePort    int    `json:"remote_port"`
	Quota         int64  `json:"quota"`
	DefaultEngine string `json:"default_engine"`
	Status        string `json:"status"`
}

func (h *TunnelHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	// 检查是否是管理员
	role, _ := c.Get("role")
	var tunnels []model.Tunnel
	var total int64
	var err error

	if role == "admin" {
		tunnels, total, err = h.repos.Tunnel.ListAll(page, pageSize)
	} else {
		userID, _ := c.Get("userID")
		tunnels, total, err = h.repos.Tunnel.ListByUser(userID.(uint), page, pageSize)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":  tunnels,
		"total": total,
		"page":  page,
	})
}

func (h *TunnelHandler) Create(c *gin.Context) {
	var req CreateTunnelRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查权限
	role, _ := c.Get("role")
	userID, _ := c.Get("userID")
	if role != "admin" && req.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Permission denied"})
		return
	}

	if req.DefaultEngine == "" {
		req.DefaultEngine = "nftables"
	}

	tunnel := &model.Tunnel{
		UserID:        req.UserID,
		NodeID:        req.NodeID,
		Name:          req.Name,
		RemoteAddr:    req.RemoteAddr,
		RemotePort:    req.RemotePort,
		Quota:         req.Quota,
		DefaultEngine: req.DefaultEngine,
		Status:        "active",
	}

	if err := h.repos.Tunnel.Create(tunnel); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, tunnel)
}

func (h *TunnelHandler) Get(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	tunnel, err := h.repos.Tunnel.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tunnel not found"})
		return
	}

	// 检查权限
	role, _ := c.Get("role")
	userID, _ := c.Get("userID")
	if role != "admin" && tunnel.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Permission denied"})
		return
	}

	c.JSON(http.StatusOK, tunnel)
}

func (h *TunnelHandler) Update(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	tunnel, err := h.repos.Tunnel.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tunnel not found"})
		return
	}

	// 检查权限
	role, _ := c.Get("role")
	userID, _ := c.Get("userID")
	if role != "admin" && tunnel.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Permission denied"})
		return
	}

	var req UpdateTunnelRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Name != "" {
		tunnel.Name = req.Name
	}
	if req.RemoteAddr != "" {
		tunnel.RemoteAddr = req.RemoteAddr
	}
	if req.RemotePort != 0 {
		tunnel.RemotePort = req.RemotePort
	}
	if req.DefaultEngine != "" {
		tunnel.DefaultEngine = req.DefaultEngine
	}
	if req.Status != "" {
		tunnel.Status = req.Status
	}
	tunnel.Quota = req.Quota

	if err := h.repos.Tunnel.Update(tunnel); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, tunnel)
}

func (h *TunnelHandler) Delete(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	tunnel, err := h.repos.Tunnel.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tunnel not found"})
		return
	}

	// 检查权限
	role, _ := c.Get("role")
	userID, _ := c.Get("userID")
	if role != "admin" && tunnel.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Permission denied"})
		return
	}

	if err := h.repos.Tunnel.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Tunnel deleted successfully"})
}

func (h *TunnelHandler) GetForwards(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	forwards, err := h.repos.Forward.ListByTunnel(uint(id))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, forwards)
}
