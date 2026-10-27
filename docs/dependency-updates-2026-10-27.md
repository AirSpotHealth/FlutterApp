# Compatible dependency updates — 27 October 2026

Updated within the existing pubspec constraints. No dependency overrides or Flutter SDK
upgrade were used. `flutter_riverpod` and `riverpod` remain at 2.6.1.

| Package | Before | After |
| --- | --- | --- |
| `archive` | 4.5.1 | 4.5.2 |
| `build_daemon` | 4.1.6 | 4.1.7 |
| `crypto` | 3.0.7 | 3.0.8 |
| `cupertino_ui` | 1.1.2 | 1.1.4 |
| `dart_style` | 3.1.13 | 3.1.14 |
| `firebase_core` | 4.15.0 | 4.15.2 |
| `firebase_messaging` | 16.7.0 | 16.7.1 |
| `flutter_blue_plus_winrt` | 0.0.22 | 0.0.23 |
| `flutter_local_notifications` | 22.3.2 | 22.3.3 |
| `geolocator_android` | 5.1.1+1 | 5.2.1 |
| `geolocator_apple` | 2.3.14 | 2.4.3 |
| `geolocator_platform_interface` | 4.4.0 | 4.4.1 |
| `go_router` | 18.0.2 | 18.1.1 |
| `google_sign_in_android` | 7.2.17 | 7.2.18 |
| `google_sign_in_ios` | 6.3.6 | 6.3.8 |
| `http_multi_server` | 3.2.2 | 3.2.3 |
| `material_ui` | 1.6.0 | 1.8.0 |
| `permission_handler_apple` | 9.6.2 | 9.6.4 |
| `posix` | 6.5.2 | 6.5.3 |
| `pubspec_parse` | 1.6.0 | 1.7.0 |
| `shared_preferences_android` | 2.4.28 | 2.5.3 |
| `shared_preferences_foundation` | 2.5.7 | 2.6.1 |
| `shelf` | 1.4.2 | 1.4.3 |
| `vector_math` | 2.4.3 | 2.4.4 |
| `vm_service` | 15.3.0 | 15.4.0 |
| `web` | 1.1.1 | 1.1.2 |
| `webview_flutter_wkwebview` | 3.27.0 | 3.27.2 |

## Review and validation

Reviewed the upstream changelog entries for each changed package. Changes include
ZIP stream decoding, HMAC finalization, Firebase native SDK patches, notification
DST scheduling, navigation, location request completion, preferences native
implementations, permissions and compatible UI/tooling fixes.

- Baseline: 197 tests passed; optional firmware fixture test skipped.
- Final: 198 tests passed, none skipped, with the production Slim 0.22.8 ZIP.
- Static analysis: no issues.
- iOS release build passed (`flutter build ios --release --no-codesign`).
  Both SwiftPM lockfiles record the tested workspace resolution, including
  Firebase iOS SDK 12.19.3. The project-only preflight resolution was aligned
  to that tested workspace graph.
- Android release APK build passed (`flutter build apk --release`).
- Dependency recheck: no compatible non-Riverpod updates remain.

Database tests require `ISAR_LIBRARY_PATH` pointing to the macOS binary from
the installed `isar_plus_flutter_libs` 1.3.9 XCFramework. The earlier missing
library failures were test-environment failures; no database test was disabled.

The optional firmware check was enabled with `AIRSPOT_SLIM_DFU`,
`AIRSPOT_SLIM_EXPECTED_VERSION=0.22.8`, and
`AIRSPOT_SLIM_EXPECTED_HASH=03f0a1d6ae03174a85c7a3a3b29da0eb0cc2efe5dc30e388adc9eb92b146b446`.

Android release validation exposed an existing host configuration omission:
`mcumgr_flutter` 0.10.1 applies the Wire Gradle plugin without a local version.
The host now supplies Wire 7.1.0 in `pluginManagement`, matching the plugin's
published example. Its native mcumgr library also requires Kotlin 2.4 metadata;
the host Kotlin plugin was aligned to the example's 2.4.20 instead of suppressing
metadata compatibility checks. The plugin cache was not modified. Generated Android build reports are ignored.
The native release build is the regression check for these Gradle configuration
errors. Remaining build warnings concern legacy KGP/SPM adoption and deprecated
Java APIs; they did not prevent either release build.

These checks do not replace physical-device login, push notification, background
location and BLE smoke tests. No TestFlight or Shorebird release was uploaded.
