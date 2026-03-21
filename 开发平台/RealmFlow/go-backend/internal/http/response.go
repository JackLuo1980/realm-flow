package httpapi

import (
	"encoding/json"
	"net/http"
)

type Envelope struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

func JSON(w http.ResponseWriter, status int, payload Envelope) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func OK(w http.ResponseWriter, data any) {
	JSON(w, http.StatusOK, Envelope{Code: http.StatusOK, Message: "ok", Data: data})
}

func Error(w http.ResponseWriter, status int, message string) {
	JSON(w, status, Envelope{Code: status, Message: message})
}
