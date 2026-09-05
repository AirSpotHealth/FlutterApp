# Slim software calibration (firmware 0.16.0)

Slim's Auto Calibration toggle now controls AirSpot's software algorithm. The
STCC4 internal ASC remains paused, including when the toggle is on. Screen's
behavior is unchanged. Existing Slim firmware still has the old hardware-toggle
behavior until updated; an app update alone cannot enforce this policy.

The app accepts command 0x11 acknowledgements and reloads device settings/progress.
0xFF is an operation failure for Slim's 0x11, 0x24 and short 0x0D responses. Existing
success frames and signed correction frames are unchanged. A reset response is
an operation result, not a calibration preference; the device state is authoritative.
Reconnect already reads the device's initial settings and continues to do so.

## Checks

- Flutter analyzer and automated tests, including Slim/Screen response compatibility.
- The optional production-image test accepts AIRSPOT_SLIM_DFU,
  AIRSPOT_SLIM_EXPECTED_VERSION and AIRSPOT_SLIM_EXPECTED_HASH so each candidate can
  be verified through the actual app ZIP/image parser.
- Physical on/off toggle, reset, reconnect and reading comparison are pending a
  reachable Slim. No nearby AirSpot advertisement or J-Link probe was available
  during implementation; no device was flashed or recalibrated.
