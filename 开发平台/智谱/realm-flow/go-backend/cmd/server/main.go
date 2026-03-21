package main

import (
	"log"
	"realm-flow/internal/api"
	"realm-flow/internal/model"
	"realm-flow/internal/repository"
	"realm-flow/pkg/config"
	"realm-flow/pkg/database"
)

func main() {
	// 加载配置
	cfg := config.Load()

	// 初始化数据库
	db, err := database.Init(cfg.Database)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// 自动迁移
	if err := model.AutoMigrate(db); err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// 初始化仓库
	repos := repository.NewRepositories(db)

	// 创建默认管理员
	if err := repos.User.CreateDefaultAdmin(); err != nil {
		log.Println("Warning: Failed to create default admin:", err)
	}

	// 启动服务器
	router := api.NewRouter(repos, cfg)
	log.Printf("Server starting on port %s", cfg.Server.Port)
	if err := router.Run(":" + cfg.Server.Port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
