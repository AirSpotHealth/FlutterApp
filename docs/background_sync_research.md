# Background Data Sync Research

## Overview

This document outlines the research and planned approach for implementing background data synchronization. This feature has been deferred but the research is preserved here.

## Requirements

- Sync data from local storage (Isar) to Cloud (Supabase) even when the app is in the background.
- Handle "Forget & Reconnect" scenarios.
- Support both iOS and Android limitations.

## Platform Constraints

### Android

- **Mechanism**: `WorkManager`.
- **Frequency**: Minimum periodic interval is **15 minutes**.
- **Execution**: Can run reliably in the background.

### iOS

- **Mechanism**: `Background App Refresh` (BGAppRefreshTask) or `Background Processing` (BGProcessingTask).
- **Frequency**: **Non-deterministic**. The OS decides when to launch the task based on battery, usage patterns, and charging status. We cannot guarantee a specific interval (e.g., "every 15 mins").

## Implementation Strategy (Deferred)

1.  **Package**: Use `workmanager` for cross-platform support.
2.  **Logic**:
    - Register a `callbackDispatcher`.
    - Initialize `Isar` and `Supabase` inside the background isolate.
    - Call `SyncService().syncData()`.
3.  **Deduplication**: Relies on Supabase `upsert` with `onConflict: (device_id, timestamp, type)` to safely handle re-syncs.

## Setup Steps

- [ ] Add `workmanager` to `pubspec.yaml`.
- [ ] Android: Add `<provider>` and `<receiver>` to `AndroidManifest.xml`.
- [ ] iOS: Add `UIBackgroundModes` key to `Info.plist` and handle registration in `AppDelegate.swift`.
