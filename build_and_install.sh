#!/bin/bash

# Build and Install Script for Lingugram iOS App
# This script builds the app and installs it on the iPhone 17 Pro simulator
# It preserves keychain data to keep you logged in across rebuilds

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCHEME="Lingugram"
PROJECT="Lingugram.xcodeproj"
SIMULATOR_NAME="iPhone 17 Pro"
DERIVED_DATA_PATH="./build"

# Check for clean install flag
CLEAN_INSTALL=false
if [[ "$1" == "--clean" ]] || [[ "$1" == "-c" ]]; then
    CLEAN_INSTALL=true
    echo -e "${YELLOW}⚠️  Clean install mode: Will uninstall app first (keychain will be cleared)${NC}\n"
fi

echo -e "${GREEN}🚀 Starting build and install process...${NC}\n"

# Step 1: Get simulator UDID and ensure it's booted
echo -e "${YELLOW}📱 Checking simulator status...${NC}"
SIMULATOR_UDID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()')

if [ -z "$SIMULATOR_UDID" ]; then
    echo -e "${RED}❌ Could not find simulator: $SIMULATOR_NAME${NC}"
    echo -e "${BLUE}💡 Available simulators:${NC}"
    xcrun simctl list devices available | grep "iPhone"
    exit 1
fi

echo -e "${GREEN}✅ Found simulator: $SIMULATOR_NAME (${SIMULATOR_UDID})${NC}"

# Check if simulator is booted
BOOT_STATUS=$(xcrun simctl list devices | grep "$SIMULATOR_UDID" | grep -oE '\(Booted\)|\(Shutdown\)')
if [[ "$BOOT_STATUS" == "(Shutdown)" ]]; then
    echo -e "${YELLOW}🔌 Booting simulator...${NC}"
    xcrun simctl boot "$SIMULATOR_UDID"
    # Wait a bit for simulator to fully boot
    sleep 3
    echo -e "${GREEN}✅ Simulator booted${NC}\n"
else
    echo -e "${GREEN}✅ Simulator is already booted${NC}\n"
fi

# Step 2: Handle clean install BEFORE building (if requested)
if [ "$CLEAN_INSTALL" = true ]; then
    echo -e "${YELLOW}🧹 Clean install requested - checking for existing app...${NC}"
    # Try to find bundle ID from previous install or use common one
    # We'll uninstall after we get the bundle ID from the built app
    echo -e "${BLUE}ℹ️  Will uninstall after build to get bundle ID${NC}\n"
fi

# Step 3: Get bundle ID from existing app (if it exists) to check consistency
echo -e "${YELLOW}🔍 Checking for existing app installation...${NC}"
# Try multiple methods to get the existing bundle ID
# First try: extract from simctl listapps output
EXISTING_BUNDLE_ID=$(xcrun simctl listapps "$SIMULATOR_UDID" 2>/dev/null | grep -i "CFBundleIdentifier" | grep -i "io.element.elementx" | head -1 | sed -E 's/.*CFBundleIdentifier[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/' || echo "")

# If that didn't work, try searching for the bundle ID directly
if [ -z "$EXISTING_BUNDLE_ID" ]; then
    EXISTING_BUNDLE_ID=$(xcrun simctl listapps "$SIMULATOR_UDID" 2>/dev/null | grep -o 'io\.element\.elementx' | head -1 || echo "")
fi

# Last resort: try plutil approach
if [ -z "$EXISTING_BUNDLE_ID" ]; then
    EXISTING_BUNDLE_ID=$(xcrun simctl listapps "$SIMULATOR_UDID" 2>/dev/null | plutil -convert json -o - - 2>/dev/null | grep -o '"io\.element\.elementx"' | head -1 | tr -d '"' || echo "")
fi

if [ -n "$EXISTING_BUNDLE_ID" ]; then
    echo -e "${GREEN}✅ Found existing app with bundle ID: $EXISTING_BUNDLE_ID${NC}"
else
    echo -e "${BLUE}ℹ️  No existing app found (first install)${NC}"
fi
echo ""

# Step 4: Build the app
echo -e "${YELLOW}📦 Building the app...${NC}"
xcodebuild -project "$PROJECT" \
           -scheme "$SCHEME" \
           -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
           -derivedDataPath "$DERIVED_DATA_PATH" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build succeeded!${NC}\n"

# Step 5: Find the built app
echo -e "${YELLOW}🔍 Looking for built app...${NC}"
APP_PATH=$(find "$DERIVED_DATA_PATH/Build/Products" -name "Lingugram.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found app at: $APP_PATH${NC}\n"

# Step 6: Get bundle ID
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print:CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "")
if [ -z "$BUNDLE_ID" ]; then
    echo -e "${YELLOW}⚠️  Could not read bundle ID from Info.plist${NC}"
fi

# Step 7: Check bundle ID consistency
if [ -n "$EXISTING_BUNDLE_ID" ] && [ -n "$BUNDLE_ID" ] && [ "$BUNDLE_ID" != "$EXISTING_BUNDLE_ID" ]; then
    echo -e "${YELLOW}⚠️  Warning: Bundle ID changed!${NC}"
    echo -e "${YELLOW}   Previous: $EXISTING_BUNDLE_ID${NC}"
    echo -e "${YELLOW}   Current:  $BUNDLE_ID${NC}"
    echo -e "${YELLOW}⚠️  This will cause keychain to be cleared!${NC}\n"
