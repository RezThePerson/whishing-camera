package main

import (
	"log/slog"
	"os"

	"github.com/reztheperson/ith/internal/http"
)

func main() {
	if err := http.Start(); err != nil {
		slog.Error("Failed to start http", "err", err)
		os.Exit(1)
	}
}
