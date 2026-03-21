package api

import (
	"net/http"
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"strconv"

	"github.com/gin-gonic/gin"
)

type NodeHandler struct {
	repos *repository.Repositories
}

func NewNodeHandler(repos *repository.Repositories) *NodeHandler {
	return &NodeHandler{repos: repos}
}

type CreateNodeRequest struct {
	Name string `json:"name" binding:"required"`
	Host string `json:"host" binding:"required"`
	Port int    `json:"port"`
}

type UpdateNodeRequest struct {
	Name   string `json:"name"`
	Host   string `json:"host"`
	Port   int    `json:"port"`
	Status string `json:"status"`
}

func (h *NodeHandler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	nodes, total, err := h.repos.Node.List(page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":  nodes,
		"total": total,
		"page":  page,
	})
}

func (h *NodeHandler) Create(c *gin.Context) {
	var req CreateNodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Port == 0 {
		req.Port = 6365
	}

	node := &model.Node{
		Name:   req.Name,
		Host:   req.Host,
		Port:   req.Port,
		Status: "offline",
	}

	if err := h.repos.Node.Create(node); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, node)
}

func (h *NodeHandler) Get(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	node, err := h.repos.Node.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Node not found"})
		return
	}

	c.JSON(http.StatusOK, node)
}

func (h *NodeHandler) Update(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	node, err := h.repos.Node.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Node not found"})
		return
	}

	var req UpdateNodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Name != "" {
		node.Name = req.Name
	}
	if req.Host != "" {
		node.Host = req.Host
	}
	if req.Port != 0 {
		node.Port = req.Port
	}
	if req.Status != "" {
		node.Status = req.Status
	}

	if err := h.repos.Node.Update(node); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, node)
}

func (h *NodeHandler) Delete(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	if err := h.repos.Node.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Node deleted successfully"})
}

func (h *NodeHandler) GetStatus(c *gin.Context) {
	id, _ := strconv.ParseUint(c.Param("id"), 10, 32)
	node, err := h.repos.Node.GetByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Node not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":    node.Status,
		"last_seen": node.LastSeen,
		"version":   node.Version,
	})
}
