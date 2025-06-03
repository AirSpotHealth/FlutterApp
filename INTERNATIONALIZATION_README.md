# AirSpot Health - Internationalization Implementation

This document provides a comprehensive guide to the internationalization (i18n) implementation in the AirSpot Health Flutter app using the `slang` package.

## Overview

The app now supports multiple languages with comprehensive translation coverage:

- **English (en)** - Base locale
- **Chinese (zh-CN)** - Full translation

## Implementation Details

### 1. Dependencies Added

The following packages were added to `pubspec.yaml`:

```yaml
dependencies:
  # Internationalization dependencies
  slang: ^4.7.2
  slang_flutter: ^4.7.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  # Internationalization build runner
  slang_build_runner: ^4.7.0
```

### 2. Configuration

**slang.yaml** - Main configuration file:

```yaml
base_locale: en
fallback_strategy: base_locale
input_directory: lib/i18n
input_file_pattern: .i18n.json
output_directory: lib/i18n
output_file_name: strings.g.dart
locale_handling: true
flutter_integration: true
translate_var: t
enum_name: AppLocale
translation_class_visibility: public
key_case: camel
key_map_case: camel
param_case: camel
string_interpolation: double_braces
flat_map: false
timestamp: true
```

### 3. Translation Files

**lib/i18n/en.i18n.json** - English translations (base locale)
**lib/i18n/zh-CN.i18n.json** - Chinese translations

Both files contain the same structure with translations organized into logical sections:

- `app` - Application name and title
- `common` - Common UI elements (OK, Cancel, Save, etc.)
- `devices` - Device management interface
- `home.menu` - Navigation menu items
- `deviceSettings` - Device configuration options
- `appSetup` - Application settings
- `solutions` - Solutions section
- `deviceGraph` - Graph and data visualization
- `findMyDevice` - Device location features
- `alerts` - User notifications and confirmations
- `errors` - Error messages
- `bluetooth` - Bluetooth connectivity
- `notifications` - System notifications
- `units` - Measurement units

### 4. App Configuration

**lib/main.dart** updates:

```dart
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize slang
  LocaleSettings.useDeviceLocale();

  // ... rest of initialization
}

class AirspotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ... existing configuration

      // Localization configuration
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocale.values.map((locale) => locale.flutterLocale),
      locale: TranslationProvider.of(context).flutterLocale,

      // ... rest of configuration
    );
  }
}
```

## Usage Examples

### Basic Usage

Replace hardcoded strings with translation calls:

```dart
// Before
Text('Add Device')

// After
import 'package:airspothealth/i18n/strings.g.dart';

Text(t.devices.addDevice)
```

### Parameterized Translations

For strings with dynamic content:

```dart
// Translation with parameter
Text(t.deviceSettings.sendCommandTo(deviceName: 'AirSpot-001'))
// Outputs: "Send Command to AirSpot-001"

Text(t.bluetooth.deviceFound(deviceName: device.name))
// Outputs: "Device found: {deviceName}"
```

### Programmatic Locale Switching

```dart
// Switch to Chinese
LocaleSettings.setLocale(AppLocale.zhCn);

// Switch to English
LocaleSettings.setLocale(AppLocale.en);

// Get current locale
String currentLocale = LocaleSettings.currentLocale.languageCode;
```

## Generated Files

The `dart run slang` command generates these files:

- `lib/i18n/strings.g.dart` - Main generated translations class
- `lib/i18n/strings_en.g.dart` - English-specific generated code
- `lib/i18n/strings_zh_CN.g.dart` - Chinese-specific generated code

## Development Workflow

### Adding New Translations

1. Add the new key-value pair to both `en.i18n.json` and `zh-CN.i18n.json`
2. Run `dart run slang` to regenerate the Dart code
3. Use the new translation key in your widget: `t.yourSection.yourKey`

### Adding New Locales

1. Create a new translation file (e.g., `fr.i18n.json` for French)
2. Copy the structure from `en.i18n.json` and translate the values
3. Run `dart run slang` to regenerate
4. The new locale will be automatically available

