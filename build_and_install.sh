#!/bin/bash

# Build and Install Script for Lingugram iOS App
# This script builds the app and installs it on the iPhone 17 Pro simulator

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCHEME="Lingugram"
PROJECT="Lingugram.xcodeproj"
SIMULATOR="iPhone 17 Pro"
DERIVED_DATA_PATH="./build"

echo -e "${GREEN}🚀 Starting build and install process...${NC}\n"

# Step 1: Build the app
echo -e "${YELLOW}📦 Building the app...${NC}"
xcodebuild -project "$PROJECT" \
           -scheme "$SCHEME" \
           -destination "platform=iOS Simulator,name=$SIMULATOR" \
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

# Step 2: Find the built app
echo -e "${YELLOW}🔍 Looking for built app...${NC}"
APP_PATH=$(find "$DERIVED_DATA_PATH/Build/Products" -name "Lingugram.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found app at: $APP_PATH${NC}\n"

# Step 3: Install on simulator
echo -e "${YELLOW}📱 Installing app on $SIMULATOR...${NC}"
xcrun simctl install "$SIMULATOR" "$APP_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Installation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App installed successfully!${NC}\n"

# Step 4: Optional - Launch the app
read -p "Do you want to launch the app? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚀 Launching app...${NC}"
    xcrun simctl launch --console "$SIMULATOR" io.element.elementx 2>&1 | head -10
    echo -e "${GREEN}✅ App launched!${NC}"
fi

echo -e "\n${GREEN}🎉 Done!${NC}"

