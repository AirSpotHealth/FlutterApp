# Slim 0.22.0 controls

Slim firmware 0.22.0+ exposes Single shot (wire 1) and Continuous (wire 3), both reporting every 10 seconds. Older Slim and Screen controls retain their existing behavior. The settings page uses an existing tune icon rather than old frequency artwork. No image assets were added or changed.

Native FRC is available when the STCC4 native policy is verified, including with ASC enabled. The UI explains known stable reference air, the 60-second continuous preparation window and restoration of the selected measurement mode. The reference field supports 0–32000 ppm and explains that it does not change native ASC's baseline. Firmware 0.21 remains on its recovery-only flow. Unknown policy and errors fail closed.

First-hour guidance describes the brief white blink every 10 seconds after setup or sensor reset. The firmware distinguishes this from startup bypass and the 22-second conditioning command. Battery life remains unmeasured and no runtime estimate is presented as fact.

Validation: full existing Flutter suite passed (184 tests, one skipped); focused native ASC/recovery suite including the new ASC-on FRC visibility test passed (13 tests). Flutter analyzer passed. This code has not been published as a Shorebird patch; perform the release-specific asset/native compatibility check and phone QA before distribution.

Correction for firmware 0.22.1: compensation is refreshed every second in BOTH modes; only CO2 acquisition changes. The app wording now states this explicitly. The general BLE notification parser safely ignores extension responses handled by dedicated subscribers, including settling status 0x3C and preferences reset 0x3D. A regression test replays the reported 0x3C frame through the general parser and validates it with the settling decoder. This correction is source-only until the updated app is restarted/rebuilt or distributed as a patch.
