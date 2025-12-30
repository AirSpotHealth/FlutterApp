#!/bin/bash

# AirSpot Health - Safe Shorebird Release Script
# This script validates environment configuration before running Shorebird releases
# to prevent deploying dev URLs to production.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ENV_FILE=".env.local"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🚀 AirSpot Health - Shorebird Release Script         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Pre-flight checks
# ─────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}🔍 Running pre-flight checks...${NC}"
echo ""

# Check if shorebird CLI is available
if ! command -v shorebird &> /dev/null; then
    echo -e "${RED}❌ Error: 'shorebird' CLI is not installed or not in PATH${NC}"
    echo -e "   Install it from: https://docs.shorebird.dev"
    exit 1
fi
echo -e "${GREEN}  ✓ Shorebird CLI found${NC}"

# Check if .env.local exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}❌ Error: $ENV_FILE not found${NC}"
    echo -e "   Please create $ENV_FILE from env.example before releasing"
    exit 1
fi
echo -e "${GREEN}  ✓ $ENV_FILE exists${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Dev URL Detection
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}🔒 Checking for development URLs...${NC}"
echo ""

# Patterns that indicate dev/local environments
DEV_PATTERNS=(
    "192\.168\."
    "10\.0\.2\.2"
    "localhost"
    "127\.0\.0\.1"
    "0\.0\.0\.0"
    ":8080"
    ":8081"
    ":3000"
    ":5000"
)

FOUND_DEV_URLS=0

for pattern in "${DEV_PATTERNS[@]}"; do
    matches=$(grep -in "$pattern" "$ENV_FILE" 2>/dev/null || true)
    if [ -n "$matches" ]; then
        if [ $FOUND_DEV_URLS -eq 0 ]; then
            echo -e "${RED}❌ BLOCKING: Development URLs detected in $ENV_FILE:${NC}"
            echo ""
        fi
        FOUND_DEV_URLS=1
        while IFS= read -r line; do
            echo -e "   ${RED}Line: $line${NC}"
        done <<< "$matches"
    fi
done

if [ $FOUND_DEV_URLS -eq 1 ]; then
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ⛔ RELEASE BLOCKED: Dev URLs would be deployed to production  ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Please update $ENV_FILE with production URLs before releasing.${NC}"
    echo -e "${YELLOW}Example production values (from env.example):${NC}"
    echo ""
    echo "   API_BASE_URL=https://update.airspothealth.com/api"
    echo "   MAP_URL=https://map.airspothealth.com/"
    echo ""
    exit 1
fi

echo -e "${GREEN}  ✓ No development URLs found${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Required Variables Check
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}📋 Validating required environment variables...${NC}"
echo ""

REQUIRED_VARS=(
    "API_KEY"
    "API_BASE_URL"
    "MAP_URL"
    "SOLUTIONS_URL"
    "MAP_HMAC_KEY"
    "MAP_HMAC_KID"
    "BLUETOOTH_SERVICE_UUID"
    "BLUETOOTH_NOTIFY_UUID"
    "BLUETOOTH_WRITE_UUID"
)

MISSING_VARS=0

for var in "${REQUIRED_VARS[@]}"; do
    # Check if variable exists and is not empty/placeholder
    value=$(grep "^$var=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2- || true)
    
    if [ -z "$value" ]; then
        echo -e "${RED}  ✗ Missing: $var${NC}"
        MISSING_VARS=1
    elif [[ "$value" == *"your_"* ]] || [[ "$value" == *"_here"* ]]; then
        echo -e "${RED}  ✗ Placeholder value: $var${NC}"
        MISSING_VARS=1
    else
        echo -e "${GREEN}  ✓ $var${NC}"
    fi
done

if [ $MISSING_VARS -eq 1 ]; then
    echo ""
    echo -e "${RED}❌ Release blocked: Missing or placeholder environment variables${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Show current configuration
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}📍 Current API Configuration:${NC}"
echo ""
grep -E "^(API_BASE_URL|MAP_URL|SOLUTIONS_URL)=" "$ENV_FILE" | while read -r line; do
    echo -e "   ${line}"
done

# ─────────────────────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────────────────────

if [ $# -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}Usage: $0 <platform>${NC}"
    echo ""
    echo "Platforms:"
    echo "  android  - Release Android APK via Shorebird"
    echo "  ios      - Release iOS via Shorebird"
    echo ""
    echo "Examples:"
    echo "  $0 android"
    echo "  $0 ios"
    exit 1
fi

PLATFORM=$1

# ─────────────────────────────────────────────────────────────────────────────
# Flutter analyze (optional - comment out to skip)
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}🔬 Running Flutter analyze...${NC}"
echo ""

if ! flutter analyze --no-fatal-infos --no-fatal-warnings; then
    echo ""
    echo -e "${RED}❌ Flutter analyze found issues. Fix them before releasing.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Flutter analyze passed${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Confirmation prompt
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ All pre-flight checks passed!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  You are about to release to PRODUCTION for: ${GREEN}$PLATFORM${NC}"
echo ""
read -p "Type 'release' to confirm and proceed: " confirmation

if [ "$confirmation" != "release" ]; then
    echo ""
    echo -e "${YELLOW}Release cancelled.${NC}"
    exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Execute Shorebird release
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}🚀 Starting Shorebird release for $PLATFORM...${NC}"
echo ""

case $PLATFORM in
    "android")
        shorebird release android --artifact apk -- --dart-define-from-file=$ENV_FILE
        ;;
    "ios")
        shorebird release ios -- --dart-define-from-file=$ENV_FILE
        ;;
    *)
        echo -e "${RED}❌ Invalid platform: $PLATFORM${NC}"
        echo "Use: android or ios"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          🎉 Shorebird release completed successfully!       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