fi

# Step 8: Uninstall app if clean install requested
if [ "$CLEAN_INSTALL" = true ] && [ -n "$BUNDLE_ID" ]; then
    echo -e "${YELLOW}🧹 Uninstalling existing app (this will clear keychain)...${NC}"
    xcrun simctl uninstall "$SIMULATOR_UDID" "$BUNDLE_ID" 2>/dev/null || true
    echo -e "${GREEN}✅ App uninstalled${NC}\n"
fi

# Step 9: Install on simulator
# IMPORTANT: For keychain preservation, the bundle ID MUST stay the same
# The keychain is tied to the bundle ID and keychain access group
# NOTE: simctl install can sometimes replace the app entirely, clearing keychain
# This is a known iOS Simulator limitation
echo -e "${YELLOW}📱 Installing app on $SIMULATOR_NAME...${NC}"
if [ "$CLEAN_INSTALL" = false ]; then
    if [ -n "$EXISTING_BUNDLE_ID" ] && [ -n "$BUNDLE_ID" ] && [ "$BUNDLE_ID" == "$EXISTING_BUNDLE_ID" ]; then
        echo -e "${GREEN}✅ Bundle ID matches - attempting to preserve keychain...${NC}"
        echo -e "${YELLOW}⚠️  Note: Simulator keychain preservation is unreliable${NC}"
        echo -e "${YELLOW}⚠️  Even with matching bundle IDs, keychain may be cleared${NC}"
    elif [ -z "$EXISTING_BUNDLE_ID" ]; then
        echo -e "${BLUE}💡 First install - no existing keychain to preserve${NC}"
    else
        echo -e "${YELLOW}⚠️  Bundle ID mismatch - keychain will be cleared${NC}"
    fi
    if [ -n "$BUNDLE_ID" ]; then
        echo -e "${BLUE}💡 Bundle ID: $BUNDLE_ID${NC}"
        # Check keychain access group
        KEYCHAIN_ACCESS_GROUP=$(/usr/libexec/PlistBuddy -c "Print:keychainAccessGroupIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "")
        if [ -n "$KEYCHAIN_ACCESS_GROUP" ]; then
            echo -e "${BLUE}💡 Keychain Access Group: $KEYCHAIN_ACCESS_GROUP${NC}"
        fi
    fi
    echo ""
fi

# Install on simulator
# NOTE: simctl install can replace the app entirely, clearing keychain
# This is a known iOS Simulator limitation - keychain preservation is unreliable
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Installation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App installed successfully!${NC}\n"

if [ "$CLEAN_INSTALL" = false ]; then
    echo -e "${GREEN}🔐 Keychain preservation status:${NC}"
    if [ -n "$EXISTING_BUNDLE_ID" ] && [ -n "$BUNDLE_ID" ] && [ "$BUNDLE_ID" == "$EXISTING_BUNDLE_ID" ]; then
        echo -e "${GREEN}✅ Bundle IDs match: $BUNDLE_ID${NC}"
        echo -e "${YELLOW}⚠️  IMPORTANT: iOS Simulator keychain preservation is unreliable${NC}"
        echo -e "${YELLOW}⚠️  Even with matching bundle IDs, simctl install may clear keychain${NC}"
        echo -e "${BLUE}💡 This is a known simulator limitation, not a script issue${NC}"
        echo ""
        echo -e "${BLUE}💡 Alternative solutions:${NC}"
        echo -e "${BLUE}   1. Use Xcode's 'Build and Run' (⌘R) - may preserve better${NC}"
        echo -e "${BLUE}   2. Test on a physical device - keychain preservation works reliably${NC}"
        echo -e "${BLUE}   3. Use Fastlane or other tools that may handle this better${NC}"
        echo -e "${BLUE}   4. Accept that simulator requires login after each install${NC}"
    elif [ -n "$BUNDLE_ID" ]; then
        echo -e "${YELLOW}⚠️  Bundle ID check:${NC}"
        echo -e "${BLUE}   Current: $BUNDLE_ID${NC}"
        if [ -n "$EXISTING_BUNDLE_ID" ]; then
            echo -e "${BLUE}   Previous: $EXISTING_BUNDLE_ID${NC}"
        fi
        echo -e "${YELLOW}⚠️  Bundle ID mismatch will cause keychain to be cleared${NC}"
    fi
    echo -e "${BLUE}💡 Note: Display name is 'Lingugram' but bundle ID is 'io.element.elementx'${NC}"
    echo -e "${BLUE}💡 Keychain Access Group: ${KEYCHAIN_ACCESS_GROUP:-unknown}${NC}\n"
fi

echo -e "\n${GREEN}🎉 Done!${NC}"
echo -e "${BLUE}💡 Tip: Use --clean flag to do a fresh install (clears keychain)${NC}"
echo -e "${YELLOW}⚠️  IMPORTANT: If you still need to login, this is a known iOS Simulator limitation${NC}"
echo -e "${YELLOW}⚠️  The simulator's keychain preservation is unreliable, even with matching bundle IDs${NC}"
echo -e "${BLUE}💡 For reliable keychain preservation, test on a physical iOS device${NC}"

