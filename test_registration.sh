#!/bin/bash

# Test Registration Script
# This script helps monitor registration logs while testing

echo "🔍 Registration Test Monitor"
echo "============================"
echo ""
echo "1. Launch the app on the simulator"
echo "2. Try to create an account with username and password"
echo "3. Watch the logs below for registration details"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""
echo "Monitoring registration logs..."
echo ""

# Monitor console logs for registration-related messages
xcrun simctl spawn "iPhone 17 Pro" log stream --predicate 'processImagePath contains "Lingugram"' --level debug 2>/dev/null | grep -i "registration\|register\|error\|failed\|success" --line-buffered

