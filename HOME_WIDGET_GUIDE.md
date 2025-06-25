# AirSpot Health Home Widget Guide

## Overview

The AirSpot Health app now includes enhanced home widgets that display CO₂ PPM values from your connected devices directly on your home screen. The widgets feature a modern, beautiful design with support for both single and multiple device monitoring, depending on widget size.

## Features

- **Adaptive Layout**: Small widgets show primary device, large widgets show up to 3 devices
- **Real-time CO₂ Display**: Shows current CO₂ values with color-coded indicators
- **Refresh Button**: Manually refresh CO₂ readings with a single tap
- **Automatic Updates**: Widgets update automatically when new CO₂ data is received
- **Multi-Device Support**: Large widgets display multiple connected devices
- **Beautiful Modern UI**: Gradient backgrounds with clean, readable text and modern styling

## Widget Sizes

### Small Widget (2x1)

- Displays primary/first connected device
- Shows CO₂ value with color coding
- Device name and refresh button
- Compact design perfect for smaller spaces

### Large Widget (4x2 or larger)

- Displays up to 3 connected devices simultaneously
- Each device shows name, status, and CO₂ value
- Global refresh button for all devices
- Card-based layout with individual device information

## Color Coding

The CO₂ values are color-coded based on air quality levels:

- **Green** (< 800 ppm): Good air quality
- **Orange** (800-999 ppm): Moderate air quality
- **Red** (≥ 1000 ppm): Poor air quality

## How to Add the Widget

### Android

1. Long-press on your home screen
2. Select "Widgets" from the menu
3. Find "AirSpot Health" in the widget list
4. Drag the "CO₂ Widget" to your desired location
5. Resize the widget by dragging corners:
   - **Small size**: Single device view
   - **Large size**: Multi-device view
6. The widget will automatically adapt its layout based on size

### iOS

1. Long-press on your home screen until apps start wiggling
2. Tap the "+" button in the top-left corner
3. Search for "AirSpot Health"
4. Choose between widget sizes:
   - **Small**: Single device monitoring
   - **Medium/Large**: Multi-device monitoring
5. Tap "Add Widget"

## Widget Functionality

### Automatic Updates

- The widget automatically updates when:
  - New CO₂ data is received from any device
  - Devices connect or disconnect
  - The app starts or resumes
  - Widget size changes (adapts layout automatically)

### Manual Refresh

- **Small Widget**: Tap the refresh button (↻) to refresh the primary device
- **Large Widget**: Tap the global refresh button to refresh all connected devices
- The widget will update with new values once received from devices

### Multi-Device Management

- Large widgets automatically display all connected devices (up to 3)
- Devices are shown in connection order
- Each device displays its own CO₂ value and status
- If fewer than 3 devices are connected, unused slots are hidden

## Device Status Indicators

- **Connected**: Device is actively connected via Bluetooth
- **Primary**: The main device used for small widget display
- Device names are automatically truncated if too long

## Widget Design Features

- **Modern Gradient Background**: Beautiful blue-purple gradient
- **Card-based Layout**: Clean separation of device information
- **Rounded Corners**: Modern, friendly appearance
- **Semi-transparent Elements**: Subtle depth and layering
- **Adaptive Typography**: Optimal text sizes for different widget sizes

## Troubleshooting

### Widget Not Updating

1. Ensure the AirSpot Health app is running in the background
2. Check that your devices are connected via Bluetooth
3. Try manually refreshing using the refresh button
4. Restart the app if needed

### Widget Shows "----"

This means no CO₂ data is available:

1. Connect your AirSpot device(s) via Bluetooth
2. Wait for the initial data sync
3. Tap the refresh button to request new data

### Large Widget Shows Fewer Devices

This is normal behavior:

1. Large widget only shows currently connected devices
2. Maximum of 3 devices are displayed
3. Disconnect and reconnect devices if they're not appearing

### Widget Size Not Changing Layout

1. Try resizing the widget manually
2. Remove and re-add the widget
3. Ensure you have the latest app version

## Technical Details

### Data Storage

- Widget data is stored using the `home_widget` package
- CO₂ values are automatically saved when received
- Multiple device data is stored separately for large widgets
- Last update timestamp is maintained for reference

### Background Updates

- The widget uses background callbacks for refresh requests
- Deep linking is used to communicate between widget and app
- Automatic updates occur when the app processes new BLE data
- Widget layout adapts automatically to size changes

### Privacy

- All data remains on your device
- No cloud synchronization for widget data
- Widget data is cleared when the app is uninstalled

## Widget Configuration

### In-App Controls

Visit the home screen in the app to see:

- Current widget status for both small and large widgets
- Connected devices list with real-time CO₂ values
- Manual refresh and initialization controls
- Visual preview of widget layouts

### Device Priority

- Small widgets always show the first connected device
- Large widgets show devices in connection order
- Primary device can be changed by disconnecting and reconnecting

## Development Notes

### Files Modified/Created

- `lib/core/services/home_widget_service.dart` - Enhanced for multi-device support
- `lib/core/providers/home_widget_provider.dart` - Multi-device data management
- `android/app/src/main/res/layout/co2_value_widget_small.xml` - Small widget layout
- `android/app/src/main/res/layout/co2_value_widget_large.xml` - Large widget layout
- `android/app/src/main/java/com/air/spot/airspothealth/Co2ValueWidget.java` - Enhanced Android widget with size detection
- Modern drawable resources for beautiful backgrounds

### Dependencies

- `home_widget: ^0.8.0` - Core widget functionality
- Uses existing BLE communication infrastructure
- Integrates with Riverpod state management
- Supports dynamic layout switching

### Widget Size Detection

- Automatic layout switching based on widget dimensions
- Threshold: 200dp width or 100dp height triggers large layout
- `onAppWidgetOptionsChanged` handles size changes dynamically

## Support

For issues or questions regarding the enhanced home widgets:

1. Check the troubleshooting section above
2. Use the in-app widget demo for testing functionality
3. Ensure you have the latest app version
4. Contact AirSpot Health support if problems persist

## What's New in This Version

- ✨ **Multi-Device Support**: Large widgets can show up to 3 devices
- 🎨 **Modern UI Design**: Beautiful gradient backgrounds and card layouts
- 📱 **Adaptive Layouts**: Automatic switching between small and large layouts
- 🔄 **Enhanced Refresh**: Individual and global refresh capabilities
- 📊 **Better Status Display**: Clear device status and connection indicators
