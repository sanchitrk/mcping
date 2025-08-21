#!/bin/bash

echo "Testing MCP Server..."

# Test 1: Initialize connection and capture session ID
echo "1. Testing initialization..."
INIT_RESPONSE=$(curl -s -i -X POST http://localhost:8081/mcp \
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
  }')

# Extract session ID from headers
SESSION_ID=$(echo "$INIT_RESPONSE" | grep -i "mcp-session-id" | cut -d: -f2 | tr -d ' \r\n')
echo "Response: $INIT_RESPONSE"
echo "Session ID: $SESSION_ID"

if [ -n "$SESSION_ID" ]; then
  echo -e "\n\n2. Testing list tools with session ID..."
  # Test 2: List available tools
  curl -X POST http://localhost:8081/mcp \
    -H "Content-Type: application/json" \
    -H "Mcp-Session-Id: $SESSION_ID" \
    -d '{
      "jsonrpc": "2.0",
      "id": 2,
      "method": "tools/list",
      "params": {}
    }'

  echo -e "\n\n3. Testing echo tool with session ID..."
  # Test 3: Call echo tool
  curl -X POST http://localhost:8081/mcp \
    -H "Content-Type: application/json" \
    -H "Mcp-Session-Id: $SESSION_ID" \
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
else
  echo "Failed to get session ID"
fi

echo -e "\n"
