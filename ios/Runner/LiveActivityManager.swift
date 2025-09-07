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
    
    func getLiveActivityDuration() -> TimeInterval {
        return 0
    }
    
    func willNeedRefreshSoon() -> Bool {
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
    
    // Track when the current Live Activity was started for duration management
    private var activityStartTime: Date?
    
    // Track dismissal intent to avoid unnecessary callbacks to Flutter
    private var isAppInitiatedDismissal = false
    
    // Live Activity duration limits (iOS default is 8 hours)
    private let maxActivityDuration: TimeInterval = 8 * 60 * 60 // 8 hours
    private let refreshThreshold: TimeInterval = 3 * 60 * 60 // 3 hours - proactive refresh to avoid 8hr limit
    private let warningThreshold: TimeInterval = 2.5 * 60 * 60 // 2.5 hours - warning before refresh
       
    init() {
        startActivityMonitoring()
    }
    
    deinit {
        activityMonitorTask?.cancel()
    }
    
    private func startActivityMonitoring() {
        activityMonitorTask?.cancel()
        activityMonitorTask = Task {
            // Start periodic monitoring for 3-hour refresh
            startPeriodicRefreshMonitoring()
            
            for await activity in Activity<LiveActivityWidgetAttributes>.activityUpdates {
                print("📱 Live Activity state changed: \(activity.activityState)")
                print("📱 Activity ID: \(activity.id)")
                print("📱 Our stored activity ID: \(liveActivity?.id ?? "none")")
                print("📱 isAppInitiatedDismissal flag: \(isAppInitiatedDismissal)")
                
                if activity.activityState == .dismissed {
                    print("🚫 Live Activity dismissed")

                    // Clear our reference and timestamp since the activity is dismissed
                    if let currentActivity = liveActivity, currentActivity.id == activity.id {
                        print("🗑️ Clearing stored activity reference")
                        liveActivity = nil
                        activityStartTime = nil
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
                    
                    // Clear our reference and timestamp since the activity is stale
                    if let currentActivity = liveActivity, currentActivity.id == activity.id {
                        print("🔄 Activity became stale, cleaning up references")
                        liveActivity = nil
                        activityStartTime = nil
                        
                        // Automatically restart if we have valid data and any device is still connected
                        var shouldRestart = false
                        for (deviceId, lastData) in self.deviceStates {
                            if let isConnected = lastData["isConnected"] as? Bool, isConnected == true {
                                print("🔄 Device \(deviceId) is still connected, automatically restarting stale Live Activity")
                                shouldRestart = true
                                break
                            }
                        }
                        
                        if shouldRestart {
                            // Wait a moment before restarting to ensure clean transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                // Restart Live Activities for all connected devices
                                for (deviceId, lastData) in self.deviceStates {
                                    if let isConnected = lastData["isConnected"] as? Bool, isConnected == true {
                                        self.startLiveActivity(data: lastData)
                                    }
                                }
                            }
                        } else {
                            print("📱 No devices connected, not restarting stale activity")
                        }
                    }
                } else if activity.activityState == .active {
                    print("✅ Live Activity is active")
                    // Ensure we have the correct reference
                    if liveActivity?.id != activity.id {
                        print("🔄 Updating activity reference to active activity")
                        liveActivity = activity
                        if activityStartTime == nil {
                            activityStartTime = Date()
                        }
                    }
                }
            }
        }
    }
    
    private func isActivityActive() -> Bool {
        guard let activity = liveActivity else { return false }
        return Activity<LiveActivityWidgetAttributes>.activities.contains(where: { $0.id == activity.id })
    }
    
    private func cleanupStaleActivity() {
        if let activity = liveActivity, !Activity<LiveActivityWidgetAttributes>.activities.contains(where: { $0.id == activity.id }) {
            print("Cleaning up stale activity reference")
            liveActivity = nil
            activityStartTime = nil
        }
    }
    
    private func createContentState(from data: [String: Any]?) -> LiveActivityWidgetAttributes.ContentState {
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
                lastUpdated: Date()
            )
        }
        
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
            lastUpdated: Date()
        )
    }
    
    /// Check if the current Live Activity is approaching the 3-hour refresh threshold
    private func isApproachingDurationLimit() -> Bool {
        guard let startTime = activityStartTime else { return false }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed >= refreshThreshold
    }
    
    /// Check if the current Live Activity is approaching the warning threshold (2.5 hours)
    private func isApproachingWarningThreshold() -> Bool {
        guard let startTime = activityStartTime else { return false }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed >= warningThreshold
    }
    
    /// Check if the current Live Activity has exceeded the duration limit
    private func hasExceededDurationLimit() -> Bool {
        guard let startTime = activityStartTime else { return false }
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed >= maxActivityDuration
    }
    
    /// Get the remaining time before the Live Activity needs to be refreshed (3-hour threshold)
    private func timeUntilRefreshNeeded() -> TimeInterval {
        guard let startTime = activityStartTime else { return 0 }
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, refreshThreshold - elapsed)
    }
    
    /// Proactively refresh the Live Activity by ending the current one and starting a new one
    private func refreshLiveActivity() {
        guard !self.deviceStates.isEmpty else {
            print("No device data available for Live Activity refresh")
            return
        }
        
        print("Refreshing Live Activity proactively (approaching 3-hour limit to avoid 8-hour iOS restriction)")
        
        // Mark this as app-initiated dismissal to avoid callback to Flutter
        isAppInitiatedDismissal = true
        
        // End all current activities and start new ones
        Task {
            // End all device activities
            for (deviceId, activity) in self.deviceActivities {
                await activity.end(dismissalPolicy: .immediate)
            }
            self.deviceActivities.removeAll()
            self.liveActivity = nil
            self.activityStartTime = nil
            
            // Brief delay to ensure clean transition
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Start new activities for all connected devices
            for (deviceId, lastData) in self.deviceStates {
                if let isConnected = lastData["isConnected"] as? Bool, isConnected == true {
                    self.startLiveActivity(data: lastData)
                }
            }
        }
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
        
        // Set a stale date to help iOS manage the activity lifecycle
        let staleDate = Date().addingTimeInterval(maxActivityDuration)
        
        // Record start time for duration tracking
        activityStartTime = Date()
        
        do {
            liveActivity = try Activity<LiveActivityWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: staleDate),
                pushType: .none
            )
            print("✅ Live Activity started successfully at \(activityStartTime!)")
            print("📅 Will become stale at: \(staleDate)")
            print("⏰ Proactive refresh scheduled in: \(timeUntilRefreshNeeded() / 3600) hours")
        } catch {
            print("❌ Error starting Live Activity: \(error)")
            liveActivity = nil
            activityStartTime = nil
            
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
                    activityStartTime = Date()
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
        
        // Set a stale date to help iOS manage the activity lifecycle
        let staleDate = Date().addingTimeInterval(maxActivityDuration)
        
        do {
            let activity = try Activity<LiveActivityWidgetAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: staleDate),
                pushType: .none
            )
            
            // Store the activity for this device
            deviceActivities[deviceId] = activity
            
            print("✅ Live Activity started successfully for device: \(deviceId)")
            print("📅 Will become stale at: \(staleDate)")
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
            activityStartTime = nil
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
            activityStartTime = nil
        }
    }
    
    func isLiveActivityActive() -> Bool {
        return !deviceActivities.isEmpty
    }
    
    /// Get the current Live Activity duration in seconds (for debugging)
    func getLiveActivityDuration() -> TimeInterval {
        guard let startTime = activityStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Check if the Live Activity will need refresh soon (for debugging)
    func willNeedRefreshSoon() -> Bool {
        return isApproachingDurationLimit()
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
            activityStartTime = nil
            
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
    
    // MARK: - Periodic Refresh Monitoring
    
    /// Start periodic monitoring to ensure Live Activity is refreshed every 3 hours
    private func startPeriodicRefreshMonitoring() {
        Task {
            while !Task.isCancelled {
                // Check every 30 minutes if we need to refresh
                try? await Task.sleep(nanoseconds: 30 * 60 * 1_000_000_000) // 30 minutes
                
                if isActivityActive() && isApproachingDurationLimit() {
                    print("⏰ Periodic check: Live Activity approaching 3-hour limit, refreshing...")
                    refreshLiveActivity()
                } else if isActivityActive() && isApproachingWarningThreshold() {
                    print("⚠️ Periodic check: Live Activity approaching 2.5-hour warning threshold")
                }
            }
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