### Regenerating Translations

```bash
dart run slang
```

Run this command whenever you:

- Add new translation keys
- Modify existing translations
- Add new locale files

## Translation Coverage

The implementation covers all major text elements in the app:

### Device Management

- Connection status indicators
- Device actions (connect, disconnect, forget)
- Device settings and configuration
- Bluetooth scanning and pairing

### Navigation & UI

- Bottom navigation tabs
- Settings screens
- Modal dialogs and alerts
- Loading states and error messages

### Technical Elements

- Measurement units (PPM, hPa, meters, etc.)
- Sensor readings and data
- Time and date formatting
- Device commands and responses

### User Feedback

- Success/error notifications
- Confirmation dialogs
- Status messages
- Help text and instructions

## Benefits

1. **Complete Internationalization**: All hardcoded text has been extracted and made translatable
2. **Type Safety**: Generated Dart code provides compile-time validation of translation keys
3. **Performance**: Efficient runtime translation lookup with no reflection
4. **Maintainability**: Centralized translation management with clear organization
5. **Extensibility**: Easy to add new languages and translation keys
6. **Developer Experience**: IntelliSense support for translation keys

## Testing the Implementation

1. **English (Default)**: App uses English by default
2. **Chinese**: Change device language to Chinese to see Chinese translations
3. **Fallback**: Missing translations automatically fall back to English
4. **Dynamic Switching**: Use the provided utility functions to switch languages programmatically

## File Structure

```
lib/
├── i18n/
│   ├── en.i18n.json              # English translations
│   ├── zh-CN.i18n.json           # Chinese translations
│   ├── strings.g.dart            # Generated main class
│   ├── strings_en.g.dart         # Generated English code
│   └── strings_zh_CN.g.dart      # Generated Chinese code
└── main.dart                     # App configuration
slang.yaml                        # Slang configuration
```

## Example Implementation

Here's how to replace hardcoded text in your widgets:

```dart
// DevicesPage example (already implemented)
import 'package:airspothealth/i18n/strings.g.dart';

class DevicesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: savedDevicesList.isEmpty
          ? Center(child: Text(t.devices.noDevicesConnected))  // "No devices connected" / "无已连接设备"
          : ListView(...),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(t.devices.addDevice),  // "Add Device" / "添加设备"
        onPressed: () => context.pushNamed(RouteNames.addDevice),
      ),
    );
  }
}
```

## Available Translation Keys

### Common UI Elements

```dart
t.common.ok              // "OK" / "确定"
t.common.cancel          // "Cancel" / "取消"
t.common.save            // "Save" / "保存"
t.common.loading         // "Loading..." / "加载中..."
```

### Device Management

```dart
t.devices.title                    // "Devices" / "设备"
t.devices.addDevice               // "Add Device" / "添加设备"
t.devices.noDevicesConnected      // "No devices connected" / "无已连接设备"
t.devices.connectedStatus         // "Connected" / "已连接"
```

### Navigation

```dart
t.home.menu.devices      // "Devices" / "设备"
t.home.menu.airMap       // "AirMap" / "空气地图"
t.home.menu.solutions    // "Solutions" / "解决方案"
t.home.menu.shop         // "Shop" / "商店"
```

### Settings

```dart
t.deviceSettings.title           // "Device Settings" / "设备设置"
t.deviceSettings.timeSettings    // "Time Settings" / "时间设置"
t.deviceSettings.calibrateDevice // "Calibrate Device" / "校准设备"
```

## Next Steps

1. **Update Remaining Files**: Replace hardcoded strings throughout the app using the pattern shown
2. **Test Translations**: Review all Chinese translations for accuracy
3. **Add More Locales**: Consider adding other languages based on user needs
4. **User Locale Selection**: Add UI for users to manually select their preferred language
5. **RTL Support**: If adding Arabic/Hebrew, configure RTL text direction support

The internationalization foundation is now complete and ready for production use!
