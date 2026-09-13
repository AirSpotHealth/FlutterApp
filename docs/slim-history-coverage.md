# Slim history coverage

Slim history downloads use the local `HistoryCoverage` Isar collection. Each
entry identifies one device and a verified interval of epoch seconds, with an
inclusive start and exclusive end. Only overlapping or adjacent intervals merge.
The current unfinished second is excluded so later readings remain fetchable.

The collection is additive. Existing readings and `BleDevice` records are
retained, but Slim no longer trusts the legacy `lastFetchedStartDate` and
`lastFetchedEndDate` span. Opening an old period rechecks its coverage and fetches
missing intervals sequentially. Identical readings retain their existing IDs.
Screen continues to use its existing history flow. No firmware or BLE wire
format changes are required.

Coverage is written only after the scan reaches the requested start and all
buffered readings are saved. Interrupted scans, invalid frames, and failed
writes leave the interval retryable. If existing flash traversal limits stop a
scan early, readings are saved but the whole requested period is not certified.
Circular-buffer traversal is intentionally unchanged.

Coverage is cleared with local history deletion, acknowledged history erase or
factory reset, and device removal. Resetting fetch metadata also clears it.

## Verification

Run `flutter test` and `flutter analyze`. Native Isar tests require the matching
Isar core library. On a host where it is not discoverable automatically, set
`ISAR_LIBRARY_PATH` to the native library from the pinned `isar_plus` release
(on macOS, the macOS `IsarPlusCore.framework/Versions/A/IsarPlusCore` binary).

The regression tests exercise disjoint downloads, interval boundaries,
sequential gaps, timeouts, cancellation, failed writes, legacy database reopening,
cleanup, and Screen compatibility.

For physical verification, connect a Slim with retained history in a known gap,
open that period, and compare its graph/export before and after the download.
Reopen the same period to verify that completed coverage avoids another scan.
