package api

import (
	"realm-flow/internal/model"
	"realm-flow/internal/repository"

	"github.com/gin-gonic/gin"
)

type NotifyHandler struct {
	repos *repository.Repositories
}

func NewNotifyHandler(repos *repository.Repositories) *NotifyHandler {
	return &NotifyHandler{repos: repos}
}

func (h *NotifyHandler) GetSettings(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	user, err := h.repos.User.GetByID(userID.(uint))
	if err != nil {
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	c.JSON(200, user.NotifyConfig)
}

func (h *NotifyHandler) UpdateSettings(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var req model.NotifyConfig
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	user, err := h.repos.User.GetByID(userID.(uint))
	if err != nil {
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	user.NotifyConfig = req
	if err := h.repos.User.Update(user); err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, user.NotifyConfig)
}

func (h *NotifyHandler) SendTest(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		Type string `json:"type" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	user, err := h.repos.User.GetByID(userID.(uint))
	if err != nil {
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	if user.TelegramID == "" {
		c.JSON(400, gin.H{"error": "Telegram ID not set"})
		return
	}

	message := h.generateTestMessage(req.Type)

	c.JSON(200, gin.H{
		"message":     "Test notification queued",
		"telegram_id": user.TelegramID,
		"content":     message,
	})
}

func (h *NotifyHandler) generateTestMessage(notifyType string) string {
	switch notifyType {
	case "traffic_alert":
		return "📊 流量告警测试\n\n这是一个测试消息，用于验证通知配置。"
	case "traffic_exceed":
		return "⚠️ 流量超限测试\n\n这是一个测试消息，用于验证通知配置。"
	case "node_down":
		return "🔴 节点离线测试\n\n这是一个测试消息，用于验证通知配置。"
	case "node_online":
		return "🟢 节点上线测试\n\n这是一个测试消息，用于验证通知配置。"
	case "forward_down":
		return "❌ 转发故障测试\n\n这是一个测试消息，用于验证通知配置。"
	case "server_high_load":
		return "⚡ 负载告警测试\n\n这是一个测试消息，用于验证通知配置。"
	default:
		return "🔔 通知测试\n\n这是一个测试消息，用于验证通知配置。"
	}
}
