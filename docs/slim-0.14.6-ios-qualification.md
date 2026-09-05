# Slim 0.14.6 / iOS qualification

Status: **provisionally accepted as working by the user on 2026-09-05**. App changes implemented; 26 automated tests and analysis passed; signed iPhone build/install/run passed. The user will perform the remaining physical checks. This is not a claim that every qualification item passed.

## Target and scope

- App working branch: `feat/airspot-slim`, starting at `b2a1c31`, with existing local dependency and time/DND edits preserved.
- Firmware: production 0.14.6, configuration commit `565eb8c`.
- Qualified package: `../firmware/airspot_slim/local_backups/button-qualification/production-final-dfu.zip`.
- MCUboot image SHA-256: `6631263b902886fd7f79a756b1c6ba7e76f25375a7765afd5a6fa4c03254214f`.
- iOS local-file updates only. Hosted Slim checks remain disabled. Android physical qualification, firmware changes, server publishing and database migrations are outside this pass.

## Compatibility findings and changes

| Area | Evidence and behavior |
| --- | --- |
| Discovery | Firmware advertises `AirSpot-XXXXXX` with the SMP UUID in scan-response data. Missing scan UUID is inconclusive; connected service discovery identifies Slim. Persisted Slim identity is retained. |
| Live readings | Firmware `protocol_send_realtime_co2` sends a 15-byte frame: big-endian timestamp and CO2, signed temperature ×100 and humidity ×100. Existing parser matches. Invalid CO2 `0xFFFF` remains a sensor error. |
| Battery | Firmware sends seven bytes with a legacy payload-length byte of 1. App retains parsing of both percentage and charging state. Firmware's OTA guard uses cached voltage ≥3,600 mV, not the app's percentage. |
| History | Firmware `protocol_send_history_data` sends timestamps big-endian and values little-endian. App now decodes Slim values little-endian and always selects the half-page protocol for Slim, regardless of firmware version numbering. Screen decoding is unchanged. |
| Calibration | Slim `0x25` is an eight-byte correction-only response, unlike the Screen response that includes a count. The parser now handles both. Start, target, countdown and correction command layouts were checked against firmware. |
| Sensor identity | Variant byte 2 is STCC4, previously displayed as SCD42/unknown. Both identity paths now report STCC4. Firmware's sensor-details serial field remains its existing placeholder, not a measured sensor serial. |
| Settings | Device-state offsets match firmware. Reconnection reads retained thresholds/settings instead of writing cached Slim defaults back onto the device. Unsupported screen, buzzer and vibration controls remain hidden. |
| Local OTA | Slim's update page offers Select firmware file for signed BIN or DFU ZIP; Screen retains its existing ZIP update path. |

## Update contract

1. Validate the selected file before disconnecting. ZIPs must contain exactly one application BIN with a recognized signed-image filename (`app_update.bin`, `application.signed.bin`, `zephyr.signed.bin`, `airspot_slim.signed.bin`). Multiple BINs are rejected rather than guessing.
2. Validate MCUboot header, all protected/unprotected TLV boundaries, SHA-256 digest and presence of the ECDSA signature TLV. Retain protected TLVs and the complete signature trailer. Only an all-`0xFF` suffix is trimmed. Input size is bounded. Product-key signature authenticity is enforced by MCUboot on the device; the app's structural check is not a replacement for it.
3. Hold the app's communicator, drain outstanding writes, pause history and block ordinary NUS commands/reconnect attempts while MCUmgr owns the connection.
4. Read current image state. An already active and confirmed matching image skips upload and is reported as already current after app verification.
5. Otherwise use `testOnly`, `eraseAppSettings: false`, pipeline depth 1. Slim confirms itself after startup and a healthy sensor sample. Reconnect with no fixed swap delay, then poll the active, confirmed target hash every two seconds for up to 150 seconds. Transient reconnect/read failures may recover during verification, but upload failures must fail immediately. Bound native update completion to ten minutes. Do not blindly re-upload on failure.

   Requalify this reconnect behavior on iOS and Android: a device ready in about 30 seconds should complete verification promptly; slow startup must remain pending until confirmation, and rollback must never report success.
