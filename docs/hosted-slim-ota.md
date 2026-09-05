# Hosted Slim OTA

The app now requests firmware per device model and refetches if BLE discovery
corrects a saved device's identity. Slim uses `device_model=slim`; Screen and legacy
unknown devices use `device_model=screen`. Both retain the existing beta rule:
app versions whose last component is not `0` request inactive releases.

A hosted Slim response must identify `device_model=slim`, provide `file_format`
(`bin` or `zip`), a valid HTTPS download URL, and an MCUboot-compatible version
(`major.minor.revision`, optionally prefixed with `v`). Missing/invalid metadata
or a response for another model is rejected. Legacy Screen responses without the
new metadata remain supported.

Slim's update page displays hosted release/update controls. Local files are
available through eight taps on the logo, matching Screen; there is no visible
local-file button. Hosted downloads retain their format, are capped at 2 MiB, and are
validated by the existing `SlimFirmwareImage` parser before transfer. The image
version must equal the selected release. Temporary files are removed on success
and failure. Before a hosted transfer, the app rediscovers services and checks the
actual device against the release. Slim uses the existing MCUmgr session and
post-update verification; Screen continues using Nordic DFU.

## Verification

- `test/hosted_firmware_test.dart` covers per-model queries, beta selection, legacy
  responses, malformed metadata, downgrade prevention, BIN/ZIP transfer handoff,
  model mismatch, image-version mismatch, failed downloads and cleanup.
- Existing Slim parser, session, service, protocol and chart tests are retained.
- On 2026-09-05, analysis and all 43 tests passed in the actual working checkout,
  including the existing local signed 0.14.6 package hash check. An isolated copy
  using staged dependencies also passed. A concurrent dependency upgrade briefly
  introduced incompatible Riverpod 3 providers; after the working dependency set
  returned to Riverpod 2.6.1, the full checks were rerun successfully. This OTA
  change does not modify dependency requirements.
- Server isolation is deployed. Slim 0.15.0 is available in the beta channel, and
  its hosted ZIP download matches the built artifact checksum. ZIP needs no
  storage configuration change. The user observed a successful reboot; final
  early-reconnect behavior still needs physical iOS/Android qualification.
- Reboot handling now uses device self-confirmation with no fixed 130-second
  delay. Read-only image checks tolerate transient disconnects for up to 150
  seconds and return as soon as the target image is active and confirmed. The
  app then requires the expected version and fresh live readings.

- Final 3.8.5+153 source validation: Flutter analysis passed and all 46 tests
  passed, including the pinned production 0.14.6 package fixture.

## Before release

The app version is `3.8.5+153`, retaining beta OTA selection. Choose the
matching server minimum-app-version requirement, and verify authenticated upload
and signed download in a test environment. Then qualify hosted OTA on both iOS and
Android with an explicitly selected signed Slim package. Check confirmed image
hash, installed version, fresh live readings, settings/history retention,
interruption recovery and Screen coexistence. An inactive server release is
available to beta clients; it is not an unpublished draft.

Server contract, storage configuration and deployment checks are documented in
`airspot_server/docs/hosted-ota.md` in the sibling server repository.
