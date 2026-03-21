package api

import (
	"net/http"
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ForwardHandler struct {
	repos *repository.Repositories
}

func NewForwardHandler(repos *repository.Repositories) *ForwardHandler {
	return &ForwardHandler{repos: repos}
}

type CreateForwardRequest struct {
	TunnelID   uint   `json:"tunnel_id" binding:"required"`
	Name       string `json:"name"`
	ListenPort int    `json:"listen_port" binding:"required"`
	ListenIP   string `json:"listen_ip"`
	TargetAddr string `json:"target_addr" binding:"required"`
	TargetPort int    `json:"target_port" binding:"required"`
	Protocol   string `json:"protocol"`
	Engine     string `json:"engine"`
}

type UpdateForwardRequest struct {
	Name       string `json:"name"`
	ListenPort int    `json:"listen_port"`
	ListenIP   string `json:"listen_ip"`
	TargetAddr string `json:"target_addr"`
	TargetPort int    `json:"target_port"`
	Protocol   string `json:"protocol"`
	Engine     string `json:"engine"`
	Enabled    *bool  `json:"enabled"`
}

type BatchRequest struct {
	Action string `json:"action" binding:"required"` // start/stop/delete
	IDs    []uint `json:"ids" binding:"required"`
}

func (h *ForwardHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	forwards, total, err := h.repos.Forward.ListAll(page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":  forwards,
		"total": total,
		"page":  page,
	})
}

func (h *ForwardHandler) Create(c *gin.Context) {
	var req CreateForwardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.ListenIP == "" {
		req.ListenIP = "0.0.0.0"
	}
	if req.Protocol == "" {
		req.Protocol = "tcp"
	}
	if req.Engine == "" {
		// 获取隧道的默认引擎
		tunnel, err := h.repos.Tunnel.GetByID(req.TunnelID)
		if err == nil {
			req.Engine = tunnel.DefaultEngine
		} else {
			req.Engine = "nftables"
		}
	}

	forward := &model.Forward{
		TunnelID:   req.TunnelID,
		Name:       req.Name,
		ListenPort: req.ListenPort,
		ListenIP:   req.ListenIP,
		TargetAddr: req.TargetAddr,
		TargetPort: req.TargetPort,
		Protocol:   req.Protocol,
		Engine:     req.Engine,
		Enabled:    true,
		Status:     "stopped",
	}

	if err := h.repos.Forward.Create(forward); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, forward)
}

func (h *ForwardHandler) Get(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	forward, err := h.repos.Forward.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Forward not found"})
		return
	}

	c.JSON(http.StatusOK, forward)
}

func (h *ForwardHandler) Update(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	forward, err := h.repos.Forward.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Forward not found"})
		return
	}

	var req UpdateForwardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Name != "" {
		forward.Name = req.Name
	}
	if req.ListenPort != 0 {
		forward.ListenPort = req.ListenPort
	}
	if req.ListenIP != "" {
		forward.ListenIP = req.ListenIP
	}
	if req.TargetAddr != "" {
		forward.TargetAddr = req.TargetAddr
	}
	if req.TargetPort != 0 {
		forward.TargetPort = req.TargetPort
	}
	if req.Protocol != "" {
		forward.Protocol = req.Protocol
	}
	if req.Engine != "" {
		forward.Engine = req.Engine
	}
	if req.Enabled != nil {
		forward.Enabled = *req.Enabled
	}

	if err := h.repos.Forward.Update(forward); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, forward)
}

func (h *ForwardHandler) Delete(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	if err := h.repos.Forward.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Forward deleted successfully"})
}

func (h *ForwardHandler) Start(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	if err := h.repos.Forward.UpdateStatus(uint(id), "running"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Forward started"})
}

func (h *ForwardHandler) Stop(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	if err := h.repos.Forward.UpdateStatus(uint(id), "stopped"); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Forward stopped"})
}

func (h *ForwardHandler) Batch(c *gin.Context) {
	var req BatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var err error
	switch req.Action {
	case "start":
		err = h.repos.Forward.BatchUpdateStatus(req.IDs, "running")
	case "stop":
		err = h.repos.Forward.BatchUpdateStatus(req.IDs, "stopped")
	case "delete":
		err = h.repos.Forward.BatchDelete(req.IDs)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid action"})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Batch operation completed"})
}
