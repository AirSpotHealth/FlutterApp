# Slim UI and customer error review — 27 October 2026

## Changes

- Shared elevated, filled, outlined and text button styles use consistent corner radius, padding and minimum 48-point targets. Main action text uses the existing darker brand blue for contrast. Disabled labels and loading semantics are explicit.
- Slim Locate uses the shared full-width action, scrollable content, pending-request protection and success/failure feedback.
- Native auto-calibration retry, recovery steps, older-firmware calibration erase and Slim guide actions align with their content and share the same buttons. Recovery confirmation and device-state gating remain intact.
- Firmware update failures display a title and next steps in a scrollable dialog. Local-file updates can be retried. Unknown or already-installed outcomes direct users to reconnect/check the device rather than immediately repeating installation.
- Slim MCUmgr `Bad state (RC: 6)` is mapped to charging guidance only in the Slim update context. Firmware uses this response for voltage below its threshold OR voltage-read failure, so the UI does not invent a battery percentage or claim a definitive low-battery diagnosis.
- Firmware installation confirmed, previous image still active, rollback, unconfirmed startup, timeout, connection failure and incompatible file remain distinct. Original firmware errors remain attached as diagnostic causes.
- Replaced raw exception display in customer calibration, sync/export, device details, settings resets, file selection, sign-in and issue-submission flows. Factory engineering diagnostics remain technical.

## Verification

- Full Flutter suite: 181 passed, one skipped. Isar-dependent tests used the existing local macOS IsarPlusCore library through `ISAR_LIBRARY_PATH`; initial runs without it failed to initialize the database test environment.
- Analysis of changed areas and tests: no issues.
- Added tests for 320/390/768-point layouts at double text size, locate duplicate-tap protection, calibration retry, recovery confirmation, minimum target sizes, and firmware error classification/diagnostic retention.
- Rendered and inspected Locate, calibration retry and recovery widget previews. The test fixture uses a representative title, not a live device connection. Preview generation is optional through `SLIM_UI_PREVIEW_DIR`, `SLIM_UI_PREVIEW_FONTS`, and `SLIM_UI_PREVIEW_FONT`.
- Firmware failure notice tested in a 320-point scrollable dialog at double text size.
- No mobile binary was installed or published. Physical iPhone/Android interaction and actual low-battery OTA rejection remain manual acceptance checks.

This pass covers the Flutter mobile app's customer flows, including shared Screen/Slim UI. It does not claim a review of the separate dashboard, map or administration websites.

## Startup follow-up (firmware candidate 0.21.1)

Slim status 0x40 is rendered as a neutral “Preparing sensor…” notice, not a failed sensor. Device cards and current readings suppress stale values while preparing; the live Bluetooth subscription stays active so a valid response can clear preparation. Missing values no longer receive a green CO2 colour. Real faults keep their existing error/report behavior. This status does not certify long-term accuracy or replace the 12-hour recovery procedure. Now mode requires a fresh-reading request to update its report.

The full suite after this follow-up passes 184 tests, with one existing skip; analysis is clean. No physical-device test or installation was performed.

## Forget disconnected device

Forget no longer requires an already disconnected device to complete a native Bluetooth disconnect. Active/pending connections have their listeners and reconnect timer stopped first; native cleanup is bounded and best-effort. Local removal still reports database failures. The async operation holds its provider alive, clears only this device's history provider, and the confirmation sheet waits for success or displays an error instead of closing immediately.

The regression test reproduces a native disconnect failure with Bluetooth unavailable, then exercises the real forget notifier and saved-device database: local removal succeeds without a disconnect call, the other saved device remains, and the forgotten device reappears in the same scan subscription. It also covers an operation with no UI listener. Full suite: 184 passed, one skipped; changed-area analysis clean. Physical phone verification remains pending.
