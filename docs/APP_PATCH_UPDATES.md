# Visible app patch updates

Shorebird patches target a platform and release version including its build number
(e.g. 3.8.13+161). TestFlight is not a separate Shorebird track. A production app
on a different release will not receive this release's patches; a TestFlight and
store installation of the same release can receive the same stable patch.
There is no beta opt-in or inference from the sensor firmware beta version.

The Home screen checks once per app session after rendering. Available patches,
pending restarts and a changed running patch can display a dialog. A dismissed
available/pending patch remains accessible from the Home App Setup badge and
App Setup → App Updates. Downloads only begin on user action. Leaving the dialog
does not cancel a download. The updater API has no percentage progress, so the
UI uses indeterminate progress rather than fabricated percentages.

The installed version/build comes from package metadata, independently of store
network requests. Quick patches and full store releases have separate controls.
A failed or unavailable store lookup must not say the user is up to date.

A downloaded patch is not active until a real process restart. No Flutter-only
restart or forced exit is used. The dialog explains fully closing and reopening;
Android foreground-service users may need a phone restart. Avoid restarting during
a device firmware update. On the next launch, the running patch is compared with
a persisted value scoped to this version/build. Rollback to the original release
is supported. Repeated taps cannot create concurrent downloads.

## Release requirement

`shorebird.yaml` now uses `auto_update: false`. Ship this configuration in a new
Shorebird-built store/TestFlight release; a Dart patch alone cannot reliably change
an already-shipped engine's automatic-update configuration. The Dart flow also
handles an already-downloaded patch and validates staging after update() returns.
Build with Shorebird to test actual patch download/activation. Ordinary Flutter
and debug builds correctly report patch updates unavailable.

Validation covers provider state transitions, stable targeting, no-op/failed
updates, pending rollback, installed patch detection and compact dialog/page UI.
A real staged patch on a Shorebird release remains necessary for end-to-end QA.
