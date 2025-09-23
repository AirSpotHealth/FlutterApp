#!/bin/bash

# AirSpot Health - Initial Setup Script
# This script helps set up the development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 AirSpot Health - Initial Setup${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✅ Flutter is installed${NC}"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creating .env file from template...${NC}"
    if [ -f "env.example" ]; then
        cp env.example .env
        echo -e "${YELLOW}⚠️  Please edit .env file with your actual values${NC}"
    else
        echo -e "${RED}❌ env.example file not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Create Android keystore properties if it doesn't exist
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}📝 Creating Android keystore properties...${NC}"
    if [ -f "android/key.properties.example" ]; then
        cp android/key.properties.example android/key.properties
        echo -e "${YELLOW}⚠️  Please edit android/key.properties with your keystore credentials${NC}"
    else
        echo -e "${RED}❌ android/key.properties.example file not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Android keystore properties already exist${NC}"
fi

# Generate VS Code launch configurations
echo -e "${BLUE}🔧 Generating VS Code launch configurations...${NC}"
if [ -f "scripts/generate_launch_config.py" ]; then
    python3 scripts/generate_launch_config.py
else
    echo -e "${RED}❌ generate_launch_config.py not found${NC}"
    exit 1
fi

# Get Flutter dependencies
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit .env file with your API keys and configuration"
echo "2. Edit android/key.properties with your keystore credentials"
echo "3. Open VS Code and press F5 to run the app"
echo "4. Or run: flutter run --dart-define-from-file=.env"
echo ""
echo -e "${BLUE}For detailed instructions, see: docs/DEVELOPMENT.md${NC}"
