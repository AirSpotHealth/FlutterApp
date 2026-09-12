# Slim software calibration (firmware 0.16.x)

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
- Physical Slim AirSpot-C58CC9 was updated to 0.16.0. Direct BLE tests verified
  toggle off/on, saved-on reboot, and reset preserving both toggle states.
  The new read-only 0x33 diagnostic confirmed paused internal ASC (`0x0084`).
- Startup testing with software ASC on produced an automatic correction (+116 ppm
  total). Software ASC was turned off and the original zero correction restored
  through sensor reset. Firmware 0.16.1 adds a three-minute observation guard
  after boot/reset. It excludes early readings from software automatic calibration
  without blocking live readings or manual calibration. Low readings after the
  guard still follow the automatic algorithm; this does not establish accuracy.
- The updated app has not been installed or exercised on a physical phone.
  All 51 Flutter tests and the analyzer passed; firmware qualification notes carry
  the hardware results and unresolved startup-calibration behavior.