6. Require the expected hash to be active and confirmed. Release MCUmgr, reconnect through the app's Bluetooth stack, discover NUS, and require matching firmware version plus a new valid live-reading notification before showing success. Cached notification replay does not count.
7. On success or failure, release the communicator hold and reconnect. Resume a paused history request when normal GATT initialization succeeds. Surface the original error with charging guidance for firmware battery rejection. A file-validation failure leaves the existing BLE connection alone.

## Automated checks

Run from `mobile/`:

```sh
flutter analyze --no-pub
AIRSPOT_SLIM_DFU=../firmware/airspot_slim/local_backups/button-qualification/production-final-dfu.zip flutter test --no-pub
flutter build ios --debug --no-pub --no-codesign --dart-define-from-file=.env.local
```

The production-package test explicitly skips when `AIRSPOT_SLIM_DFU` is not set; all synthetic fixtures are test-only.

- Baseline analysis: passed with no issues before implementation.
- Current automated tests: 26 passed, including the actual production ZIP/hash and graph startup regression tests.
- Coverage: protected TLVs, truncation, unsigned images, malformed ZIP selection, corrupt body hash, padding, live readings, battery, history endianness, calibration, STCC4 identity, Slim/Screen DFU routing, communicator suspension, confirmed-target requirement, already-current behavior, rejection, early stream closure, timeout cleanup, and session restoration after suspend/upload/verification/reconnect failures.
- Analysis and signed iOS build/install/run passed in the resumed physical session below.

## Physical iPhone checklist — in progress

The first implementation pass had no phone online. The resumed session below uses a physical iPhone. Existing macOS SMP firmware qualification does not substitute for the Flutter/native iOS checks.

Use a test Slim with a backed-up history/settings snapshot. Record phone model/iOS, app revision, device ID, source/target image hashes, timestamps and logs for each run.

- [ ] Discover/add Slim; close and reopen the app; reconnect to the same saved identity.
- [ ] Compare displayed CO2/temperature/humidity with actual NUS readings; check refresh, sensor warmup/error, battery percentage and charging transitions.
- [ ] Fetch a known history page and compare record timestamps/values with firmware output; inspect graph and export. No byte-swapped values, duplicate identity or unintended history erase.
- [ ] Change alias, sampling mode and LED thresholds; reconnect/reboot and verify retained values. Verify supported calibration target, countdown and completion on a suitably prepared test device.
- [ ] Background/resume the app and toggle phone Bluetooth; confirm reconnection and fresh readings.
- [ ] Exercise the qualified 0.14.6 sleep/wake gesture with debugger detached. Confirm expected disconnect, wake, same identity and live readings after sensor conditioning.
- [x] Select the exact current production image: expect “already current; device verified,” with no upload. This is not an upgrade test.
- [ ] Start from a distinct qualified signed source image compatible with the installed bootloader. Upload production 0.14.6 from the iPhone app. Confirm target hash, automatic firmware confirmation, version, live reading and retained settings/history. Never re-provision/overwrite the bootloader to set up this check.
- [ ] Reject invalid/unsigned/truncated files without disconnecting the working device.
- [ ] Interrupt a transfer, then reconnect and verify normal operation. Retry deliberately and record the actual final image state; do not infer success from upload progress.
- [ ] On a suitably charged/controlled test device, verify firmware battery rejection and retry after charging; do not force brownout.
- [ ] Check the Screen device's normal reading/settings and Nordic ZIP update behavior on physical hardware before a shared app release.

Completion requires these physical checks and a signed device run. An unsigned build and passing unit tests alone do not qualify iOS OTA or sleep/wake.

## Build environment note

The first Xcode build stopped before app compilation: the generated `ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift` declared iOS 13, while Firebase requires 15 (Home Widget requires 14). Runner already targets 15 or higher. This predates the app changes; tracked iOS targets and dependency files were left intact.

Flutter's [documented configuration regeneration](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-use-a-swift-package-manager-flutter-plugin-that-requires-a-higher-os-version) (`flutter build ios --config-only`) did not update the generated minimum in this environment. For local compilation, the ignored generated package was aligned to `.iOS("15.0")`, matching Runner. Regeneration may recreate the discrepancy; record that dependency/tooling issue separately from BLE qualification.

