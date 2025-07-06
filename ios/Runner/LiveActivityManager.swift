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
       
   
    func startLiveActivity(data: [String: Any]?) {
        let attributes = LiveActivityWidgetAttributes()
        if let info = data {
            let state = LiveActivityWidgetAttributes.ContentState(
                co2Value: info["co2Value"] as? Int ?? 0,
                powerMode: info["powerMode"] as? String ?? "3 Min",
                batteryLevel: info["batteryLevel"] as? Int ?? 0,
                alarmEnabled: info["alarmEnabled"] as? Bool ?? false,
                vibrationEnabled: info["vibrationEnabled"] as? Bool ?? false,
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
                }
            }
        }
    }

    func updateLiveActivity(data: [String: Any]?) {
        if liveActivity == nil {
            startLiveActivity(data: data)
            return
        }

        if let info = data {
            let updatedState = LiveActivityWidgetAttributes.ContentState(
                co2Value: info["co2Value"] as? Int ?? 0,
                powerMode: info["powerMode"] as? String ?? "3 Min",
                batteryLevel: info["batteryLevel"] as? Int ?? 0,
                alarmEnabled: info["alarmEnabled"] as? Bool ?? false,
                vibrationEnabled: info["vibrationEnabled"] as? Bool ?? false,
                lastUpdated: Date()
            )
            Task {
                do {
                    await liveActivity?.update(using: updatedState)
                    print("Live Activity updated successfully")
                } catch {
                    print("Error updating Live Activity: \(error)")
                }
            }
        }
    }
    
    func endLiveActivity() {
        Task {
            do {
                await self.liveActivity?.end(dismissalPolicy: .immediate)
                print("Live Activity ended successfully")
            } catch {
                print("Error ending Live Activity: \(error)")
            }
        }
    }
    
    func isLiveActivityActive() -> Bool {
        return liveActivity != nil
    }
}
