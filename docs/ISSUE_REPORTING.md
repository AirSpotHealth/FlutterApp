# Issue Reporting Feature

This document describes the in-app issue reporting feature for the AirSpot Health app.

---

## Feature Overview

Users can report issues related to:

- **App Issues** - Bugs, crashes, UI problems in the mobile app
- **Device Issues** - Problems with their AirSpot CO2 monitor (sensor errors, connectivity, firmware)

### Access Point

**App Setup** → **Report an Issue**

---

## User Flow

1. User taps "Report an Issue" in App Setup
2. Selects issue type: **Device Issue** or **App Issue**
3. If Device Issue: optionally selects which AirSpot device
4. Enters description (minimum 10 characters)
5. **Optionally enters email for follow-up**
6. Optionally attaches a screenshot
7. Taps **Submit**

---

## Auto-Collected Metadata

The following is collected automatically with each report:

| Field               | Example             | Source                       |
| ------------------- | ------------------- | ---------------------------- |
| `app_version`       | `3.7.2+145`         | Package info                 |
| `platform`          | `ios` / `android`   | Platform detection           |
| `device_model`      | `iOS Device`        | Platform                     |
| `os_version`        | `17.2.1`            | Platform                     |
| `user_id`           | UUID                | Supabase auth (if logged in) |
| `user_email`        | `user@example.com`  | Supabase auth (if logged in) |
| `airspot_device_id` | `AA:BB:CC:DD:EE:FF` | Selected device              |
| `firmware_version`  | `2.1.0`             | Selected device              |

---

## Device Diagnostics (Auto-Collected for Device Issues)

When user selects a device issue and picks a device, the following data is automatically collected:

| Field                    | Description                   |
| ------------------------ | ----------------------------- | --- |
| `last_co2_reading`       | Most recent CO2 value         |
| `last_co2_time`          | Timestamp of last CO2 reading |
| `last_sensor_error_code` | Numeric error code (if any)   |
| `last_sensor_error`      | Human-readable error message  |
| `last_sensor_error_time` | When error occurred           |
| `last_battery_low_time`  | Last battery low event        |
| `last_calibration_time`  | Last calibration event        |
| `last_reset_reason`      | Why device last reset         |
| `last_reset_time`        | When device last reset        |
| `total_co2_readings`     | Total readings stored locally |     |

---

## API Specification

### Endpoint

```
POST https://update.airspothealth.com/api/issues
```

### Headers

```
Content-Type: application/json
x-api-key: <API_KEY>
```

### Request Body

```json
{
  "issue_type": "device",
  "description": "The CO2 sensor shows ---- and never updates",

  "app_version": "3.7.2+145",
  "platform": "ios",
  "device_model": "iOS Device",
  "os_version": "17.2.1",

  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_email": "user@example.com",

  "airspot_device_id": "AA:BB:CC:DD:EE:FF",
  "firmware_version": "2.1.0",

  "attachment_base64": "data:image/png;base64,iVBORw0KGgo...",
  "attachment_filename": "screenshot.png"
}
```

### Required Fields

- `issue_type`: `"device"` or `"app"`
- `description`: String (min 10 characters)

### Optional Fields

- All metadata fields (auto-collected, may be null if unavailable)
- `attachment_base64` / `attachment_filename` (only if user attaches image)
- `airspot_device_id` / `firmware_version` (only for device issues)

### Response

- **`200 OK`** or **`201 Created`** on success
- **`400 Bad Request`** if validation fails
- **`401 Unauthorized`** if API key is invalid/missing

---

## Database Schema

See [issues_table_migration.sql](./issues_table_migration.sql) for full schema.

### Table: `issues`

| Column               | Type        | Description                                |
| -------------------- | ----------- | ------------------------------------------ |
| `id`                 | UUID        | Primary key                                |
| `issue_type`         | TEXT        | `device` or `app`                          |
| `description`        | TEXT        | User's description                         |
| `attachment_url`     | TEXT        | S3/Storage URL (decoded from base64)       |
| `app_version`        | TEXT        | App version                                |
| `platform`           | TEXT        | `ios` or `android`                         |
| `device_model`       | TEXT        | Phone model                                |
| `os_version`         | TEXT        | OS version                                 |
| `airspot_device_id`  | TEXT        | AirSpot MAC address                        |
| `firmware_version`   | TEXT        | Device firmware                            |
| `device_diagnostics` | JSONB       | Auto-collected device data (see above)     |
| `user_id`            | UUID        | Supabase user ID                           |
| `user_email`         | TEXT        | User email                                 |
| `status`             | TEXT        | `new`, `in_progress`, `resolved`, `closed` |
| `created_at`         | TIMESTAMPTZ | Submission time                            |
| `updated_at`         | TIMESTAMPTZ | Last update time                           |

### Indexes

- `status` - For filtering in admin panel
- `created_at DESC` - For sorting by newest
- `issue_type` - For filtering by type
- `airspot_device_id` - For device-specific lookups
- `user_id` - For user-specific lookups

---

## Backend Implementation Checklist

- [ ] Create `POST /issues` endpoint
- [ ] Validate `x-api-key` header
- [ ] Validate required fields (`issue_type`, `description`)
- [ ] Decode base64 attachment and upload to S3/Supabase Storage
- [ ] Insert record into `issues` table
- [ ] Create `GET /issues` endpoint for admin panel (protected)
- [ ] Add status update endpoint `PATCH /issues/:id` for admin

---

## Flutter Files

| File                                                                | Purpose          |
| ------------------------------------------------------------------- | ---------------- |
| `lib/features/report_issue/models/issue_report.dart`                | Model class      |
| `lib/features/report_issue/providers/issue_reporting_provider.dart` | State management |
| `lib/features/report_issue/report_issue_page.dart`                  | UI page          |
| `lib/core/services/issue_reporting_service.dart`                    | API calls        |
