//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Charts

struct LiveActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // CO2 Value
        var co2Value: Int
        // Power Mode
        var powerMode: String
        // Battery Level
        var batteryLevel: Int
        // Is Charging
        var isCharging: Bool
        // Alarm Enabled
        var alarmEnabled: Bool
        // Vibration Enabled
        var vibrationEnabled: Bool
        // CO2 History
        var co2History: [Int]
        // Thresholds
        var greenUpperLimit: Int
        var yellowUpperLimit: Int
        // Graph Range
        var graphMaxValue: Int
        var graphMinValue: Int
        // Last Updated
        var lastUpdated: Date
    }
}

import Charts

struct Co2GraphView: View {
    let co2History: [Int]
    let greenUpperLimit: Int
    let yellowUpperLimit: Int
    let graphMaxValue: Int
    let graphMinValue: Int

    private func co2Color(for value: Int) -> Color {
        if value <= greenUpperLimit {
            return .green
        } else if value <= yellowUpperLimit {
            return .orange
        } else {
            return .red
        }
    }
    
    private func normalizedHeight(for value: Int) -> CGFloat {
        let range = graphMaxValue - graphMinValue
        let normalizedValue = max(0, min(value - graphMinValue, range))
        return CGFloat(normalizedValue) / CGFloat(range)
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<co2History.count, id: \.self) { index in
                let value = co2History[index]
                let heightRatio = normalizedHeight(for: value)
                
                GeometryReader { geometry in
                    let maxHeight = geometry.size.height
                    let barHeight = maxHeight * heightRatio
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Colored bar representing the actual value
                        RoundedRectangle(cornerRadius: 1)
                            .fill(co2Color(for: value))
                            .frame(height: barHeight)
                    }
                    .background(
                        // Grey background representing the full scale
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.gray.opacity(0.3))
                    )
                }
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.1))
        )
    }
}


struct LiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 16) {
                // Top section with CO2 value and status
                HStack(spacing: 16) {
                    // CO2 Value Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AIRSPOT")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("\(context.state.co2Value)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(co2Color(for: context.state.co2Value, green: context.state.greenUpperLimit, yellow: context.state.yellowUpperLimit))
                            Text("CO₂ ppm")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -2)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Section
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 12) {
                                                    // Battery
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .foregroundColor(batteryColor(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .font(.system(size: 14, weight: .medium))
                            Text(batteryText(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                            
                            // Power Mode
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14, weight: .medium))
                                Text(context.state.powerMode)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Alarm & Vibration Status
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: context.state.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                    .foregroundColor(context.state.alarmEnabled ? .blue : .gray)
                                    .font(.system(size: 12, weight: .medium))
                                Text("Alarm")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: context.state.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                    .foregroundColor(context.state.vibrationEnabled ? .blue : .gray)
                                    .font(.system(size: 12, weight: .medium))
                                Text("Vibration")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                // Graph Section
                if !context.state.co2History.isEmpty {
                    Co2GraphView(
                        co2History: context.state.co2History,
                        greenUpperLimit: context.state.greenUpperLimit,
                        yellowUpperLimit: context.state.yellowUpperLimit,
                        graphMaxValue: context.state.graphMaxValue,
                        graphMinValue: context.state.graphMinValue
                    )
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
                        Text("AIRSPOT")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack(alignment: .bottom, spacing: 2) {
                            Text("\(context.state.co2Value)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(co2Color(for: context.state.co2Value, green: context.state.greenUpperLimit, yellow: context.state.yellowUpperLimit))
                            Text("CO₂ ppm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -2)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .foregroundColor(batteryColor(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .font(.system(size: 14, weight: .medium))
                            Text(batteryText(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                                .font(.system(size: 12, weight: .medium))
                            Text(context.state.powerMode)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: context.state.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                .foregroundColor(context.state.alarmEnabled ? .blue : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Alarm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: context.state.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                .foregroundColor(context.state.vibrationEnabled ? .blue : .gray)
                                .font(.system(size: 12, weight: .medium))
                            Text("Vibration")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Updated \(context.state.lastUpdated.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text("AS")
                        .foregroundColor(co2Color(for: context.state.co2Value, green: context.state.greenUpperLimit, yellow: context.state.yellowUpperLimit))
                        .font(.system(size: 10, weight: .bold))
                    Text("\(context.state.co2Value)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(co2Color(for: context.state.co2Value, green: context.state.greenUpperLimit, yellow: context.state.yellowUpperLimit))
                }
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                        .foregroundColor(batteryColor(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                        .font(.system(size: 12, weight: .medium))
                    Text(batteryText(for: context.state.batteryLevel, isCharging: context.state.isCharging))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
            } minimal: {
                Text("AS")
                    .foregroundColor(co2Color(for: context.state.co2Value, green: context.state.greenUpperLimit, yellow: context.state.yellowUpperLimit))
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }
    
    // Helper functions for dynamic colors and icons
    private func co2Color(for value: Int, green: Int, yellow: Int) -> Color {
        if value <= green {
            return .green
        } else if value <= yellow {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func batteryColor(for level: Int, isCharging: Bool) -> Color {
        if isCharging {
            return .green // Always green when charging
        }
        
        switch level {
        case 0...20:
            return .red
        case 21...50:
            return .orange
        default:
            return .green
        }
    }
    
    private func batteryIcon(for level: Int, isCharging: Bool) -> String {
        if isCharging {
            // Use charging icons
            switch level {
            case 0...10:
                return "battery.0percent.bolt"
            case 11...25:
                return "battery.25percent.bolt"
            case 26...50:
                return "battery.50percent.bolt"
            case 51...75:
                return "battery.75percent.bolt"
            default:
                return "battery.100percent.bolt"
            }
        } else {
            // Use regular battery icons
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
    
    private func batteryText(for level: Int, isCharging: Bool) -> String {
        if isCharging {
            return "CHG"
        } else {
            return "\(level)%"
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
        LiveActivityWidgetAttributes.ContentState(co2Value: 450, powerMode: "3 Min", batteryLevel: 85, isCharging: false, alarmEnabled: true, vibrationEnabled: true, co2History: [400, 420, 450, 480, 500], greenUpperLimit: 400, yellowUpperLimit: 800, graphMaxValue: 1600, graphMinValue: 0, lastUpdated: Date())
     }
     
     fileprivate static var lowBatteryData: LiveActivityWidgetAttributes.ContentState {
         LiveActivityWidgetAttributes.ContentState(co2Value: 1200, powerMode: "1 Min", batteryLevel: 25, isCharging: true, alarmEnabled: false, vibrationEnabled: true, co2History: [1000, 1100, 1200, 1250, 1300], greenUpperLimit: 1000, yellowUpperLimit: 1100, graphMaxValue: 1600, graphMinValue: 0, lastUpdated: Date())
     }
}

//#Preview("Notification", as: .content, using: LiveActivityWidgetAttributes.preview) {
//   LiveActivityWidgetLiveActivity()
//} contentStates: {
//    LiveActivityWidgetAttributes.ContentState.sampleData
//    LiveActivityWidgetAttributes.ContentState.lowBatteryData
//}
