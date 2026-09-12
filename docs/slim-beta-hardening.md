# Slim 0.17 beta updater qualification

Local candidate based on mobile revision
`a2e6f4f9466a3dcc113c1663501214c6aff861c4` (app 3.8.5+153).

The updater retains device-controlled test-boot confirmation. Transfer completion
is not installation success. Native errors after reset trigger read-only image
verification; the UI distinguishes observed rollback, previous image still active,
unconfirmed/unavailable image, and confirmed installation followed by failed
sensor-health verification. Repair upload authorization is enforced by firmware
using a fresh battery reading independently of sensor health.

Slim factory reset waits for the device's successful completion acknowledgement
before removing local data. Rejection, timeout, failed send or disconnect preserve
local data. Screen retains its existing protocol path.

The Slim status page can read and export the bounded firmware diagnostic journal
as JSON through the share sheet. The reader validates the NUS checksum, schema,
record CRC, sequence and snapshot consistency. Export is read-only and never
uploads automatically. Older firmware without the diagnostic command times out.

Tests cover interrupted/invalid hosted downloads, image parsing, DFU post-reset
verification, diagnostics and factory-reset acknowledgement. Full suite: 69 pass
plus one optional package check; the package check separately passed against the
actual signed 0.17.0 firmware. Static analysis passed. iOS release compilation
passed without codesigning. Android release APK compilation passed. Artifact identities
are recorded in the firmware report below.

Android compile SDK 37, AGP 9.1.1 and Gradle 9.3.1 are required by the currently
installed Android permission plugin's API 37 references; target SDK was retained.
Existing Flutter compatibility flags for legacy Kotlin/plugins remain in place.
A scoped file_picker Gradle bridge explicitly applies Kotlin compilation because
version 11 assumes AGP 9 built-in Kotlin even when the project disables it.
Remove that bridge when all plugins migrate to built-in Kotlin.
Do not interpret successful host builds as iOS/Android BLE qualification.

See [firmware findings](../../firmware/airspot_slim/docs/BETA_HARDENING.md) and
[validation evidence](../../firmware/airspot_slim/docs/BETA_VALIDATION.md).
Beta is **NO-GO** pending 20 update cycles per platform, fault/interruption tests,
resource and energy measurements, Screen compatibility and a 72-hour device soak.
No publication, device flashing or rollout was performed.