### Initial verification record (before storage was cleared)

- Final analysis: no issues found.
- Final tests: 24 passed, including the real production-package hash test.
- Independent review: identified asynchronous restoration before success and failed-initialization retry state. Both fixed; session restoration regression tests added.
- iOS build: **blocked**, not passed. After aligning the ignored generated Swift package minimum, the configured build failed while resolving packages because Macintosh HD was out of space (`Failed saving result bundle ... volume ... is out of space`). It did not establish app/native compilation success.
- Toolchain at final attempt: Flutter 3.47.2 / Dart 3.13.2. Runtime configuration: existing `.env.local`; no secrets copied into the report.
- Cleared only regenerable `build/ios/SourcePackages/repositories` and `artifacts` caches to recover enough space to finish source/test/report writes. They will download again on a later build. No tracked dependencies or deployment targets changed by this task.
- Physical iPhone OTA, normal operation and sleep/wake: **pending**; no phone online. Resume by freeing sufficient disk space, rerunning the configured build, then connecting a signed iPhone build and test Slim.


## Resumed physical session

- iPhone 17 Pro Max, iOS 26.6, connected over USB; developer mode enabled.
- User cleared storage; 45 GiB free at restart.
- Copied the qualified production ZIP to the app's `Documents/AirSpot-Slim-0.14.6-dfu.zip`, accessible through Files.
- Signed debug build, installation and launch **passed** with `.env.local` (Xcode build 61.9 seconds after cache recovery). SwiftPM's interrupted Firebase/GoogleSignIn checkouts and stale workspace-state metadata were moved to `/tmp/airspot-slim-spm-recovery/` for preservation and regenerated.
- Slim identity confirmed: **AirSpot-C58CC9**, saved alias **AirSpot Slim**, iOS BLE ID `FD0B9027-A712-91F6-3901-68FBFE822FD4`. SMP discovered and Slim routing selected. NUS reports **0.14.6**, STCC4, battery **70%**, not charging.
- Saved-device reconnect and repeated fresh readings passed. Example actual NUS sample: `ffaa010a6a9c3fc209720afc0ebd07` → 2418 ppm, 28.12°C, 37.73% RH. Settings were read; calibration target 426 ppm, LED thresholds 800/1000 ppm. Settings mutation/retention and actual calibration remain pending.
- Screen coexistence check: **AirSpot-AF94D2 / Travel Bag**, firmware 1.5.5, battery 58%, valid live readings, correctly classified as Screen with Nordic FE59 instead of SMP. Screen OTA remains pending.
- Slim history page request completed at page 0 with all-zero records, which the app correctly skipped. Nonempty history decoding/retention and export still require a populated device.
- Opening the graph exposed a pre-existing WebView startup race: option updates could evaluate JavaScript before `chart` existed. Fixed configuration ordering/readiness gating and pending latest-option application. A native WebView query confirmed the graph initialized with 47 real data points. A fresh opening after the final fix remains to be rechecked. Flutter inspector screenshots exclude embedded WebViews and are not evidence of chart pixels.
- Resumed analysis: **no issues**. Tests: **26 passed**, including the real signed production package and two chart startup/disposal regression tests. Independent review found no blocker in the chart fix.
- Remote debugger screenshot/navigation attempts produced Flutter inspector assertions and stalled UI inspection. Debug hot restart restored navigation. These are recorded separately from app BLE results; native file selection is being performed on the phone.
- Production ZIP copied into app Documents. Local already-current verification, actual distinct-source upgrade, interrupted transfer, sleep/wake, background/Bluetooth interruption, battery rejection and retained settings/history remain pending until individually evidenced.

### Local already-current run (16:23 Sydney time)

