# Build stage
FROM golang:1.23-alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /go-postgresqld ./examples/go-postgresqld

# Runtime stage
FROM alpine:latest

RUN apk update && apk add --no-cache ca-certificates

COPY --from=builder /go-postgresqld /go-postgresqld

ENTRYPOINT ["/go-postgresqld"]
