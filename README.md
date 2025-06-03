# AirSpot Health 🌬️

Air-Spot Health mobile application for real-time air quality monitoring and device management.

![Flutter](https://img.shields.io/badge/Flutter-3.5.3-blue.svg)
![Dart](https://img.shields.io/badge/Dart-SDK-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## 📱 Overview

AirSpot Health is a comprehensive Flutter mobile application designed to monitor air quality through Bluetooth-connected AirSpot devices. The app provides real-time CO₂ readings, device management, data visualization, and comprehensive health insights to help users maintain optimal indoor air quality.

## ✨ Features

### 🔗 Device Management

- **Bluetooth Connectivity**: Seamless pairing and management of AirSpot devices
- **Multi-Device Support**: Connect and monitor up to 4 devices simultaneously
- **Auto-Connect**: Automatic reconnection to previously paired devices
- **Device Settings**: Comprehensive configuration options for each device

### 📊 Data Monitoring

- **Real-Time Readings**: Live CO₂ concentration monitoring (PPM)
- **Historical Data**: Comprehensive data logging and visualization
- **Interactive Graphs**: Detailed charts with customizable time ranges
- **Data Export**: CSV export functionality for further analysis

### ⚙️ Device Configuration

- **Calibration**: Manual and automatic sensor calibration
- **Alarm Settings**: Customizable CO₂ level alerts (Amber/Red thresholds)
- **Time Synchronization**: Device time management and sync
- **Power Management**: Battery monitoring and power mode settings
- **Sensor Configuration**: Advanced sensor parameter adjustment

### 🌍 Internationalization

- **Multi-Language Support**: English and Chinese (Simplified)
- **Automatic Locale Detection**: Uses device language settings
- **Type-Safe Translations**: Compile-time validation of translation keys
- **Extensible**: Easy addition of new languages

### 📍 Additional Features

- **Find My Device**: Locate connected AirSpot devices with audio alerts
- **Firmware Updates**: Over-the-air device firmware updates
- **Data Backup**: Local data storage with Isar database
- **Notifications**: Push notifications for air quality alerts
- **Solutions Hub**: Air quality improvement recommendations
- **News & Updates**: Latest air quality news and app updates

## 🛠️ Technology Stack

### Core Framework

- **Flutter**: 3.5.3+ (Cross-platform mobile development)
- **Dart**: 3.5.3+ (Programming language)

### State Management

- **Riverpod**: 2.6.1 (State management and dependency injection)
- **Flutter Riverpod**: Provider-based reactive programming

### Bluetooth & Hardware

- **Flutter Blue Plus**: 1.35.5 (Bluetooth Low Energy communication)
- **Permission Handler**: 12.0.0 (Device permissions management)

### Data & Storage

- **Isar**: 4.0.3 (High-performance local database)
- **Shared Preferences**: 2.5.3 (Simple key-value storage)
- **Path Provider**: 2.1.5 (File system path access)

### UI & Navigation

- **Go Router**: 15.1.2 (Declarative routing)
- **Material Design**: Flutter's material components
- **Custom Theming**: Consistent design system

### Internationalization

- **Slang**: 4.7.2 (Type-safe internationalization)
- **Flutter Localizations**: Official Flutter i18n support

### Networking & External Integration

- **Dio**: 5.8.0 (HTTP client for API communication)
- **URL Launcher**: 6.3.1 (External URL handling)
- **WebView Flutter**: 4.13.0 (In-app web content)

### Utilities & Tools

- **Package Info Plus**: 8.3.0 (App version and build info)
- **Geolocator**: 14.0.0 (Location services)
- **Share Plus**: 11.0.0 (Content sharing)
- **File Picker**: 10.1.9 (File selection)
- **File Saver**: 0.2.14 (File saving functionality)

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality and utilities
│   ├── models/                    # Data models and entities
│   ├── providers/                 # Global state providers
│   ├── router/                    # Navigation and routing
│   ├── services/                  # Core services (database, notifications)
│   ├── theme/                     # App theming and styling
│   ├── utils/                     # Utility functions and constants
│   └── widgets/                   # Reusable UI components
├── features/                      # Feature-based modules
│   ├── add_device/               # Device pairing and setup
│   ├── devices/                  # Device list and management
│   ├── device_settings/          # Device configuration
│   ├── device_graph/             # Data visualization
│   ├── find_my_device/           # Device location feature
│   ├── home/                     # Main navigation and dashboard
│   └── solutions/                # Air quality solutions
├── i18n/                         # Internationalization
│   ├── en.i18n.json             # English translations
│   ├── zh-CN.i18n.json          # Chinese translations
│   └── strings.g.dart           # Generated translation code
└── main.dart                     # Application entry point

android/                          # Android-specific configuration
ios/                             # iOS-specific configuration
assets/                          # Static assets (images, icons)
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5.3 or higher
- Dart SDK 3.5.3 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (for iOS builds)
- Android development: Android SDK

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd airspothealth
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate internationalization files**

   ```bash
   dart run slang
   ```

4. **Run the application**

   ```bash
   # Development mode
   flutter run

   # Specific platform
   flutter run -d android
   flutter run -d ios
   ```

### Building for Production

#### Android

```bash
# Generate APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release

# Build IPA for App Store
flutter build ipa --release
```

## 🔧 Development Workflow

### Code Generation

```bash
# Generate translation files
dart run slang

# Generate build files
flutter packages pub run build_runner build

# Clean and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Debugging

```bash
# Run with debugging
flutter run --debug

# Profile mode for performance testing
flutter run --profile

# Release mode testing
flutter run --release
```

### Analysis and Testing

```bash
# Code analysis
flutter analyze

# Run tests
flutter test

# Check for dependency updates
flutter pub outdated
```

## 🌍 Internationalization

The app supports multiple languages through the **slang** package:

### Supported Languages

- 🇺🇸 **English** (en) - Base locale
- 🇨🇳 **Chinese Simplified** (zh-CN) - Complete translation

### Adding New Languages

1. Create a new translation file: `lib/i18n/{locale}.i18n.json`
2. Copy the structure from `en.i18n.json`
3. Translate all values to the target language
4. Run `dart run slang` to generate Dart code
5. The new locale will be automatically available

### Usage in Code

```dart
import 'package:airspothealth/i18n/strings.g.dart';

// Basic usage
Text(t.devices.addDevice)

// Parameterized translations
Text(t.bluetooth.deviceFound(deviceName: device.name))

// Programmatic locale switching
LocaleSettings.setLocale(AppLocale.zhCn);
```

For detailed internationalization documentation, see [INTERNATIONALIZATION_README.md](INTERNATIONALIZATION_README.md).

## 📊 Key Components

### Device Communication

- Bluetooth Low Energy (BLE) protocol implementation
- Real-time data streaming from AirSpot devices
- Automatic reconnection and error handling
- Device command and configuration management

### Data Management

- Local storage with Isar database
- Real-time data synchronization
- Historical data retention and cleanup
- Export functionality for data analysis

### User Interface

- Material Design components
- Responsive layouts for different screen sizes
- Dark/light theme support
- Accessibility features

## 🔒 Permissions

### Android

- `BLUETOOTH` - Bluetooth device communication
- `BLUETOOTH_ADMIN` - Bluetooth management
- `ACCESS_FINE_LOCATION` - Required for Bluetooth scanning
- `INTERNET` - Network access for updates and news
- `WRITE_EXTERNAL_STORAGE` - File export functionality

### iOS

- `NSBluetoothAlwaysUsageDescription` - Bluetooth access
- `NSLocationWhenInUseUsageDescription` - Location for Bluetooth
- `NSAppTransportSecurity` - Network security configuration

## 📱 App Store Information

- **Version**: 3.4.10 (Build 108)
- **Minimum SDK**: Android 23 (Android 6.0) / iOS 11.0
- **Target SDK**: Latest Android / iOS versions
- **App Store**: Private distribution

## 🤝 Contributing

### Development Guidelines

1. Follow Flutter/Dart style guidelines
2. Use meaningful commit messages
3. Ensure code analysis passes (`flutter analyze`)
4. Test on both platforms before submitting
5. Update translations when adding new text
6. Document complex functionality

### Code Style

- Use `flutter format` for consistent formatting
- Follow naming conventions (camelCase for variables, PascalCase for classes)
- Add meaningful comments for complex logic
- Keep widgets small and focused

### Adding Features

1. Create feature branch from `develop`
2. Implement feature following project structure
3. Add appropriate tests
4. Update documentation if needed
5. Submit pull request for review

## 📄 Version Information

- **Current Version**: 3.4.10+108
- **Flutter Version**: 3.5.3
- **Dart Version**: 3.5.3

## 🐛 Known Issues

- Some dependency packages have newer versions available (see `flutter pub outdated`)
- Minor deprecation warnings in theme implementation

## 📞 Support

For technical support or bug reports:

- Create an issue in the project repository
- Include device information and reproduction steps
- Attach relevant logs when possible

## 📝 License

This project is proprietary software. All rights reserved.

---

**AirSpot Health** - Breathe Better, Live Better 🌬️✨
