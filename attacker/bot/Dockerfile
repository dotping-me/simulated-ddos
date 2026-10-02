
# Multi-stage Docker build file for bots

# 1. Build stage
FROM golang:1.27-alpine AS builder
WORKDIR /app

# TODO: Can include tcpdump to show network activity

# Downloading dependencies
COPY go.mod go.sum ./
RUN go mod download

# Compiling bot scrips
COPY bot/ ./bot/
COPY cmd/bot/ ./cmd/bot/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bot ./cmd/bot
RUN chmod +x /app/bot/flood.sh

# 2. Runtime stage
FROM alpine:latest
RUN apk add --no-cache bash iproute2 su-exec

# Runs the binary which starts the relevant scripts
RUN adduser -D -H bot

COPY --from=builder /bot /bot
COPY --from=builder /app/bot /app/bot
COPY bot/entrypoint.sh /entrypoint.sh
RUN chmod 755 /bot /entrypoint.sh /app/bot/flood.sh && chown -R bot:bot /app/bot /bot

ENTRYPOINT ["/entrypoint.sh"]