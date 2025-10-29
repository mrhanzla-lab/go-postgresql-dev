# Build stage
FROM golang:1.23-alpine AS builder

RUN apk update && apk add --no-cache git ca-certificates

WORKDIR /build

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code (excluding bin/ via .dockerignore)
COPY postgresql ./postgresql
COPY postgresqltest ./postgresqltest
COPY examples ./examples

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go-postgresqld ./examples/go-postgresqld

# Runtime stage
FROM alpine:latest

RUN apk update && apk add --no-cache ca-certificates

COPY --from=builder /go-postgresqld /go-postgresqld

ENTRYPOINT ["/go-postgresqld"]
