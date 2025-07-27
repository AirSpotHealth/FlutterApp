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
        print("Live Activities not available on iOS 15.0 - refresh state controlled by Flutter")
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
    
    // Store last valid state for activity management
    private var lastValidState: [String: Any]?
       
    init() {
        // Reset dismissal state on fresh app launch
        userDismissedInCurrentSession = false
        startActivityMonitoring()
    }
    
    deinit {
        activityMonitorTask?.cancel()
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
    
    private func createContentState(from data: [String: Any]?) -> LiveActivityWidgetAttributes.ContentState {
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
                isRefreshing: false,
                isConnected: false,
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
            isRefreshing: info["isRefreshing"] as? Bool ?? false,
            isConnected: info["isConnected"] as? Bool ?? false,
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
        // Refresh state is now controlled by Flutter via updateLiveActivity data
        print("startRefreshState called - refresh state is now controlled by Flutter via data updates")
    }
    

    
    func endLiveActivity() {
        // This is app-initiated dismissal (user toggled setting OFF)
        // Reset the user dismissal flag since this is intentional
        userDismissedInCurrentSession = false
        
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
