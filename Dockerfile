# Multi-stage build for Go application optimized for Cloud Run
# Build stage
FROM golang:1.23-bullseye AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go mod and sum files first for better layer caching
COPY go.mod go.sum ./

# Set Go environment variables for the build
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

# Since we need Go 1.25 but using 1.23, let's set GOTOOLCHAIN to allow auto download
ENV GOTOOLCHAIN=go1.25.0

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application with optimizations for Cloud Run
RUN go build -ldflags="-w -s" -o mcping .

# Runtime stage - use Google's distroless image for security and minimal size
FROM gcr.io/distroless/static-debian12:nonroot

# Copy the binary from the builder stage
COPY --from=builder /app/mcping /mcping

# Use non-root user (distroless nonroot user has UID 65532)
USER nonroot:nonroot

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Set the PORT environment variable (Cloud Run will override this)
ENV PORT=8080

# Run the binary
ENTRYPOINT ["/mcping"]
