# Changelog

## Unreleased

- Restrict cloud-sync controls, background jobs, and uploads to dev mode; immediate uploads also respect the auto-sync toggle.
- Update the Slim LED and charging guide to match firmware 0.15.0 button gestures and timed indications.

## 3.8.5+153

- Add hosted Slim firmware updates with model-specific release selection, package validation, and post-update verification.
- Reconnect after Slim reboot without the fixed 130-second delay, waiting for device confirmation and fresh readings.
- Keep local firmware selection behind eight logo taps for both Slim and Screen.
- Correct Slim history, calibration, and sensor-model handling; pause normal BLE traffic during updates.
- Fix chart startup timing and adapt time pickers to updated dependencies.

This build retains beta firmware selection. Physical qualification of the final reconnect flow on iOS and Android remains pending.
