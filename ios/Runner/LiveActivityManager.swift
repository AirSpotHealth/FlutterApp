//
//  LiveActivityManager.swift
//  Runner
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import Foundation
// ActivityKit is only available in iOS 16.1+
#if canImport(ActivityKit)
import ActivityKit
#endif

// AppIntents is only available in iOS 16.0+
#if canImport(AppIntents)
import AppIntents
#endif

// Base protocol for Live Activity management
protocol LiveActivityManagerProtocol {
    func startLiveActivity(data: [String: Any]?)
    func updateLiveActivity(data: [String: Any]?)
    func startRefreshState()
    func endLiveActivity()
    func isLiveActivityActive() -> Bool
}

// Implementation for iOS 15.0 where Live Activities are not available
class LiveActivityManagerStub: LiveActivityManagerProtocol {
    func startLiveActivity(data: [String: Any]?) {
        print("Live Activities not available on iOS 15.0")
    }
    
    func updateLiveActivity(data: [String: Any]?) {
        print("Live Activities not available on iOS 15.0")
    }
    
    func startRefreshState() {
        print("Live Activities not available on iOS 15.0 - refresh state controlled by Flutter")
    }
    
    func endLiveActivity() {
        print("Live Activities not available on iOS 15.0")
    }
    
    func isLiveActivityActive() -> Bool {
        return false
    }
}

#if canImport(ActivityKit)
@available(iOS 16.2, *)
class LiveActivityManager: LiveActivityManagerProtocol {
    private var liveActivity: Activity<LiveActivityWidgetAttributes>? = nil
    private var activityMonitorTask: Task<Void, Never>?
    
    // Store device data and Live Activities for multiple devices (max 3)
    private var deviceStates: [String: [String: Any]] = [:]
    private var deviceActivities: [String: Activity<LiveActivityWidgetAttributes>] = [:]
    private let maxDevices = 3
    
    // Track dismissal intent to avoid unnecessary callbacks to Flutter
    private var isAppInitiatedDismissal = false
       
    init() {
        startActivityMonitoring()
        setupNotificationObservers()
    }
    
