#!/bin/bash

# AirSpot Health - Build Script with Environment Variables
# This script loads environment variables from .env file and builds the app

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 AirSpot Health Build Script${NC}"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from example...${NC}"
    if [ -f "env.example" ]; then
        cp env.example .env
        echo -e "${YELLOW}📝 Please edit .env file with your actual values before building${NC}"
        exit 1
    else
        echo -e "${RED}❌ env.example file not found. Cannot create .env file${NC}"
        exit 1
    fi
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}⚠️  android/key.properties not found. Creating from example...${NC}"
    if [ -f "android/key.properties.example" ]; then
        cp android/key.properties.example android/key.properties
        echo -e "${YELLOW}📝 Please edit android/key.properties with your keystore credentials${NC}"
    else
        echo -e "${RED}❌ android/key.properties.example not found${NC}"
        exit 1
    fi
fi

# Function to build with environment variables
build_with_env() {
    local platform=$1
    local build_type=$2
    
    echo -e "${GREEN}🔨 Building $platform ($build_type) with environment variables...${NC}"
    
    case $platform in
        "android")
            case $build_type in
                "debug")
                    flutter build apk --debug --dart-define-from-file=.env
                    ;;
                "release")
                    flutter build apk --release --dart-define-from-file=.env
                    ;;
                "bundle")
                    flutter build appbundle --release --dart-define-from-file=.env
                    ;;
                *)
                    echo -e "${RED}❌ Invalid build type: $build_type. Use: debug, release, or bundle${NC}"
                    exit 1
                    ;;
            esac
            ;;
        "ios")
            case $build_type in
                "debug")
                    flutter build ios --debug --dart-define-from-file=.env
                    ;;
                "release")
                    flutter build ios --release --dart-define-from-file=.env
                    ;;
                *)
                    echo -e "${RED}❌ Invalid build type: $build_type. Use: debug or release${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}❌ Invalid platform: $platform. Use: android or ios${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <platform> <build_type>"
    echo "Platforms: android, ios"
    echo "Build types: debug, release, bundle (android only)"
    echo ""
    echo "Examples:"
    echo "  $0 android debug"
    echo "  $0 android release"
    echo "  $0 android bundle"
    echo "  $0 ios release"
    exit 1
fi

PLATFORM=$1
BUILD_TYPE=$2

# Run the build
build_with_env $PLATFORM $BUILD_TYPE
