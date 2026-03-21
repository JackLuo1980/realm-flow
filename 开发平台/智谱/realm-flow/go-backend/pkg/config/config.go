package config

import (
	"os"
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	JWT      JWTConfig      `mapstructure:"jwt"`
	Telegram TelegramConfig `mapstructure:"telegram"`
}

type ServerConfig struct {
	Port string `mapstructure:"port"`
	Mode string `mapstructure:"mode"`
}

type DatabaseConfig struct {
	Driver   string `mapstructure:"driver"`
	Host     string `mapstructure:"host"`
	Port     string `mapstructure:"port"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	DBName   string `mapstructure:"dbname"`
	SSLMode  string `mapstructure:"sslmode"`
}

type JWTConfig struct {
	Secret string `mapstructure:"secret"`
	Expire int    `mapstructure:"expire"`
}

type TelegramConfig struct {
	BotToken string `mapstructure:"bot_token"`
	Enabled  bool   `mapstructure:"enabled"`
}

func Load() *Config {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("/etc/realm-flow/")

	// 设置默认值
	viper.SetDefault("server.port", "6365")
	viper.SetDefault("server.mode", "release")
	viper.SetDefault("database.driver", "sqlite")
	viper.SetDefault("database.dbname", "realm-flow.db")
	viper.SetDefault("jwt.secret", "realm-flow-secret-key-change-in-production")
	viper.SetDefault("jwt.expire", 24)

	// 读取配置文件
	if err := viper.ReadInConfig(); err != nil {
		// 使用默认配置
	}

	// 从环境变量读取配置（优先级更高）
	if port := os.Getenv("PORT"); port != "" {
		viper.Set("server.port", port)
	}
	if jwtSecret := os.Getenv("JWT_SECRET"); jwtSecret != "" {
		viper.Set("jwt.secret", jwtSecret)
	}

	// 解析 DATABASE_URL 环境变量
	if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
		// 格式: postgres://user:password@host:port/dbname?sslmode=disable
		if strings.HasPrefix(dbURL, "postgres://") {
			viper.Set("database.driver", "postgres")
			// 解析 URL
			url := strings.TrimPrefix(dbURL, "postgres://")
			parts := strings.Split(url, "@")
			if len(parts) == 2 {
				userPass := strings.Split(parts[0], ":")
				if len(userPass) == 2 {
					viper.Set("database.user", userPass[0])
					viper.Set("database.password", userPass[1])
				}
				hostPortDB := parts[1]
				// 处理查询参数
				if idx := strings.Index(hostPortDB, "?"); idx != -1 {
					query := hostPortDB[idx+1:]
					hostPortDB = hostPortDB[:idx]
					if strings.Contains(query, "sslmode=") {
						sslmode := strings.Split(query, "sslmode=")[1]
						if idx := strings.Index(sslmode, "&"); idx != -1 {
							sslmode = sslmode[:idx]
						}
						viper.Set("database.sslmode", sslmode)
					}
				}
				// 解析 host:port/dbname
				hostPortAndDB := strings.SplitN(hostPortDB, "/", 2)
				if len(hostPortAndDB) == 2 {
					viper.Set("database.dbname", hostPortAndDB[1])
					hostPort := hostPortAndDB[0]
					if strings.Contains(hostPort, ":") {
						hp := strings.Split(hostPort, ":")
						viper.Set("database.host", hp[0])
						viper.Set("database.port", hp[1])
					} else {
						viper.Set("database.host", hostPort)
						viper.Set("database.port", "5432")
					}
				}
			}
		}
	}

	var cfg Config
	if err := viper.Unmarshal(&cfg); err != nil {
		panic(err)
	}

	return &cfg
}