    deinit {
        activityMonitorTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        // Listen for restart requests from Live Activity
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRestartLiveActivityRequest(_:)),
            name: Notification.Name("RestartLiveActivityRequested"),
            object: nil
        )
    }
    
    @objc private func handleRestartLiveActivityRequest(_ notification: Notification) {
        print("🔄 Received restart Live Activity request from widget")
        
        guard let userInfo = notification.userInfo,
              let deviceId = userInfo["deviceId"] as? String else {
            print("❌ No device ID found in restart notification")
            return
        }
        
        print("🔄 Restarting Live Activity for device: \(deviceId)")
        
        // Navigate to device settings in Flutter
        let navigationInfo: [String: Any] = ["deviceId": deviceId]
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToDeviceSettings"),
            object: nil,
            userInfo: navigationInfo
        )
    }
    
    private func startActivityMonitoring() {
        activityMonitorTask?.cancel()
        activityMonitorTask = Task {
            // Start periodic monitoring for 3-hour refresh
            
            for await activity in Activity<LiveActivityWidgetAttributes>.activityUpdates {
                print("📱 Live Activity state changed: \(activity.activityState)")
                print("📱 Activity ID: \(activity.id)")
                print("📱 Our stored activity ID: \(liveActivity?.id ?? "none")")
                print("📱 isAppInitiatedDismissal flag: \(isAppInitiatedDismissal)")
                
                if activity.activityState == .dismissed {
                    print("🚫 Live Activity dismissed")

                    // Clear our reference since the activity is dismissed
                    if let currentActivity = liveActivity, currentActivity.id == activity.id {
                        print("🗑️ Clearing stored activity reference")
                        liveActivity = nil
                    }
                    
                    // Always send callback to Flutter for dismissal, regardless of who initiated it
                    // This ensures Flutter always knows when the live activity is gone
                    print("📤 Sending dismissal notification to Flutter")
                    
                    // Post notification to AppDelegate to notify Flutter about dismissal
                    // Since we can have multiple Live Activities, we'll notify about all dismissals
                    let userInfo: [String: Any] = ["deviceId": "all"] // "all" means all devices
                    NotificationCenter.default.post(
                        name: Notification.Name("LiveActivityDismissed"),
                        object: nil,
                        userInfo: userInfo
                    )
                    print("✅ Posted LiveActivityDismissed notification with userInfo: \(userInfo)")
                    
                    // Reset the flag for next dismissal
                    isAppInitiatedDismissal = false
                } else if activity.activityState == .stale {
                    print("⚠️ Live Activity became stale (exceeded duration limit)")

                    // Find which device activity became stale and clean it up
                    if let (deviceId, _) = self.deviceActivities.first(where: { $0.value.id == activity.id }) {
                        print("🗑️ Device activity for \(deviceId) is stale. Removing reference.")
                        self.deviceActivities.removeValue(forKey: deviceId)
                    } else if let currentActivity = liveActivity, currentActivity.id == activity.id {
                        // Backward compatibility for single activity
                        print("🗑️ Main Live Activity is stale. Removing reference.")
                        liveActivity = nil
                    }
                } else if activity.activityState == .active {
                    print("✅ Live Activity is active")
                    // Ensure we have the correct reference
                    if liveActivity?.id != activity.id {
                        print("🔄 Updating activity reference to active activity")
                        liveActivity = activity
                    }
                }
            }
        }
    }
    
    private func isActivityActive() -> Bool {
        // Consider active if any per-device activity is running
        return !deviceActivities.isEmpty
    }
    
    private func cleanupStaleActivity() {
        if let activity = liveActivity, !Activity<LiveActivityWidgetAttributes>.activities.contains(where: { $0.id == activity.id }) {
            print("Cleaning up stale activity reference")
            liveActivity = nil
        }
    }
    
    private func createContentState(from data: [String: Any]?) -> LiveActivityWidgetAttributes.ContentState {
        let currentTime = Date()
        
        guard let info = data else {
            return LiveActivityWidgetAttributes.ContentState(
                deviceId: "1234567890",
                deviceName: "AirSpot Device",
                co2Value: 0,
                powerMode: "3 Min",
                batteryLevel: 0,
                isCharging: false,
                alarmEnabled: false,
                vibrationEnabled: false,
                co2History: [],
                greenUpperLimit: 800,
                yellowUpperLimit: 1000,
                graphMaxValue: 1600,
                graphMinValue: 0,
                isRefreshing: false,
                isConnected: false,
                lastUpdated: currentTime,
                activityStartTime: currentTime,
                showStaleWarning: false
            )
        }
        
        // Get activity start time from data (milliseconds since epoch), or use current time if starting new
        let activityStartTimeMs = info["activityStartTime"] as? Int64
        let activityStartTime = activityStartTimeMs != nil ? Date(timeIntervalSince1970: Double(activityStartTimeMs!) / 1000.0) : currentTime
        
        // Calculate if we should show stale warning (last 10 minutes before 8 hours)
        let timeElapsed = currentTime.timeIntervalSince(activityStartTime)
        
        // DEBUG MODE: Use shorter times for testing
        // Production: 8 hours total, 10 minutes warning
        // Debug: 2 minutes total, 30 seconds warning
        #if DEBUG
        let totalDurationInSeconds: TimeInterval = 2 * 60 // 2 minutes for testing
        let warningTimeInSeconds: TimeInterval = 30 // 30 seconds warning
        #else
        let totalDurationInSeconds: TimeInterval = 8 * 60 * 60 // 8 hours
        let warningTimeInSeconds: TimeInterval = 10 * 60 // 10 minutes
        #endif
        
        let showStaleWarning = timeElapsed >= (totalDurationInSeconds - warningTimeInSeconds)
        
        return LiveActivityWidgetAttributes.ContentState(
            deviceId: info["deviceId"] as? String ?? "1234567890",
            deviceName: info["deviceName"] as? String ?? "AirSpot Device",
            co2Value: info["co2Value"] as? Int ?? 0,
            powerMode: info["powerMode"] as? String ?? "3 Min",
            batteryLevel: info["batteryLevel"] as? Int ?? 0,
            isCharging: info["isCharging"] as? Bool ?? false,
            alarmEnabled: info["alarmEnabled"] as? Bool ?? false,
            vibrationEnabled: info["vibrationEnabled"] as? Bool ?? false,
            co2History: info["co2History"] as? [Int] ?? [],
            greenUpperLimit: info["greenUpperLimit"] as? Int ?? 800,
            yellowUpperLimit: info["yellowUpperLimit"] as? Int ?? 1000,
            graphMaxValue: info["graphMaxValue"] as? Int ?? 1600,
            graphMinValue: info["graphMinValue"] as? Int ?? 0,
            isRefreshing: info["isRefreshing"] as? Bool ?? false,
            isConnected: info["isConnected"] as? Bool ?? false,
            lastUpdated: currentTime,
            activityStartTime: activityStartTime,
            showStaleWarning: showStaleWarning
        )
    }
    
    
    func startLiveActivity(data: [String: Any]?) {
        guard let data = data,
              let deviceId = data["deviceId"] as? String else {
            print("❌ No device ID found in data, cannot start Live Activity")
            return
        }
        
        // Store device data
        deviceStates[deviceId] = data
        
        // Check if we already have a Live Activity for this device
        if let existingActivity = deviceActivities[deviceId] {
            print("📱 Live Activity already exists for device: \(deviceId), updating instead")
            updateLiveActivity(data: data)
            return
        }
        
        // Check if we've reached the maximum number of devices
        if deviceActivities.count >= maxDevices {
            print("⚠️ Maximum number of devices (\(maxDevices)) reached, cannot add device: \(deviceId)")
            return
        }
        
        // Start Live Activity for this specific device
        Task {
            await performStartDeviceLiveActivity(deviceId: deviceId, data: data)
        }
    }
    
    private func performStartLiveActivity(data: [String: Any]?) async {
        let attributes = LiveActivityWidgetAttributes()
        let state = createContentState(from: data)
        
        // Set stale date based on debug/production mode
        #if DEBUG
        let staleDate = Date().addingTimeInterval(2 * 60) // 2 minutes for testing
        #else
        let staleDate = Date().addingTimeInterval(8 * 60 * 60) // 8 hours
        #endif
        
        do {
            liveActivity = try Activity<LiveActivityWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: staleDate),
                pushType: .none
            )
            print("✅ Live Activity started successfully")
        } catch {
            print("❌ Error starting Live Activity: \(error)")
            liveActivity = nil
            
            // If starting fails, it might be due to system limitations
            // Try again after a brief delay
            let errorString = error.localizedDescription
            if errorString.contains("TooManyActivitiesError") || errorString.contains("ActivityLimitExceeded") {
                print("🔄 Too many activities, cleaning up and retrying...")
                // End all activities and retry
                let existingActivities = Activity<LiveActivityWidgetAttributes>.activities
                for activity in existingActivities {
                    await activity.end(dismissalPolicy: .immediate)
                }
                // Wait a moment and retry
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                do {
                    liveActivity = try Activity<LiveActivityWidgetAttributes>.request(
                        attributes: attributes,
                        content: .init(state: state, staleDate: staleDate),
                        pushType: .none
                    )
                    print("✅ Live Activity started successfully on retry")
                } catch {
                    print("❌ Failed to start Live Activity even after cleanup: \(error)")
                }
            }
        }
    }
    
    private func performStartDeviceLiveActivity(deviceId: String, data: [String: Any]) async {
        let attributes = LiveActivityWidgetAttributes()
        let state = createContentState(from: data)
        
        // Set stale date based on debug/production mode
        #if DEBUG
        let staleDate = Date().addingTimeInterval(2 * 60) // 2 minutes for testing
        #else
        let staleDate = Date().addingTimeInterval(8 * 60 * 60) // 8 hours
        #endif
        
        do {
            let activity = try Activity<LiveActivityWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: staleDate),
                pushType: .none
            )
            
            // Store the activity for this device
            deviceActivities[deviceId] = activity
            
            print("✅ Live Activity started successfully for device: \(deviceId)")
            print("📊 Total active Live Activities: \(deviceActivities.count)")
        } catch {
            print("❌ Error starting Live Activity for device \(deviceId): \(error)")
        }
    }

    func updateLiveActivity(data: [String: Any]?) {
        guard let data = data,
              let deviceId = data["deviceId"] as? String else {
            print("❌ No device ID found in data, cannot update Live Activity")
            return
        }
        
        // Store device data
        deviceStates[deviceId] = data
        
        // Check if we have a Live Activity for this device
        guard let activity = deviceActivities[deviceId] else {
            print("No Live Activity found for device: \(deviceId), starting new one")
            startLiveActivity(data: data)
            return
        }
        
        // Update the specific device's Live Activity
        let updatedState = createContentState(from: data)
        
        Task {
            do {
                await activity.update(using: updatedState)
                print("Live Activity updated successfully for device: \(deviceId)")
            } catch {
                print("Error updating Live Activity for device \(deviceId): \(error)")
                // If update fails, the activity might be stale, clean it up
                deviceActivities.removeValue(forKey: deviceId)
            }
        }
    }
    
    func startRefreshState() {
        // Refresh state is now controlled by Flutter via updateLiveActivity data
        print("startRefreshState called - refresh state is now controlled by Flutter via data updates")
    }
    

    
    func endLiveActivity() {
        // This is app-initiated dismissal (user toggled setting OFF)
        
        if deviceActivities.isEmpty {
            print("No active Live Activities to end")
            liveActivity = nil
            return
        }
        
        // Mark this as app-initiated dismissal to avoid callback to Flutter
        isAppInitiatedDismissal = true
        
        Task {
            // End all device activities
            for (deviceId, activity) in deviceActivities {
                do {
                    await activity.end(dismissalPolicy: .immediate)
                    print("Live Activity ended successfully for device: \(deviceId)")
                } catch {
                    print("Error ending Live Activity for device \(deviceId): \(error)")
                }
            }
            
            // Clear all references
            deviceActivities.removeAll()
            deviceStates.removeAll()
            liveActivity = nil
        }
    }
    
    func isLiveActivityActive() -> Bool {
        return !deviceActivities.isEmpty
    }
    
    
    /// Reset the dismissal state flag
    func resetDismissalState() {
        isAppInitiatedDismissal = false
        print("🔄 Dismissal state reset")
    }
    
    /// Force clean up all existing activities and start fresh
    func forceCleanupAndRestart(data: [String: Any]?) {
        print("🧹 Force cleanup and restart requested")
        
        Task {
            // End all existing activities
            let existingActivities = Activity<LiveActivityWidgetAttributes>.activities
            for activity in existingActivities {
                print("🗑️ Force ending activity: \(activity.id)")
                await activity.end(dismissalPolicy: .immediate)
            }
            
            // Clear internal state
            liveActivity = nil
            
            // Wait for clean transition
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Start fresh if data provided
            if let data = data {
                print("🔄 Starting fresh Live Activity after cleanup")
                await performStartLiveActivity(data: data)
            }
        }
    }
    
    // MARK: - Multiple Device Management
    
    /// Add or update device data
    func addDeviceData(deviceId: String, data: [String: Any]) {
        deviceStates[deviceId] = data
        print("📱 Added/updated data for device: \(deviceId)")
        
        // Start or update Live Activity for this device
        if deviceActivities[deviceId] != nil {
            updateLiveActivity(data: data)
        } else {
            startLiveActivity(data: data)
        }
    }
    
    /// Remove device data
    func removeDeviceData(deviceId: String) {
        deviceStates.removeValue(forKey: deviceId)
        print("📱 Removed data for device: \(deviceId)")
        
        // End the Live Activity for this specific device
        if let activity = deviceActivities[deviceId] {
            Task {
                do {
                    await activity.end(dismissalPolicy: .immediate)
                    print("Live Activity ended for device: \(deviceId)")
                } catch {
                    print("Error ending Live Activity for device \(deviceId): \(error)")
                }
            }
            deviceActivities.removeValue(forKey: deviceId)
        }
    }
    
    /// Switch to a different device (not needed with multiple Live Activities)
    func switchToDevice(deviceId: String) {
        guard let deviceData = deviceStates[deviceId] else {
            print("❌ No data found for device: \(deviceId)")
            return
        }
        
        print("📱 Switching to device: \(deviceId) - updating Live Activity")
        
        // With multiple Live Activities, we just update the specific device's activity
        updateLiveActivity(data: deviceData)
    }
    
    /// Get all tracked device IDs
    func getTrackedDevices() -> [String] {
        return Array(deviceStates.keys)
    }
    
    /// Get the currently active device IDs (all tracked devices)
    func getActiveDeviceId() -> [String] {
        return Array(deviceStates.keys)
    }
    
    /// Check if a device is being tracked
    func isDeviceTracked(deviceId: String) -> Bool {
        return deviceStates[deviceId] != nil
    }
    
    func getLiveActivityState(deviceId: String) -> String {
        guard let activity = deviceActivities[deviceId] else {
            return "none"
        }
        
        switch activity.activityState {
        case .active:
            return "active"
        case .stale:
            return "stale"
        case .ended:
            return "ended"
        case .dismissed:
            return "dismissed"
        @unknown default:
            return "unknown"
        }
    }
}
#endif

// Factory function to create the appropriate manager based on iOS version
func createLiveActivityManager() -> LiveActivityManagerProtocol {
    if #available(iOS 16.2, *) {
        #if canImport(ActivityKit)
        return LiveActivityManager()
        #else
        return LiveActivityManagerStub()
        #endif
    } else {
        return LiveActivityManagerStub()
    }
}
