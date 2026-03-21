package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/JackLuo1980/realm-flow/go-backend/internal/config"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func TestHealthEndpoint(t *testing.T) {
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		t.Fatalf("failed to open sqlite db: %v", err)
	}

	srv := NewServer(config.Config{}, db)
	req := httptest.NewRequest(http.MethodGet, "/api/health", nil)
	rec := httptest.NewRecorder()

	srv.Handler().ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
}
