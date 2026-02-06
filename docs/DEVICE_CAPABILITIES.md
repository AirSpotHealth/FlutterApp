# AirSpot Device Capabilities

This document outlines the feature differences and capabilities of the various AirSpot device models to ensure consistent UI logic and behavior across the application.

## Device Models

### 1. AirSpot Screen (Default)

The original AirSpot device featuring an e-ink display, buzzer, and vibration motor.

**Capabilities:**

- **Screen**: Yes (E-ink display)
- **Controls**: Alarm (Buzzer), Vibrate
- **Sensors**: CO2, Temperature, Humidity, Pressure
- **Flight Mode**: Manual toggle (User controlled)
- **Do Not Disturb**: Supported (Silences persistent alarms/vibrations)

### 2. AirSpot Slim

A compact version without a screen, utilizing LED indicators for status.

**Capabilities:**

- **Screen**: No
- **Controls**: None (No buzzer, No vibration motor)
- **Sensors**: CO2, Temperature, Humidity, Pressure
- **Flight Mode**: Auto-calculated (Based on pressure sensors) - _No manual toggle UI_
- **Do Not Disturb**: Not supported (No audio/haptic feedback to silence)

## UI Feature Matrix

| Feature / Setting Group | Setting Item           | AirSpot Screen | AirSpot Slim |
| :---------------------- | :--------------------- | :------------: | :----------: |
| **Device Controls**     | Alarm                  |       ✅       |      ❌      |
|                         | Vibrate                |       ✅       |      ❌      |
|                         | Auto Connect           |       ✅       |      ✅      |
| **Sensor & Display**    | Time Settings          |       ✅       |      ❌      |
|                         | CO2 Reading Rate       |       ✅       |      ✅      |
|                         | Device Screen Settings |       ✅       |      ❌      |
|                         | Notification Settings  |       ✅       |      ✅      |
| **Focus**               | Do Not Disturb         |       ✅       |      ❌      |
| **System & Support**    | Device Update          |       ✅       |      ✅      |
|                         | Calibrate Device       |       ✅       |      ✅      |
|                         | Locate my AirSpot      |       ✅       |      ✅      |
| **Actions**             | Flight Mode            |  ✅ (Manual)   |  ❌ (Auto)   |
|                         | Disconnect             |       ✅       |      ✅      |
|                         | Forget Device          |       ✅       |      ✅      |
|                         | Power Off              |       ✅       |      ✅      |

## Implementation Logic

The application logic should determine the device type (stored in `BleDevice`) and check against these capabilities before rendering settings tiles.

**Default Behavior:**
If `deviceType` is unknown, assume **AirSpot Screen** (Full capabilities).
