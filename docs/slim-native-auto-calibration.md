# Slim native auto-calibration (firmware 0.18.0+)

Device Settings > CO₂ Calibration exposes a sensor-confirmed Auto Calibration
switch. The app reads the separate native ASC protocol, not the older software
ASC setting. It publishes a preference only after an authoritative successful
response. Reconnects refresh the state; loading, failed, disconnected and unknown
states disable the switch and hide manual controls. Older Slims require firmware
0.18.0+ for the switch; fixed experimental 0.17.12 retains its manual lockout.
Screen calibration remains unchanged.

When ON, manual calibration, its target, and sensor reset are hidden. Native
sensor ASC updates its own baseline; saved host offsets are bypassed. When OFF,
learning pauses, the native baseline remains applied, and an old host offset is
not silently restored. A deliberate successful manual calibration can commit a
new software correction. Direct manual/reset app actions also check the verified
policy rather than relying only on control visibility.

The widget does not claim calibration completion or a baseline save. Those are
not exposed by the STCC4 public interface used here. ON means learning is enabled
and the production sensor status agrees with that policy.

Protocol 0x38 read: FF AA 38 00 E1. Write ON: FF AA 38 01 01 E3;
write OFF: FF AA 38 01 00 E2. Response payload: schema=1, mode
(0=host/manual, 1=native baseline held, 2=native learning), verified flag,
signed operation errno (16-bit BE), sensor status (16-bit BE). Response length
is 12 bytes with additive checksum. Modes, schema, flags, checksum, status-policy
agreement and errors are checked before allowing manual controls.

The switch preserves reading rate. For this experiment use five-second reporting
with continuous internal sensing. Fit normal covers, compare alongside the Screen
in the same shaded air, finish warm-up/initial operation, and observe fresh air
for 2–3 uninterrupted hours before pausing ASC for indoor comparisons. This is
an observation window, not a calibration-complete promise.

Signed local release: firmware/airspot_slim/releases/v0.18.0-native-asc-controls.
This experiment build defaults native ASC ON for units without a saved native
policy. Saved policy takes precedence on subsequent restarts. For ordinary units build
without native_asc_experiment.conf to retain an initial OFF/manual policy.
On 2026-10-05, the authorized OTA rollout verified 0.18.0 and native ASC ON on
2325D4, F1D7C1, 81A9DC and BE56FF, including their exact active self-confirmed
image hash and fresh samples. BE56FF retains one-minute reporting; the others
retain five-second reporting. Select five-second reporting on BE56FF for the
comparison. A physical
ON/OFF test on 2325D4 verified OFF persisted across an MCU restart, then restored
ON. This confirms policy persistence, not an internal sensor baseline save. The
user is running the modified app on their phone; that installation has not been
independently verified here. Screen firmware was not changed.
