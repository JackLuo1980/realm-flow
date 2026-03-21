package httpapi

import (
	"net/http"

	"github.com/JackLuo1980/realm-flow/go-backend/internal/auth"
	"github.com/JackLuo1980/realm-flow/go-backend/internal/config"
	"gorm.io/gorm"
)

type Server struct {
	cfg     config.Config
	db      *gorm.DB
	jwt     *auth.Manager
	mux     *http.ServeMux
	handler http.Handler
}

func NewServer(cfg config.Config, database *gorm.DB) *Server {
	server := &Server{
		cfg: cfg,
		db:  database,
		jwt: auth.NewManager(cfg.JWTSecret, cfg.JWTIssuer),
		mux: http.NewServeMux(),
	}
	server.routes()
	server.handler = Chain(
		server.mux,
		Recover(),
		RequestLog(),
		CORS(cfg.CORSOrigins),
		JWTBypass(),
	)
	return server
}

func (s *Server) Handler() http.Handler {
	return s.handler
}

func (s *Server) routes() {
	s.mux.HandleFunc("GET /api/health", s.health)
	s.mux.HandleFunc("GET /api/auth/me", s.authMe)
	s.mux.HandleFunc("POST /api/auth/login", s.notImplemented("login"))
	s.mux.HandleFunc("POST /api/auth/logout", s.notImplemented("logout"))
}

func (s *Server) health(w http.ResponseWriter, r *http.Request) {
	data := map[string]any{"status": "ok"}
	if s.db != nil {
		sqlDB, err := s.db.DB()
		if err != nil {
			Error(w, http.StatusInternalServerError, "database unavailable")
			return
		}
		if err := sqlDB.Ping(); err != nil {
			Error(w, http.StatusServiceUnavailable, "database unavailable")
			return
		}
		data["database"] = "ok"
	}
	OK(w, data)
}

func (s *Server) authMe(w http.ResponseWriter, r *http.Request) {
	OK(w, map[string]any{
		"user": nil,
	})
}

func (s *Server) notImplemented(name string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		Error(w, http.StatusNotImplemented, name+" is not implemented yet")
	}
}
