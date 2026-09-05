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

# Warn if xcode-select points at Xcode 26.4 without the iOS 26.4 platform (use 26.5)
if command -v xcode-select &>/dev/null; then
  xcode_path="$(xcode-select -p 2>/dev/null || true)"
  if [[ "$xcode_path" == *"Xcode-26.4"* ]] && [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
    echo -e "${YELLOW}⚠️  xcode-select uses Xcode 26.4; iOS device builds need Xcode 26.5.${NC}"
    echo -e "${YELLOW}   Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer${NC}"
    echo -e "${YELLOW}   Or: source scripts/use_xcode_26_5.sh before flutter run${NC}"
  fi
fi

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

# nordic_dfu 7.1.2 SPM package name fix (required for iOS builds with isar SPM)
if [ -f "tool/patch_nordic_dfu_spm.sh" ]; then
  echo -e "${BLUE}🔧 Patching nordic_dfu Swift Package Manager metadata...${NC}"
  ./tool/patch_nordic_dfu_spm.sh
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Edit .env file with your API keys and configuration"
echo "2. Edit android/key.properties with your keystore credentials"
echo "3. Open VS Code and press F5 to run the app"
echo "4. Or run: flutter run --dart-define-from-file=.env"
echo ""
echo -e "${BLUE}For detailed instructions, see: docs/DEVELOPMENT.md${NC}"
