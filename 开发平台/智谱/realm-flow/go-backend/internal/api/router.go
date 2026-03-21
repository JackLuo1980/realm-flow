package api

import (
	"realm-flow/internal/middleware"
	"realm-flow/internal/repository"
	"realm-flow/pkg/config"

	"github.com/gin-gonic/gin"
)

func NewRouter(repos *repository.Repositories, cfg *config.Config) *gin.Engine {
	r := gin.Default()

	// 处理器
	authHandler := NewAuthHandler(repos, cfg)
	userHandler := NewUserHandler(repos)
	nodeHandler := NewNodeHandler(repos)
	tunnelHandler := NewTunnelHandler(repos)
	forwardHandler := NewForwardHandler(repos)
	agentHandler := NewAgentHandler(repos)
	monitorHandler := NewMonitorHandler(repos)
	notifyHandler := NewNotifyHandler(repos)

	// 公开路由
	api := r.Group("/api")
	{
		// 认证
		auth := api.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
			auth.POST("/logout", authHandler.Logout)
		}

		// Agent 接口
		agent := api.Group("/agent")
		{
			agent.POST("/heartbeat", agentHandler.Heartbeat)
			agent.POST("/traffic", agentHandler.Traffic)
			agent.POST("/status", agentHandler.Status)
			agent.GET("/config/:node", agentHandler.GetConfig)
		}
	}

	// 需要认证的路由
	authorized := api.Group("")
	authorized.Use(middleware.JWTAuth(cfg))
	{
		// 认证
		authorized.GET("/auth/me", authHandler.Me)

		// 用户管理
		users := authorized.Group("/users")
		{
			users.GET("", middleware.AdminOnly(), userHandler.List)
			users.POST("", middleware.AdminOnly(), userHandler.Create)
			users.GET("/:id", userHandler.Get)
			users.PUT("/:id", userHandler.Update)
			users.DELETE("/:id", middleware.AdminOnly(), userHandler.Delete)
			users.GET("/:id/traffic", monitorHandler.GetUserTraffic)
		}

		// 节点管理
		nodes := authorized.Group("/nodes")
		{
			nodes.GET("", nodeHandler.List)
			nodes.POST("", middleware.AdminOnly(), nodeHandler.Create)
			nodes.GET("/:id", nodeHandler.Get)
			nodes.PUT("/:id", middleware.AdminOnly(), nodeHandler.Update)
			nodes.DELETE("/:id", middleware.AdminOnly(), nodeHandler.Delete)
			nodes.GET("/:id/status", nodeHandler.GetStatus)
			nodes.GET("/:id/traffic", monitorHandler.GetNodeTraffic)
		}

		// 隧道管理
		tunnels := authorized.Group("/tunnels")
		{
			tunnels.GET("", tunnelHandler.List)
			tunnels.POST("", tunnelHandler.Create)
			tunnels.GET("/:id", tunnelHandler.Get)
			tunnels.PUT("/:id", tunnelHandler.Update)
			tunnels.DELETE("/:id", tunnelHandler.Delete)
			tunnels.GET("/:id/forwards", tunnelHandler.GetForwards)
			tunnels.GET("/:id/traffic", monitorHandler.GetTunnelTraffic)
		}

		// 转发管理
		forwards := authorized.Group("/forwards")
		{
			forwards.GET("", forwardHandler.List)
			forwards.POST("", forwardHandler.Create)
			forwards.GET("/:id", forwardHandler.Get)
			forwards.PUT("/:id", forwardHandler.Update)
			forwards.DELETE("/:id", forwardHandler.Delete)
			forwards.POST("/:id/start", forwardHandler.Start)
			forwards.POST("/:id/stop", forwardHandler.Stop)
			forwards.POST("/batch", forwardHandler.Batch)
			forwards.GET("/:id/traffic", monitorHandler.GetForwardTraffic)
		}

		// 监控相关
		monitor := authorized.Group("/monitor")
		{
			monitor.GET("/traffic", monitorHandler.GetTraffic)
			monitor.GET("/server", monitorHandler.GetServerStatus)
			monitor.GET("/server/:id", monitorHandler.GetServerStatusByID)
			monitor.GET("/dashboard", monitorHandler.GetDashboard)
		}

		// 通知相关
		notify := authorized.Group("/notify")
		{
			notify.GET("/settings", notifyHandler.GetSettings)
			notify.PUT("/settings", notifyHandler.UpdateSettings)
			notify.POST("/test", notifyHandler.SendTest)
		}
	}

	return r
}
