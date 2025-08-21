#!/bin/bash

echo "Testing MCP Echo Server with multiple messages..."

# Initialize connection and get session ID
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

SESSION_ID=$(echo "$INIT_RESPONSE" | grep -i "mcp-session-id" | cut -d: -f2 | tr -d ' \r\n')

if [ -n "$SESSION_ID" ]; then
  echo "Session established: $SESSION_ID"
  
  # Test various echo messages
  messages=("Hello, MCP!" "This is a test message" "🚀 Streaming server works!" "123 Numbers and symbols @#$")
  
  for i in "${!messages[@]}"; do
    id=$((i + 2))
    message="${messages[$i]}"
    echo -e "\nTest $((i + 1)): Echoing '$message'"
    
    response=$(curl -s -X POST http://localhost:8081/mcp \
      -H "Content-Type: application/json" \
      -H "Mcp-Session-Id: $SESSION_ID" \
      -d "{
        \"jsonrpc\": \"2.0\",
        \"id\": $id,
        \"method\": \"tools/call\",
        \"params\": {
          \"name\": \"echo\",
          \"arguments\": {
            \"message\": \"$message\"
          }
        }
      }")
    
    # Extract the echoed text from the JSON response
    echo "Response: $response"
  done
else
  echo "Failed to establish session"
fi
