//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // CO2 Value
        var co2Value: Int
        // Power Mode
        var powerMode: String
        // Battery Level
        var batteryLevel: Int
        // Alarm Enabled
        var alarmEnabled: Bool
        // Vibration Enabled
        var vibrationEnabled: Bool
        // Last Updated
        var lastUpdated: Date
    }
}

struct LiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack(spacing: 16) {
                // CO2 Value Section
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(co2Color(for: context.state.co2Value))
                            .font(.system(size: 16, weight: .medium))
                        Text("CO₂")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(context.state.co2Value)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(co2Color(for: context.state.co2Value))
                        Text("ppm")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .offset(y: -2)
                    }
                }
                
                Spacer()
                
                // Status Section
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 12) {
                        // Battery
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: context.state.batteryLevel))
                                .foregroundColor(batteryColor(for: context.state.batteryLevel))
                                .font(.system(size: 14, weight: .medium))
                            Text("\(context.state.batteryLevel)%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        // Power Mode
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                                .font(.system(size: 14, weight: .medium))
                            Text(context.state.powerMode)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Alarm & Vibration Status
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: context.state.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                .foregroundColor(context.state.alarmEnabled ? .orange : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Alarm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: context.state.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .foregroundColor(context.state.vibrationEnabled ? .purple : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Vibration")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "cloud.fill")
                                .foregroundColor(co2Color(for: context.state.co2Value))
                                .font(.system(size: 16, weight: .medium))
                            Text("CO₂")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("\(context.state.co2Value)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(co2Color(for: context.state.co2Value))
                            Text("ppm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                                .offset(y: -2)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: context.state.batteryLevel))
                                .foregroundColor(batteryColor(for: context.state.batteryLevel))
                                .font(.system(size: 14, weight: .medium))
                            Text("\(context.state.batteryLevel)%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .medium))
                            Text(context.state.powerMode)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: context.state.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                .foregroundColor(context.state.alarmEnabled ? .orange : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Alarm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: context.state.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .foregroundColor(context.state.vibrationEnabled ? .purple : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Vibration")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Updated \(context.state.lastUpdated.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(co2Color(for: context.state.co2Value))
                        .font(.system(size: 12, weight: .medium))
                    Text("\(context.state.co2Value)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(co2Color(for: context.state.co2Value))
                }
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(for: context.state.batteryLevel))
                        .foregroundColor(batteryColor(for: context.state.batteryLevel))
                        .font(.system(size: 12, weight: .medium))
                    Text("\(context.state.batteryLevel)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            } minimal: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(co2Color(for: context.state.co2Value))
                    .font(.system(size: 12, weight: .medium))
            }
        }
    }
    
    // Helper functions for dynamic colors and icons
    private func co2Color(for value: Int) -> Color {
        switch value {
        case 0...400:
            return .green
        case 401...800:
            return .yellow
        case 801...1200:
            return .orange
        default:
            return .red
        }
    }
    
    private func batteryColor(for level: Int) -> Color {
        switch level {
        case 0...20:
            return .red
        case 21...50:
            return .orange
        default:
            return .green
        }
    }
    
    private func batteryIcon(for level: Int) -> String {
        switch level {
        case 0...10:
            return "battery.0percent"
        case 11...25:
            return "battery.25percent"
        case 26...50:
            return "battery.50percent"
        case 51...75:
            return "battery.75percent"
        default:
            return "battery.100percent"
        }
    }
}

extension LiveActivityWidgetAttributes {
    fileprivate static var preview: LiveActivityWidgetAttributes {
        LiveActivityWidgetAttributes()
    }
}

extension LiveActivityWidgetAttributes.ContentState {
    fileprivate static var sampleData: LiveActivityWidgetAttributes.ContentState {
        LiveActivityWidgetAttributes.ContentState(co2Value: 450, powerMode: "3 Min", batteryLevel: 85, alarmEnabled: true, vibrationEnabled: true, lastUpdated: Date())
     }
     
     fileprivate static var lowBatteryData: LiveActivityWidgetAttributes.ContentState {
         LiveActivityWidgetAttributes.ContentState(co2Value: 1200, powerMode: "1 Min", batteryLevel: 25, alarmEnabled: false, vibrationEnabled: true, lastUpdated: Date())
     }
}

// Preview removed to avoid build issues - test directly from the app
