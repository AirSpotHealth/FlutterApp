# AirSpot Health - Development Guide

## Quick Start

1. **Setup Environment**

   ```bash
   # Copy configuration files
   cp env.example .env
   cp android/key.properties.example android/key.properties

   # Edit with your values
   nano .env
   nano android/key.properties
   ```

2. **Run the App**

   - **VS Code**: Press F5 and select "AirSpot Health (Debug with Env)"
   - **Command Line**: `flutter run --dart-define-from-file=.env`

3. **Build the App**

   ```bash
   # Using build script
   ./scripts/build_with_env.sh android debug

   # Manual build
   flutter build apk --dart-define-from-file=.env
   ```

## Environment Variables

The app uses environment variables for configuration. Copy `env.example` to `.env` and fill in your values:

```bash
# API Configuration
API_KEY=your_api_key_here
API_BASE_URL=https://update.airspothealth.com/api
MAP_URL=https://map.airspothealth.com/
SOLUTIONS_URL=https://airspothealth.com/a/blog/category/

# Map Handoff Service
MAP_HMAC_KEY=your_map_hmac_key_here
MAP_HMAC_KID=map-key-2025-01

# Bluetooth Configuration
BLUETOOTH_SERVICE_UUID=6E400001-B5A3-F393-E0A9-E50E24DCCA9E
BLUETOOTH_NOTIFY_UUID=6E400003-B5A3-F393-E0A9-E50E24DCCA9E
BLUETOOTH_WRITE_UUID=6E400002-B5A3-F393-E0A9-E50E24DCCA9E
```

## VS Code Launch Configurations

The project includes pre-configured VS Code launch configurations:

| Configuration                               | Description                              | Environment Variables |
| ------------------------------------------- | ---------------------------------------- | --------------------- |
| **AirSpot Health (Debug with Env)**         | Debug mode with environment variables    | ✅ Yes                |
| **AirSpot Health (Debug - No Env)**         | Debug mode without environment variables | ❌ No                 |
| **AirSpot Health (Profile with Env)**       | Profile mode with environment variables  | ✅ Yes                |
| **AirSpot Health (Release with Env)**       | Release mode with environment variables  | ✅ Yes                |
| **AirSpot Health (Android Debug with Env)** | Android-specific debug                   | ✅ Yes                |
| **AirSpot Health (iOS Debug with Env)**     | iOS-specific debug                       | ✅ Yes                |
| **AirSpot Health (Web Debug with Env)**     | Web debug                                | ✅ Yes                |

### Using Launch Configurations

1. Open VS Code
2. Go to **Run and Debug** panel (Ctrl+Shift+D)
3. Select your desired configuration
4. Press F5 or click the play button

### Regenerate Launch Configurations

```bash
python3 scripts/generate_launch_config.py
```

## Building

### Using Build Scripts

```bash
# Android builds
./scripts/build_with_env.sh android debug
./scripts/build_with_env.sh android release
./scripts/build_with_env.sh android bundle

# iOS builds
./scripts/build_with_env.sh ios debug
./scripts/build_with_env.sh ios release
```

### Manual Build Commands

```bash
# Debug
flutter run --dart-define-from-file=.env

# Release
flutter build apk --dart-define-from-file=.env
flutter build ios --dart-define-from-file=.env
```

## Security

- **Never commit** `.env`, `android/key.properties`, or `android/upload-keystore.jks`
- The app uses default values if environment variables are missing
- For production builds, always use proper keystore credentials

## Troubleshooting

### Launch Configuration Not Working

1. Ensure `.env` file exists in project root
2. Regenerate: `python3 scripts/generate_launch_config.py`

### Environment Variables Not Loading

1. Verify `.env` file format (no spaces around `=`)
2. Check that variables are not commented out (`#`)

### Build Errors

1. Ensure all required environment variables are set
2. Check that keystore file exists and credentials are correct
3. Verify Flutter SDK version compatibility
