# Slim app fixes: iOS 3.8.14+162, patch 3

Published to Shorebird Stable for app 6c351c5c-eab0-4e29-8001-4b559248254e.
Source: 2a7a9ba on codex/stcc4-recovery-guidance. Flutter 3.47.7, arm64.
Includes recovery guidance, consistent buttons and customer errors, neutral
sensor preparation, and offline Forget Device.

The initial dry run caught a new hourglass_top glyph absent from the shipped
Material font. Replaced it with the already-shipped hourglass_empty glyph.
The final font was byte-identical to the original release. The only manifest
change was removal of assets/images/.DS_Store, with all other decoded entries
identical. The final Shorebird command passed without asset/native overrides.

Validation: 184 app tests passed with one skipped before the icon adjustment;
the three preparation UI tests passed after it. Shorebird built and verified
the iOS archive, uploaded the 2.63 MB patch, and promoted patch 3 to Stable.

Shorebird reported 82.3% shared Dart code and warned of possible slower execution.
On-phone patch activation, UI behaviour and performance remain to be checked.
This patch targets only iOS 3.8.14+162; it does not update older releases or Android.

On the installed app, open App Setup → App Updates, download the update, then
fully close and reopen the app. Do not restart the app during sensor DFU.
