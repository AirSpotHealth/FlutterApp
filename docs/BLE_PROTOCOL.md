# AirSpot Health BLE Protocol Documentation

This document describes the Bluetooth Low Energy (BLE) communication protocol used between the AirSpot Health mobile app and AirSpot devices.

## Table of Contents

1. [Bluetooth Service UUIDs](#bluetooth-service-uuids)
2. [Protocol Overview](#protocol-overview)
3. [Command Structure](#command-structure)
4. [Response Structure](#response-structure)
5. [Data Formats](#data-formats)
6. [Supported Commands](#supported-commands)
7. [Response Commands](#response-commands)
8. [Data Flow](#data-flow)
9. [Device Data Types](#device-data-types)

## Bluetooth Service UUIDs

The AirSpot device uses a custom BLE service with the following UUIDs:

| Component                 | UUID                                   | Description                               |
| ------------------------- | -------------------------------------- | ----------------------------------------- |
| **Service UUID**          | `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` | Main BLE service identifier               |
| **Write Characteristic**  | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | Used to send commands to the device       |
| **Notify Characteristic** | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | Used to receive responses from the device |

These UUIDs can be configured via environment variables:

- `BLUETOOTH_SERVICE_UUID`
- `BLUETOOTH_WRITE_UUID`
- `BLUETOOTH_NOTIFY_UUID`

## Protocol Overview

The communication protocol follows a request-response pattern:

1. **App → Device**: Commands are sent via the Write characteristic
2. **Device → App**: Responses are received via the Notify characteristic (subscription required)

All commands and responses use a binary format with:

- Fixed prefix bytes (`0xFF 0xAA`)
- Command/response identifier
- Payload length
- Payload data
- Checksum byte

## Command Structure

All commands sent to the device follow this structure:

```
[0xFF] [0xAA] [CMD] [LEN] [PAYLOAD...] [CHECKSUM]
```

### Fields

- **Prefix**: `0xFF 0xAA` - Fixed identifier for all commands
- **CMD**: Command byte (see [Supported Commands](#supported-commands))
- **LEN**: Length of payload (1 byte)
- **PAYLOAD**: Variable-length command-specific data
- **CHECKSUM**: Single byte checksum (sum of all bytes before checksum, modulo 256)

### Checksum Calculation

```dart
int checksum = 0;
for (byte in [prefixHigh, prefixLow, cmd, len, ...payload]) {
    checksum = (checksum + byte) & 0xFF;
}
```

## Response Structure

Responses from the device follow a similar structure:

```
[0xFF] [0xAA] [RESPONSE_CMD] [LEN] [PAYLOAD...] [CHECKSUM]
```

### Fields

- **Prefix**: `0xFF 0xAA` - Same as commands
- **RESPONSE_CMD**: Response command byte (see [Response Commands](#response-commands))
- **LEN**: Length of payload
- **PAYLOAD**: Response data (format depends on command)
- **CHECKSUM**: Single byte checksum

## Data Formats

### Timestamps

Timestamps are represented in two ways depending on context:

1. **Unix Timestamp (4 bytes, big-endian)**: Used for time synchronization

   - Seconds since Unix epoch (1970-01-01)
   - Timezone offset is added when sending to device
   - Timezone offset is subtracted when parsing from device

2. **Seconds since 2000-01-01 (4 bytes, big-endian)**: Used for historical data
   - Base date: `2000-01-01 00:00:00 UTC`
   - Used in CO2 history records

### CO2 Values

- **Format**: 2 bytes, big-endian (unsigned 16-bit integer)
- **Range**: 0-65535 ppm
- **Special values**:
  - Values > 33000 and ≤ 65535 are treated as negative (for certain data types)
  - Formula: `value = (highByte << 8) | lowByte`

### Boolean Values

- `0x00` = false
- `0x01` = true

### Two-Byte Integers

- **Format**: 2 bytes, big-endian
- **Formula**: `value = (highByte << 8) | lowByte`

### Float Values

- **Format**: 4 bytes, IEEE 754 single precision, big-endian
- Used for scaling factors and temperature offsets

### Historical Data Record Format

Each historical data record is **8 bytes**:

```
[4 bytes: timestamp] [1 byte: type] [2 bytes: value] [1 byte: reserved]
```

- **Timestamp**: Seconds since 2000-01-01 (4 bytes, big-endian)
- **Type**: Device data type (see [Device Data Types](#device-data-types))
- **Value**: 2-byte value (CO2 ppm, or other depending on type)
- **Reserved**: 1 byte (unused)

## Supported Commands

### Basic Commands

| Command              | CMD Byte | Description                     | Payload  |
| -------------------- | -------- | ------------------------------- | -------- |
| Get CO2              | `0x01`   | Request current CO2 reading     | `[0x01]` |
| Refresh CO2          | `0x21`   | Force CO2 sensor refresh        | `[0x01]` |
| Get Battery Level    | `0x20`   | Request battery level           | `[0x01]` |
| Get Firmware Version | `0x13`   | Request firmware version string | `[0x01]` |
| Get Initial Data     | `0x08`   | Request all device settings     | `[0x01]` |

### Alarm Commands

| Command                  | CMD Byte | Description                   | Payload                                                      |
| ------------------------ | -------- | ----------------------------- | ------------------------------------------------------------ |
| Set Alarm On             | `0x02`   | Enable alarm                  | `[0x01, 0x01]`                                               |
| Set Alarm Off            | `0x02`   | Disable alarm                 | `[0x01, 0x00]`                                               |
| Set Vibration On         | `0x03`   | Enable vibration              | `[0x01, 0x01]`                                               |
| Set Vibration Off        | `0x03`   | Disable vibration             | `[0x01, 0x00]`                                               |
| Set CO2 Threshold        | `0x07`   | Set green/yellow thresholds   | `[0x04, lowHigh, lowLow, medHigh, medLow]`                   |
| Set Screen On Alarm      | `0x2D`   | Enable screen on alarm        | `[0x01, enabled]`                                            |
| Set Alarm On CO2 Fall    | `0x2E`   | Enable alarm on CO2 falling   | `[0x01, enabled]`                                            |
| Set Advanced Alarm Level | `0x2C`   | Set individual alarm level    | `[0x05, index, threshHigh, threshLow, repeatCount, enabled]` |
| Reset Advanced Alarms    | `0x2F`   | Reset to default alarm config | `[0x00]`                                                     |

### Power Mode Commands

| Command         | CMD Byte | Description              | Payload        |
| --------------- | -------- | ------------------------ | -------------- |
| Power On-Demand | `0x05`   | Set on-demand power mode | `[0x01, 0x00]` |
| Power Low       | `0x05`   | Set low power mode       | `[0x01, 0x01]` |
| Power Medium    | `0x05`   | Set medium power mode    | `[0x01, 0x02]` |
| Power High      | `0x05`   | Set high power mode      | `[0x01, 0x03]` |
| Power Off       | `0xEE`   | Turn device off          | `[0x01, 0x01]` |

### Time Commands

| Command  | CMD Byte | Description     | Payload                     |
| -------- | -------- | --------------- | --------------------------- |
| Set Time | `0x04`   | Set device time | `[0x04, timestampBytes...]` |

Timestamp format: 4 bytes (big-endian), Unix epoch seconds + timezone offset

### Display Commands

| Command                    | CMD Byte | Description                 | Payload                                            |
| -------------------------- | -------- | --------------------------- | -------------------------------------------------- |
| Set Continuous Display On  | `0x0E`   | Enable continuous screen    | `[0x01, 0x01]`                                     |
| Set Continuous Display Off | `0x0E`   | Disable continuous screen   | `[0x01, 0x02]`                                     |
| Set Graph Mode             | `0x28`   | Set UI mode and graph range | `[0x05, uiMode, maxHigh, maxLow, minHigh, minLow]` |

### Alias/Name Commands

| Command   | CMD Byte | Description          | Payload               |
| --------- | -------- | -------------------- | --------------------- |
| Get Alias | `0x09`   | Request device alias | `[0x01, 0x01]`        |
| Set Alias | `0x0A`   | Set device alias     | `[len, nameBytes...]` |

### History Commands

| Command                | CMD Byte | Description                | Payload                                      |
| ---------------------- | -------- | -------------------------- | -------------------------------------------- |
| Get CO2 History (Old)  | `0x0C`   | Get history by date range  | `[0x08, startTimestamp..., endTimestamp...]` |
| Get CO2 History (New)  | `0x0C`   | Get history by page number | `[0x02, pageHigh, pageLow]`                  |
| Get Current Flash Page | `0x0B`   | Get current flash page     | `[0x01, 0x00]`                               |
| Erase Data             | `0xFD`   | Erase all stored data      | `[0x01, 0x01]`                               |

### Calibration Commands

| Command                  | CMD Byte | Description                          | Payload                             |
| ------------------------ | -------- | ------------------------------------ | ----------------------------------- |
| Set Auto Calibration     | `0x11`   | Enable auto calibration              | `[0x01, 0x01]`                      |
| Set Manual Calibration   | `0x11`   | Disable auto calibration             | `[0x01, 0x00]`                      |
| Start Recalibration      | `0x0D`   | Start recalibration process          | `[0x00]`                            |
| Set Recalibration Target | `0x0D`   | Set recalibration target             | `[0x02, targetHigh, targetLow]`     |
| Get ASC Data             | `0x25`   | Get ASC (Auto Self Calibration) data | `[0x01, 0x01]`                      |
| Get ASC Day Count        | `0x2A`   | Get days until next ASC              | `[0x01, 0x01]`                      |
| Set ASC Duration         | `0x29`   | Set ASC duration                     | `[0x02, durationHigh, durationLow]` |

### Sensor Commands

| Command            | CMD Byte | Description                | Payload                 |
| ------------------ | -------- | -------------------------- | ----------------------- |
| Get Sensor Details | `0x30`   | Get sensor configuration   | `[0x01, 0x01]`          |
| Reset Sensor       | `0x24`   | Reset sensor               | `[0x01, 0x01]`          |
| Set Scale Factor   | `0x31`   | Set scaling factor         | `[0x04, floatBytes...]` |
| Set Flight Mode    | `0x32`   | Enable/disable flight mode | `[0x01, enabled]`       |

### DND (Do Not Disturb) Commands

| Command   | CMD Byte | Description      | Payload                                              |
| --------- | -------- | ---------------- | ---------------------------------------------------- |
| Set DND   | `0x22`   | Set DND schedule | `[0x05, 0x01, startHour, startMin, endHour, endMin]` |
| Reset DND | `0x22`   | Disable DND      | `[0x01, 0x00]`                                       |

### Bluetooth Commands

| Command         | CMD Byte | Description                     | Payload        |
| --------------- | -------- | ------------------------------- | -------------- |
| Open Bluetooth  | `0x06`   | Enable Bluetooth                | `[0x01, 0x01]` |
| Close Bluetooth | `0x06`   | Disable Bluetooth               | `[0x01, 0x00]` |
| Init Bluetooth  | `0x08`   | Initialize Bluetooth            | `[0x01, 0x01]` |
| Find Device     | `0x10`   | Trigger device location feature | `[0x01, 0x01]` |

### Factory Test Commands

| Command                  | CMD Byte | Description             | Payload             |
| ------------------------ | -------- | ----------------------- | ------------------- |
| Enter Factory Test Mode  | `0xD0`   | Enter factory test mode | `[0x01, 0x01]`      |
| Start Factory Auto Tests | `0xD1`   | Start automated tests   | `[0x01, 0x01]`      |
| Factory Test End         | `0xDE`   | Exit factory test mode  | `[0x01, sleep?]`    |
| Display Screen Test      | `0xDC`   | Test display            | `[0x01, testType]`  |
| Buzzer Test              | `0xDB`   | Test buzzer             | `[0x01, beepCount]` |
| Get Charge Status        | `0xDA`   | Get charging status     | `[0x01, 0x01]`      |
| Get Button Press Count   | `0xD9`   | Get button press count  | `[0x01, 0x01]`      |
| Reset Button Counter     | `0xD8`   | Reset button counter    | `[0x01, 0x01]`      |
| Start Manual Test        | `0xD2`   | Start manual test       | `[0x01, testType]`  |
| Confirm Manual Test      | `0xD3`   | Confirm test result     | `[0x01, passed]`    |

### Other Commands

| Command            | CMD Byte | Description            | Payload         |
| ------------------ | -------- | ---------------------- | --------------- |
| Populate Fake Data | `0x23`   | Populate test data     | `[0x01, 0x01]`  |
| Get Memory Dump    | `0x26`   | Get raw memory dump    | `[0x01, 0x01]`  |
| Restart Device     | `0x27`   | Restart device         | `[0x01, 0x01]`  |
| Get Device Variant | `0x2B`   | Get device variant     | `[0x01, 0x01]`  |
| Factory Reset      | `0xFA`   | Factory reset device   | `[0x01, 0x01]`  |
| Set Sensor Error   | `0xFF`   | Set sensor error state | `[0x01, high?]` |

## Response Commands

Responses use the same command byte values but are received via the Notify characteristic.

### Response Command Values

| Response                      | CMD Byte | Description                        |
| ----------------------------- | -------- | ---------------------------------- |
| CO2 Value                     | `0x01`   | Current CO2 reading                |
| Set Alarm Result              | `0x02`   | Alarm setting confirmation         |
| Set Vibration Result          | `0x03`   | Vibration setting confirmation     |
| Set Time Result               | `0x04`   | Time setting confirmation          |
| Set Power Mode                | `0x05`   | Power mode setting confirmation    |
| Disconnect Result             | `0x06`   | Disconnect confirmation            |
| Set CO2 PPM Result            | `0x07`   | CO2 threshold setting confirmation |
| Initial Data                  | `0x08`   | Complete device settings           |
| Get Alias                     | `0x09`   | Device alias string                |
| Set Alias Result              | `0x0A`   | Alias setting confirmation         |
| Get CO2 History               | `0x0C`   | Historical CO2 data                |
| Calibrate Sensors             | `0x0D`   | Calibration result                 |
| Set Continuous Display Result | `0x0E`   | Display setting confirmation       |
| Recalibration Time            | `0x0F`   | Recalibration time value           |
| Locate My Airspot             | `0x10`   | Location feature confirmation      |
| Firmware Version              | `0x13`   | Firmware version string            |
| Recalibration Confirm         | `0x1F`   | Recalibration confirmation         |
| Battery Level                 | `0x20`   | Battery level and charging status  |
| DND Mode                      | `0x22`   | DND setting confirmation           |
| Populate Fake Data            | `0x23`   | Fake data population confirmation  |
| Reset Sensor Result           | `0x24`   | Sensor reset confirmation          |
| ASC Data                      | `0x25`   | ASC calibration data               |
| Get Memory Dump               | `0x26`   | Memory dump data                   |
| ASC Day Count                 | `0x2A`   | Days until next ASC                |
| Get Device Variant            | `0x2B`   | Device variant value               |
| Get Advanced Alarm Settings   | `0x2F`   | Advanced alarm configuration       |
| Get Sensor Details            | `0x30`   | Sensor configuration data          |
| Data Erase Done               | `0xFD`   | Data erase confirmation            |

### Response Payload Formats

#### CO2 Value Response (`0x01`)

**Short format** (6 bytes total):

```
[0xFF] [0xAA] [0x01] [0x02] [valueHigh] [valueLow] [checksum]
```

**Long format** (10 bytes total):

```
[0xFF] [0xAA] [0x01] [0x06] [tsByte3] [tsByte2] [tsByte1] [tsByte0] [valueHigh] [valueLow] [checksum]
```

#### Initial Data Response (`0x08`)

Contains all device settings. Format varies by firmware version:

**Basic fields** (minimum 13 bytes):

- Byte 4: Alarm enabled (boolean)
- Byte 5: Vibration enabled (boolean)
- Byte 6: Power mode (0-3)
- Bytes 7-8: Green threshold (2 bytes, big-endian)
- Bytes 9-10: Yellow threshold (2 bytes, big-endian)
- Byte 11: Continuous screen enabled (boolean)
- Byte 12: Auto calibration enabled (boolean)
- Byte 13: DND enabled (boolean, if present)
- Bytes 14-17: DND times (if present)

**Extended fields** (firmware v3.0.0+):

- Bytes 18-19: Recalibration target (2 bytes)
- Byte 20: UI mode
- Bytes 21-22: Graph max value (2 bytes)
- Bytes 23-24: Graph min value (2 bytes)
- Bytes 25+: Advanced alarm settings (42 bytes)
- Bytes 67+: Scaling factor (4 bytes, float)
- Bytes 71+: Flight mode (1 byte, boolean)

#### CO2 History Response (`0x0C`)

**Page number response** (7 bytes):

```
[0xFF] [0xAA] [0x0C] [0x01] [0x01] [pageHigh] [pageLow] [checksum]
```

**History data response**:

```
[0xFF] [0xAA] [0x0C] [recordCount] [pageHigh] [pageLow] [records...] [checksum]
```

Each record is 8 bytes (see [Historical Data Record Format](#historical-data-record-format)).

**Done response** (6 bytes):

```
[0xFF] [0xAA] [0x0C] [0x01] [0x01] [0xB8] [checksum]
```

#### Battery Level Response (`0x20`)

```
[0xFF] [0xAA] [0x20] [0x02] [level] [charging] [checksum]
```

- **level**: Battery level (0-100)
- **charging**: 0x00 = not charging, 0x01 = charging

#### Sensor Details Response (`0x30`)

Minimum 21 bytes:

- Bytes 4-5: Temperature offset (2 bytes, raw)
- Bytes 6-7: Altitude (2 bytes)
- Bytes 8-9: Ambient pressure (2 bytes, mbar)
- Byte 10: ASC enabled (boolean)
- Bytes 11-12: ASC target (2 bytes)
- Bytes 13-18: Serial number (6 bytes, hex)
- Byte 19: Sensor variant

## Data Flow

### Connection Flow

1. **Device Discovery**: App scans for BLE devices
2. **Connection**: App connects to device
3. **Service Discovery**: App discovers services and characteristics
4. **Subscribe**: App subscribes to Notify characteristic
5. **Initialization**: App sends `Get Initial Data` command
6. **Ready**: Device responds with settings, app is ready

### CO2 Reading Flow

1. **Request**: App sends `Get CO2` command (`0x01`)
2. **Response**: Device responds with CO2 value via Notify
3. **Processing**: App parses response and stores data
4. **Update**: UI updates with new reading

### History Download Flow

1. **Request Page**: App sends `Get CO2 History` with page number
2. **Response**: Device responds with page data or page number
3. **Process**: App parses records and stores locally
4. **Continue**: App requests next page until done (`0xB8` response)
5. **Complete**: All data downloaded

### Settings Update Flow

1. **Change**: User changes setting in app
2. **Command**: App sends appropriate set command
3. **Confirmation**: Device responds with confirmation
4. **Refresh**: App may request `Get Initial Data` to verify

## Device Data Types

Device data records can have different types, identified by a single byte:

| Type                       | Byte Value | Description                |
| -------------------------- | ---------- | -------------------------- |
| CO2                        | `0x00`     | CO2 reading (ppm)          |
| Battery Low                | `0x01`     | Battery low event          |
| Calibration                | `0x02`     | Calibration event          |
| Sensor Error               | `0x03`     | Sensor error event         |
| Reset                      | `0x04`     | Device reset event         |
| Sensor Factory Reset       | `0x05`     | Sensor factory reset       |
| Calibration Correction     | `0x06`     | Calibration correction     |
| Sensor Auto Calibration    | `0x07`     | Auto calibration event     |
| Integrity Error            | `0x08`     | Integrity check error      |
| Calibration Target         | `0x09`     | Calibration target update  |
| Time Sync                  | `0x0A`     | Time synchronization       |
| Calibration Adjustment     | `0x0B`     | Calibration adjustment     |
| ASC Lowest                 | `0x0C`     | ASC lowest value           |
| Calibration Correction Old | `0x0D`     | Old calibration correction |
| Manual Calib Start         | `0x0E`     | Manual calibration start   |
| Calibration Target Update  | `0x0F`     | Calibration target update  |
| DFU Update                 | `0x10`     | Device firmware update     |
| DFU Update Fail            | `0x11`     | DFU update failure         |
| CO2 Retry                  | `0x12`     | CO2 reading retry          |
| Flight Mode                | `0x13`     | Flight mode event          |
| Scaling                    | `0x14`     | Scaling factor change      |

## Notes

### Firmware Version Compatibility

- **Old firmware** (< v3.0.0): Uses date-range based history requests
- **New firmware** (≥ v3.0.0): Uses page-based history requests

### Timezone Handling

- When sending time to device: Add local timezone offset
- When parsing time from device: Subtract local timezone offset
- Device displays time as-is without timezone conversion

### Checksum Validation

All commands and responses should validate checksums before processing. Invalid checksums indicate corrupted data.

### Error Handling

- Commands may fail silently (no response)
- Responses may be delayed or arrive out of order
- Always validate response length before parsing
- Handle missing or unexpected fields gracefully

## References

- Command definitions: `lib/core/utils/device_cmd_utils.dart`
- Response parsing: `lib/core/services/ble_data_service.dart`
- Data models: `lib/core/models/device_data.dart`
- Constants: `lib/core/utils/constants.dart`
