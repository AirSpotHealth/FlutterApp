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
    func resetDismissalState()
    func isLiveActivityActive() -> Bool
    func wasUserDismissedThisSession() -> Bool
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
        print("Live Activities not available on iOS 15.0")
    }
    
    func endLiveActivity() {
        print("Live Activities not available on iOS 15.0")
    }
    
    func resetDismissalState() {
        print("Live Activities not available on iOS 15.0")
    }
    
    func isLiveActivityActive() -> Bool {
        return false
    }
    
    func wasUserDismissedThisSession() -> Bool {
        return false
    }
}

#if canImport(ActivityKit)
@available(iOS 16.2, *)
class LiveActivityManager: LiveActivityManagerProtocol {
    private var liveActivity: Activity<LiveActivityWidgetAttributes>? = nil
    private var userDismissedInCurrentSession = false
    private var activityMonitorTask: Task<Void, Never>?
    
    // Refresh state management
    private var isRefreshing = false
    private var refreshTimer: Timer?
    private var lastValidState: [String: Any]?
       
    init() {
        // Reset dismissal state on fresh app launch
        userDismissedInCurrentSession = false
        startActivityMonitoring()
    }
    
    deinit {
        activityMonitorTask?.cancel()
        refreshTimer?.invalidate()
    }
    
    private func startActivityMonitoring() {
        activityMonitorTask?.cancel()
        activityMonitorTask = Task {
            for await activity in Activity<LiveActivityWidgetAttributes>.activityUpdates {
                if activity.activityState == .dismissed {
                    print("User dismissed Live Activity manually")
                    userDismissedInCurrentSession = true
                    // Clear our reference since the activity is dismissed
                    if let currentActivity = liveActivity, currentActivity.id == activity.id {
                        liveActivity = nil
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
        }
    }
    
    private func createContentState(from data: [String: Any]?, isRefreshing: Bool = false) -> LiveActivityWidgetAttributes.ContentState {
        guard let info = data else {
            return LiveActivityWidgetAttributes.ContentState(
                deviceId: "1234567890",
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
                isRefreshing: isRefreshing,
                lastUpdated: Date()
            )
        }
        
        return LiveActivityWidgetAttributes.ContentState(
            deviceId: info["deviceId"] as? String ?? "1234567890",
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
            isRefreshing: isRefreshing,
            lastUpdated: Date()
        )
    }
   
    func startLiveActivity(data: [String: Any]?) {
        // Check if user dismissed it manually this session
        if userDismissedInCurrentSession {
            print("User dismissed Live Activity this session, not starting new one")
            return
        }
        
        // Clean up any stale activity references first
        cleanupStaleActivity()
        
        // If we already have an active activity, don't start a new one
        if isActivityActive() {
            print("Live Activity already active, skipping start")
            return
        }
        
        // Store the data for potential refresh scenarios
        lastValidState = data
        
        let attributes = LiveActivityWidgetAttributes()
        let state = createContentState(from: data)
        
        Task {
            do {
                liveActivity = try Activity<LiveActivityWidgetAttributes>.request(
                    attributes: attributes,
                    content: .init(state: state, staleDate: nil),
                    pushType: .none
                )
                print("Live Activity started successfully")
            } catch {
                print("Error starting Live Activity: \(error)")
                liveActivity = nil
            }
        }
    }

    func updateLiveActivity(data: [String: Any]?) {
        // Check if user dismissed it manually this session
        if userDismissedInCurrentSession {
            print("User dismissed Live Activity this session, not updating or restarting")
            return
        }
        
        // Clean up any stale activity references first
        cleanupStaleActivity()
        
        // If no active activity, start one
        if !isActivityActive() {
            print("No active Live Activity found, starting new one")
            startLiveActivity(data: data)
            return
        }
        
        // Stop refresh state and timer if new data arrives
        if isRefreshing {
            stopRefreshState()
        }
        
        // Store the new valid data
        lastValidState = data
        
        let updatedState = createContentState(from: data)
        
        Task {
            do {
                await liveActivity?.update(using: updatedState)
                print("Live Activity updated successfully")
            } catch {
                print("Error updating Live Activity: \(error)")
                // If update fails, the activity might be stale, clean it up
                liveActivity = nil
            }
        }
    }
    
    func startRefreshState() {
        // Only start refresh if we have an active activity and valid last state
        guard isActivityActive(), let lastState = lastValidState, isRefreshing == false else {
            print("Cannot start refresh: no active activity or no last valid state or already refreshing")
            return
        }
        
        print("Starting refresh state with blink animation")
        isRefreshing = true
        
        // Update the live activity with refresh state
        let refreshState = createContentState(from: lastState, isRefreshing: true)
        
        Task {
            do {
                await liveActivity?.update(using: refreshState)
                print("Live Activity updated with refresh state")
            } catch {
                print("Error updating Live Activity with refresh state: \(error)")
            }
        }
        
        // Start 6-second timeout timer
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { [weak self] _ in
            self?.stopRefreshState()
        }
    }
    
    private func stopRefreshState() {
        guard isRefreshing else { return }
        
        print("Stopping refresh state")
        isRefreshing = false
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        // Update the live activity to stop the refresh state
        guard let lastState = lastValidState else { return }
        
        let normalState = createContentState(from: lastState, isRefreshing: false)
        
        Task {
            do {
                await liveActivity?.update(using: normalState)
                print("Live Activity updated to normal state after refresh")
            } catch {
                print("Error updating Live Activity to normal state: \(error)")
            }
        }
    }
    
    func endLiveActivity() {
        // This is app-initiated dismissal (user toggled setting OFF)
        // Reset the user dismissal flag since this is intentional
        userDismissedInCurrentSession = false
        
        // Clean up refresh state
        stopRefreshState()
        
        if !isActivityActive() {
            print("No active Live Activity to end")
            liveActivity = nil
            return
        }
        
        Task {
            do {
                await self.liveActivity?.end(dismissalPolicy: .immediate)
                self.liveActivity = nil
                print("Live Activity ended successfully")
            } catch {
                print("Error ending Live Activity: \(error)")
                // Even if ending fails, clear the reference
                self.liveActivity = nil
            }
        }
    }
    
    func resetDismissalState() {
        // This can be called when app comes to foreground from background
        // to reset the dismissal state for new session
        userDismissedInCurrentSession = false
        print("Live Activity dismissal state reset for new session")
    }
    
    func isLiveActivityActive() -> Bool {
        return isActivityActive()
    }
    
    func wasUserDismissedThisSession() -> Bool {
        return userDismissedInCurrentSession
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
