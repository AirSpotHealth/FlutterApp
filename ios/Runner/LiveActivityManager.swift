//
//  LiveActivityManager.swift
//  Runner
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import Foundation
import ActivityKit

@available(iOS 16.2, *)
class LiveActivityManager {
    private var liveActivity: Activity<LiveActivityWidgetAttributes>? = nil
    private var userDismissedInCurrentSession = false
    private var activityMonitorTask: Task<Void, Never>?
       
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
        
        let attributes = LiveActivityWidgetAttributes()
        if let info = data {
            let state = LiveActivityWidgetAttributes.ContentState(
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
                lastUpdated: Date()
            )
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

        if let info = data {
            let updatedState = LiveActivityWidgetAttributes.ContentState(
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
                lastUpdated: Date()
            )
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
