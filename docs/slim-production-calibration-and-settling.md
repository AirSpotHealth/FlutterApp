# Slim calibration and first-hour settling UI

Current Slim firmware uses read-only auto-calibration status: there is no toggle
or app action for turning it off. Forced recalibration is shown only after
verified enabled status on compatible firmware. Older devices with a saved OFF
setting receive firmware-update guidance. Screen controls retain their existing
behaviour.

Customer wording uses “Forced recalibration”, “Auto-calibration” and “Sensor
settling”; no sensor-vendor name, internal native/host terminology, or inactive
calibration-erase history appears in current Slim calibration UI. The legacy
12-hour guidance card is hidden for firmware 0.22 and later.

First-hour progress comes from firmware 0.22.4 command 0x3E, with a validated
versioned packet. Cards show it only for connected Slim devices reporting an
active interval. Phone time is not used to advance progress. A shared auto-
disposed provider polls every 30 seconds while observed, cancels on completion,
and is invalidated after sensor reset. Reconnect obtains a fresh snapshot.

Colours, typography, buttons and spacing use the existing app theme. The
rendered component preview is ui-previews/slim-calibration-and-settling.png;
it combines actual components with a fixture status for layout inspection.
No new bundled assets or fonts are required. A mobile build/patch and firmware
0.22.4 deployment are required for the first-hour card to work on a device.
