package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

func main() {
	// Create MCP server with tool capabilities enabled
	s := server.NewMCPServer(
		"Echo Server",
		"1.0.0",
		server.WithToolCapabilities(true),
	)

	// Define the echo tool
	tool := mcp.NewTool("echo",
		mcp.WithDescription("Echoes back the input message"),
		mcp.WithString("message",
			mcp.Required(),
			mcp.Description("The message to echo back"),
		),
	)

	// Add the tool with its handler
	s.AddTool(tool, echoHandler)

	// Create streamable HTTP server
	streamableServer := server.NewStreamableHTTPServer(s)

	// Set up graceful shutdown
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// Start server in a goroutine
	go func() {
		fmt.Println("Starting MCP HTTP streaming server on port 8081...")
		fmt.Println("The server endpoint is available at: http://localhost:8081/mcp")
		fmt.Println("Press Ctrl+C to gracefully shutdown")

		if err := streamableServer.Start(":8081"); err != nil {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for shutdown signal
	<-ctx.Done()
	fmt.Println("\nShutting down server...")

	// Graceful shutdown
	if err := streamableServer.Shutdown(context.Background()); err != nil {
		log.Printf("Error during shutdown: %v", err)
	} else {
		fmt.Println("Server shutdown complete")
	}
}

func echoHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	// Extract the message parameter
	message, err := request.RequireString("message")
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Missing or invalid 'message' parameter: %v", err)), nil
	}

	// Log the request for debugging
	log.Printf("Echo request received: %q", message)

	// Return the echoed message
	return mcp.NewToolResultText(fmt.Sprintf("Echo: %s", message)), nil
}
