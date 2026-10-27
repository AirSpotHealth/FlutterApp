# Forget Device: storage-limit recovery

The reported failure was `DatabaseFullError` from the device-history bulk
`deleteAll`, after the Bluetooth disconnect timeout had already been caught.
The app opened Isar with its implicit 128 MiB ceiling. Deletion modifies indexes
and can need transaction working space even when the intended result is smaller.

The app now opens the same database with a 512 MiB ceiling. This is a maximum,
not a preallocated disk file. Launch compaction is conditional on at least a
64 MiB file, 32 MiB reclaimable space and a 2:1 size ratio; it doesn't discard
readings. Fully closing and relaunching the updated app applies this open policy.

Removal purges only the selected device, in transactions of at most 256 history
rows, yielding between batches. It also clears the selected device's event and
coverage records, settings and notification preferences. The saved device stays
until the purge succeeds. Interrupted purges are retryable but may already have
removed some of that device's history. BLE notification delivery is detached
before deletion to avoid writing more incoming readings during the purge.

Both entry points show a specific local-storage-full message and preserve the
actual exception in developer logs. No database reset, unrelated history purge
or cloud deletion is used. The 5-second Bluetooth cleanup timeout is unchanged.

Regression coverage fills a real small Isar database to `DatabaseFullError`,
reopens it with the production policy, checks bounded transactions and retry after
partial progress, and verifies another device's records remain. This reproduces
map exhaustion; the exact bulk-delete failure depends on database page layout.
The real card-sheet interaction and disconnected-device paths are also tested.
