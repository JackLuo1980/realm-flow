package main

import (
	"log"
	"os"

	"github.com/JackLuo1980/realm-flow/go-backend/internal/app"
)

func main() {
	application, err := app.New()
	if err != nil {
		log.Printf("failed to initialize app: %v", err)
		os.Exit(1)
	}

	if err := application.Run(); err != nil {
		log.Printf("server stopped with error: %v", err)
		os.Exit(1)
	}
}
