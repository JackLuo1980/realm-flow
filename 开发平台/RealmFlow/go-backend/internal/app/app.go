package app

import (
	"context"
	"net/http"
	"time"

	"github.com/JackLuo1980/realm-flow/go-backend/internal/config"
	"github.com/JackLuo1980/realm-flow/go-backend/internal/db"
	httpapi "github.com/JackLuo1980/realm-flow/go-backend/internal/http"
)

type App struct {
	cfg    config.Config
	server *http.Server
}

func New() (*App, error) {
	cfg := config.Load()
	database, err := db.Open(cfg)
	if err != nil {
		return nil, err
	}
	if err := db.AutoMigrate(database); err != nil {
		return nil, err
	}

	handler := httpapi.NewServer(cfg, database).Handler()
	server := &http.Server{
		Addr:              cfg.Address(),
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
	}

	return &App{cfg: cfg, server: server}, nil
}

func (a *App) Run() error {
	return a.server.ListenAndServe()
}

func (a *App) Shutdown(ctx context.Context) error {
	return a.server.Shutdown(ctx)
}
