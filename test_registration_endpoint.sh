#!/bin/bash

# Test Registration Endpoint Script
# This tests if the Matrix registration endpoint is accessible and working

SERVER="http://192.168.178.34"
REGISTER_URL="${SERVER}/_matrix/client/v3/register"

echo "🧪 Testing Matrix Registration Endpoint"
echo "========================================"
echo ""
echo "Server: $SERVER"
echo "Endpoint: $REGISTER_URL"
echo ""

# Test 1: Check if server is reachable
echo "1. Testing server connectivity..."
if curl -s --connect-timeout 5 "$SERVER" > /dev/null 2>&1; then
    echo "   ✅ Server is reachable"
else
    echo "   ❌ Server is NOT reachable"
    echo "   Please check if the server at $SERVER is running and accessible"
    exit 1
fi

# Test 2: Check registration endpoint
echo ""
echo "2. Testing registration endpoint..."
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$REGISTER_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser'$(date +%s)'",
    "password": "testpass123",
    "initial_device_display_name": "Test Device",
    "auth": {}
  }' 2>&1)

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

echo "   HTTP Status: $HTTP_STATUS"
echo "   Response: $BODY"
echo ""

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ]; then
    echo "   ✅ Registration endpoint is working!"
    echo "   The server accepts registration requests"
elif [ "$HTTP_STATUS" = "403" ]; then
    echo "   ⚠️  Registration is disabled on this server (403 Forbidden)"
    echo "   You may need to enable registration in your Matrix server configuration"
elif [ "$HTTP_STATUS" = "400" ]; then
    echo "   ⚠️  Bad request (400)"
    echo "   This might be due to username format or other validation issues"
    echo "   Response details: $BODY"
else
    echo "   ❌ Registration endpoint returned status: $HTTP_STATUS"
    echo "   Response: $BODY"
fi

echo ""
echo "========================================"
echo "Test completed"