- User selected the staged production ZIP through the native file picker. The app disconnected Slim, returned through version/live-reading verification, restored normal initialization and closed the success dialog without an upload/reset delay.
- Fresh verification frame: `ffaa010a6a9c420605f80ac70f7352` → 1528 ppm, 27.59°C, 39.55% RH; version reply was 0.14.6. Further readings continued after restoration.
- Settings after restoration: sampling mode 3 (changed during the physical session), LED thresholds 800/1000, calibration target 426; saved alias AirSpot Slim. This verifies retention across the already-current reconnect, not across an actual firmware swap.
- This is an **already-current check only**. An actual upgrade is being prepared using `system-off-dfu.zip`, the previously qualified 0.14.5 application-only source. Its image hash is `09f6195333c31597d5430a70fbf7eb3dfffb2bd1e0ddf78c11d0512cf78ac66e`; ZIP SHA-256 is `b5ba24402a5d3aca3117421572617f2c792558971913f28e7d3c438fcb2b5d63`. Bootloader is not replaced.

### Distinct-source and interrupted-transfer checks

- Native iOS test-and-confirm successfully activated the qualified 0.14.5 source, then the app verified its active/confirmed hash, version and a fresh reading before reporting success. Startup wait completed normally. Settings frame remained `ffaa0844000003032003e80000001600070001aa0007d001900000000000000000000000000000000000000000000000000000000000000000000000000000000000003f80000000f5`.
- For fresh-transfer qualification, debug test preparation read and checked the confirmed source hash, erased only inactive image 0 / slot 1 through the native MCUmgr API, then verified that slot was empty. Active firmware, bootloader and settings were not erased. The debug preparation script used a page reference invalidated by disconnect navigation; its restoration raised a disposed-reference error. Normal communication was restored through the app connection provider. This was an external test-script error; production OTA holds its provider alive and completed its own restoration.
- Production upload was deliberately cancelled through the native update manager after **8.2728%**. The app surfaced `Firmware update ended before completion`, restored communication, read back 0.14.5 and retained settings, and received fresh sample `ffaa010a6a9c43a005680ab61016f0` (1384 ppm). This proves partial-transfer cancellation/recovery; a physical Bluetooth-radio interruption is still a separate pending check.
- Retried the same production file through the actual app update provider/dialog. Transfer progressed through individual percentages; final target verification is pending below.

- Final signed build with graph readiness fix and clearer startup-wait message passed (`flutter build ios --debug --no-pub --dart-define-from-file=.env.local`, Xcode 25.3 seconds). Final analysis remained clean; all 26 tests passed. Installation of this final on-disk build follows completion of the running OTA check.

## Handoff — user taking over remaining checks

The user stopped further qualification and accepted the app/firmware combination as working provisionally. No further device changes or physical tests were started.

- **Observed on the final production retry:** upload reached 100%, test boot completed, native confirmation and active-image verification passed, app reconnected, NUS reported **0.14.6**, and a new valid reading arrived: `ffaa010a00000088054c0aaa107acb` → **1356 ppm, 27.30°C, 42.18% RH**. The service's active-image verification compares the recorded production hash and requires active/confirmed flags.
- **Not captured:** the final `AsyncSuccess` transition and completion of ordinary communication restoration. The debug session ended (`Lost connection to device`) immediately after the live reading while this turn was interrupted. Do not infer the missing terminal transition from upload completion. The first post-reset reading used uptime 136 seconds as its timestamp; post-restoration clock synchronization and subsequent graph timestamps still need checking.
- Already-current flow, qualified 0.14.5 source activation/confirmation/reconnect, deliberate cancellation at 8.3%, failure reporting and recovery to 0.14.5 were observed. Source/settings identity remained intact in those completed checks.
- The final signed app binary was built successfully at `build/ios/iphoneos/Runner.app`. The graph fix ran via debug reload/restart; the final on-disk build (including the clearer two-minute startup message) was **not reinstalled** before handoff.
- **User-owned outstanding checks:** sleep/wake (charger ready and firmware debugger disconnected, but gesture not exercised in this app session); physical Bluetooth interruption/background-resume; final post-upgrade settings/history/clock retention; nonempty history/graph/export; calibration with a prepared reference environment; physical invalid-file and low-battery rejection; Screen OTA. Invalid-file cases passed automated tests; the staged truncated BIN was not selected on the phone.
- All existing unrelated uncommitted changes remain preserved. No firmware protocol, database schema, hosted rollout or release publication changes were made.
