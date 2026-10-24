# Multi-stage production build for Go + Templ

# ---------------------------------------------------
# Stage 1: Build binary and compile templates
# ---------------------------------------------------
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Install git and build essentials if CGO or dependencies require them
RUN apk add --no-cache git ca-certificates

# Install templ CLI to generate Go code from .templ files
RUN go install github.com/a-h/templ/cmd/templ@latest

# Cache Go modules
COPY go.mod go.sum* ./
RUN go mod download

# Copy application source code
COPY . .

# 1. Generate Go files from .templ files
# 2. Compile static binary without CGO for minimal runtime image
RUN templ generate && \
    CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o server main.go

# ---------------------------------------------------
# Stage 2: Minimal runtime image
# ---------------------------------------------------
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/server /app/server

# Expose production application port
EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/app/server"]
