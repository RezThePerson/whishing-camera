package http

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"github.com/a-h/templ"
	"github.com/gorilla/mux"
	"github.com/reztheperson/ith/internal/web"
	"github.com/reztheperson/ith/internal/web/templates"
)

func Start() error {
	r := mux.NewRouter()

	// Set up routes
	r.PathPrefix("/static/").Handler(http.FileServer(http.FS(web.StaticFS)))
	r.Handle("/", templ.Handler(templates.Home())).Methods("GET")

	// Serving routes
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	slog.Info("App successfully started", "port", ":8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		return fmt.Errorf("serving http routes: %w", err)
	}

	return nil
}
