# Changelog

## Unreleased

- Export one CSV row per measurement with diagnostic columns; keep mode/calibration changes as event rows and import both new consolidated and older CSV formats.
- Temporarily hide sensor-settling guidance on graph, settings and calibration screens; retain its tracking and implementation for the next update.

- Include selected measurement mode in diagnostic CSV readings and timestamp successful mode changes, including changes to On-demand before another reading occurs.

- Add Slim per-reading CSV diagnostics and battery columns when provided by updated firmware; keep old readings blank for unavailable fields and preserve diagnostic events on CSV import.

- Slim 0.19.0: separate calibration-preserving restarts/preferences reset from an explicitly confirmed sensor calibration erase. Show device-owned continuous settling progress and a fresh-air step; unknown history and completed guidance do not certify accuracy. This supersedes the older ASC-dependent Reset Sensor behaviour below.

- Fix iOS pod installation by aligning the project format with the supported Xcode 16 object version.

- Move Export Diagnostics into the main Slim device settings list, visible even with Dev Mode off.

- Match restart, diagnostics and app-update UI to existing illustrated settings rows and AirSpot bottom sheets; move explanatory text inside the sheets.

- Show available app patches, download state, restart instructions and confirmation after activation. Add manual patch checks in App Setup → App Updates; keep store releases linked to the store. Patches use the existing stable Shorebird track and installed version/build targeting.

- Require Slim 0.18.9+ for a complete factory reset including internal sensor calibration history. Decode retained bus failures, sensor readings/status, power context, recovery outcomes and reset failures in diagnostic exports.

- Make Slim Reset Sensor erase learned internal calibration history when auto-calibration is on, while keeping auto-calibration enabled (firmware 0.18.7+). With auto-calibration off, reset clears only the manual correction. Wait for a confirmed setting before selecting the reset.

- Add Restart device to normal device settings. Reboot the MCU while keeping saved settings, calibration and readings, with confirmation and connection/update failure feedback.

- Include device identity, saved firmware version and Bluetooth collection context in Slim diagnostic JSON exports; clarify that exporting requires a connection.

- Fix firmware checks failing with "Invalid firmware response: created_at" when the API omits the release timestamp.

- Rename the Slim guide to Button, LED and Charging Guide, keep extra Single/Double press copy in dark grey, and shorten the battery-status heading to one line.

- Place the Slim LED & charging guide under CO₂ reading rate, and CO₂ Zone Settings under Notification Settings. Keep Single and Double press colour lists visible, with extra detail on tap.

- Move Slim CO₂ PPM zones to a dedicated CO₂ Zone Settings page, linked from its LED guide. Preserve Device Screen Settings for Screen devices and align the guide text with the app theme.

- Refresh the Slim LED and charging guide with clearer status descriptions, a battery screenshot, and collapsible battery protection, power, and diagnostics sections.

- Fix Slim graph gaps between separate syncs by tracking completed download intervals. Existing readings are preserved; previously cached periods are rechecked when opened. Interrupted or failed downloads remain retryable.
- Restrict cloud-sync controls, background jobs, and uploads to dev mode; immediate uploads also respect the auto-sync toggle.
- Update the Slim LED and charging guide to match firmware 0.15.0 button gestures and timed indications.

## 3.8.5+153

- Add hosted Slim firmware updates with model-specific release selection, package validation, and post-update verification.
- Reconnect after Slim reboot without the fixed 130-second delay, waiting for device confirmation and fresh readings.
- Keep local firmware selection behind eight logo taps for both Slim and Screen.
- Correct Slim history, calibration, and sensor-model handling; pause normal BLE traffic during updates.
- Fix chart startup timing and adapt time pickers to updated dependencies.

This build retains beta firmware selection. Physical qualification of the final reconnect flow on iOS and Android remains pending.
