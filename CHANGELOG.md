# Changelog

## Unreleased

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
