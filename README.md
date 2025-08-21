# mcping

A Model Context Protocol (MCP) HTTP streaming server that provides an echo tool for testing deployments.

## Features

- **HTTP Streaming Server**: Implements the MCP streamable HTTP transport protocol
- **Echo Tool**: Simple tool that echoes back any message sent to it
- **Session Management**: Proper MCP session handling with session IDs
- **Graceful Shutdown**: Handles SIGINT/SIGTERM for clean shutdown
- **JSON-RPC 2.0**: Full compliance with MCP protocol specifications

## Building and Running

```bash
# Build the server
go build

# Run the server
./mcping
```

The server will start on port 8081 and be available at `http://localhost:8081/mcp`.

## Usage

The server implements the MCP streamable HTTP protocol. Here's how to interact with it:

### 1. Initialize a Session

```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-03-26",
      "capabilities": {
        "tools": {}
      },
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    }
  }'
```

This returns a session ID in the `Mcp-Session-Id` header that must be used for subsequent requests.

### 2. List Available Tools

```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: YOUR_SESSION_ID" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'
```

### 3. Call the Echo Tool

```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: YOUR_SESSION_ID" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "echo",
      "arguments": {
        "message": "Hello, World!"
      }
    }
  }'
```

## Testing

Run the included test scripts to verify functionality:

```bash
# Basic functionality test
./test_client.sh

# Comprehensive echo testing
./test_echo.sh
```

## Dependencies

- [github.com/mark3labs/mcp-go](https://github.com/mark3labs/mcp-go) - MCP implementation for Go

## Protocol Compliance

This server implements the [Model Context Protocol](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports#streamable-http) streamable HTTP transport specification.
