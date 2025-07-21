# Android Foreground Notification Implementation

## Overview

This implementation adds a persistent foreground notification for Android that mimics the iOS Live Activity functionality. The notification shows real-time CO2 data and can be toggled from the same button used for iOS Live Activity.

## Key Components

### 1. ForegroundNotificationService.java

- Main service that creates and manages the persistent notification
- Shows CO2 value, device info, battery status, and CO2 history graph
- Supports both compact and expanded notification layouts
- Automatically updates when new data is received

### 2. Notification Layouts

- **notification_compact.xml**: Simple layout showing CO2, device name, and battery
- **notification_expanded.xml**: Detailed layout with graph, status icons, and refresh button

### 3. Updated MainActivity.kt

- Added method channel handler for `liveActivityChannel`
- Maps iOS Live Activity methods to Android notification service:
  - `startLiveActivity` → Start foreground service
  - `updateLiveActivity` → Update notification
  - `endLiveActivity` → Stop foreground service
  - `isLiveActivityActive` → Check service status

### 4. Updated AndroidManifest.xml

- Added necessary permissions:
  - `FOREGROUND_SERVICE`
  - `FOREGROUND_SERVICE_DATA_SYNC`
  - `POST_NOTIFICATIONS`
  - `WAKE_LOCK`
- Registered `ForegroundNotificationService`

### 5. Updated LiveActivityService.dart

- Enhanced to support both iOS and Android platforms
- Platform-specific logging and error handling
- Same API for both platforms

### 6. Updated LiveActivitySettingWidget.dart

- Dynamic title based on platform:
  - iOS: "Live Activity"
  - Android: "Persistent Notification"
- Single toggle controls both iOS Live Activity and Android notification

### 7. Updated BLE Communication Provider

- Enhanced to handle both platforms when Live Activity setting is enabled
- For Android: Updates both widget AND notification service
- For iOS: Updates Live Activity as before

### 8. Updated HomeWidgetService.dart

- Added automatic notification update when widget data changes
- Uses method channel to trigger Android notification updates

## Data Flow

1. **User toggles Live Activity setting**

   - iOS: Starts/stops Live Activity
   - Android: Starts/stops foreground notification service

2. **New CO2 data received via BLE**

   - Data processed in BleDeviceCommunicationProvider
   - Widget data updated via HomeWidgetService
   - If Live Activity enabled:
     - iOS: LiveActivityService.updateLiveActivity()
     - Android: LiveActivityService.updateLiveActivity() + HomeWidgetService triggers notification update

3. **Widget/Notification refresh requested**
   - Widget/notification refresh button pressed
   - HomeWidgetService.\_backgroundCallback() handles refresh
   - Sends BLE command to get fresh CO2 data
   - New data flows through normal update process

## Features

### Notification Features

- **Real-time CO2 value** with color coding (green/orange/red)
- **Device information** (name, power mode, battery level)
- **Status indicators** (alarm on/off, vibration on/off, charging status)
- **CO2 history graph** (same as iOS Live Activity)
- **Action buttons**:
  - Refresh: Get latest CO2 reading
  - Open App: Launch main app
  - Stop: End notification service
- **Expandable layout** (compact view + detailed expanded view)

### Technical Features

- **Foreground service** ensures notification persists
- **Low priority** notification (doesn't interrupt user)
- **Custom layouts** with dynamic content
- **Graph generation** using Canvas API (matches iOS implementation)
- **Background refresh** capability
- **Platform-unified API** (same code path for iOS/Android in Flutter)

## Usage

1. Go to Device Settings
2. Toggle "Live Activity" (iOS) or "Persistent Notification" (Android)
3. Notification appears showing current CO2 data
4. Notification updates automatically as new data arrives
5. Use refresh button for manual updates
6. Toggle off to stop the notification service

## Benefits

- **Unified user experience** across iOS and Android
- **Consistent feature set** between platforms
- **Always visible CO2 monitoring** without opening the app
- **Interactive controls** for quick actions
- **Battery efficient** (low priority, minimal wake-ups)
- **Maintains existing widget functionality**

## Files Created/Modified

### New Files

- `ForegroundNotificationService.java`
- `notification_compact.xml`
- `notification_expanded.xml`
- `circular_button_background.xml`
- `ic_refresh.xml`
- `ic_open_app.xml`
- `ic_close.xml`
- `ic_stat_name.xml`

### Modified Files

- `MainActivity.kt` - Added method channel support
- `AndroidManifest.xml` - Added permissions and service registration
- `LiveActivityService.dart` - Enhanced platform support
- `live_activity_setting_widget.dart` - Platform-specific UI
- `ble_device_communication_provider.dart` - Android notification integration
- `home_widget_service.dart` - Auto-notification updates

This implementation provides a comprehensive solution that brings iOS Live Activity-like functionality to Android while maintaining code reuse and a unified API.
