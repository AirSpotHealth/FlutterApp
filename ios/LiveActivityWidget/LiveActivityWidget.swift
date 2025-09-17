//
//  LiveActivityWidget.swift
//  LiveActivityWidget
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import WidgetKit
import SwiftUI
import Charts

// MARK: - Widget Data Provider
struct Co2WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> Co2WidgetEntry {
        Co2WidgetEntry(
            date: Date(),
            deviceId: "1234567890",
            deviceName: "AirSpot Device",
            co2Value: 450,
            powerMode: "3 Min",
            batteryLevel: 85,
            isCharging: false,
            alarmEnabled: true,
            vibrationEnabled: true,
            co2History: [400, 420, 450, 480, 470, 460, 450],
            greenUpperLimit: 800,
            yellowUpperLimit: 1000,
            isConnected: true,
            isRefreshing: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (Co2WidgetEntry) -> ()) {
        // Try to get data from UserDefaults shared with the main app
        let entry = getWidgetData() ?? placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        
        let entry = getWidgetData() ?? placeholder(in: context)
        
        // Update every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getWidgetData() -> Co2WidgetEntry? {
        // Get data from shared UserDefaults (App Group)
        guard let userDefaults = UserDefaults(suiteName: "group.com.airspot.lohas") else {
            print("❌ Widget: Failed to access App Group UserDefaults")
            return nil
        }
        
        guard let widgetDataJson = userDefaults.string(forKey: "widget_data_json") else {
            print("❌ Widget: No data found for key 'widget_data_json'")
            // List all keys to see what's available
            let allKeys = Array(userDefaults.dictionaryRepresentation().keys)
            print("📋 Widget: Available keys in UserDefaults: \(allKeys)")
            return nil
        }
        
        print("✅ Widget: Found data - \(widgetDataJson.prefix(100))...")
        
        guard let data = widgetDataJson.data(using: .utf8) else {
            print("❌ Widget: Failed to convert JSON string to data")
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("✅ Widget: Successfully parsed JSON with co2Value: \(json?["co2Value"] ?? "nil")")
            return parseWidgetData(from: json)
        } catch {
            print("❌ Widget: Error parsing widget data: \(error)")
            return nil
        }
    }
    
    private func parseWidgetData(from json: [String: Any]?) -> Co2WidgetEntry? {
        guard let json = json else { return nil }
        
        let co2HistoryArray = json["co2History"] as? [Int] ?? []
        let deviceId = json["deviceId"] as? String ?? ""
        let isConnected = json["isConnected"] as? Bool ?? false
        
        // Check if we have a valid device connection
        let hasValidDevice = !deviceId.isEmpty && isConnected
        
        return Co2WidgetEntry(
            date: Date(),
            deviceId: deviceId,
            deviceName: hasValidDevice ? (json["deviceName"] as? String ?? "AirSpot Device") : "",
            co2Value: hasValidDevice ? (json["co2Value"] as? Int ?? 0) : 0,
            powerMode: hasValidDevice ? (json["powerMode"] as? String ?? "Now") : "",
            batteryLevel: hasValidDevice ? (json["batteryLevel"] as? Int ?? 0) : 0,
            isCharging: hasValidDevice ? (json["isCharging"] as? Bool ?? false) : false,
            alarmEnabled: hasValidDevice ? (json["alarmEnabled"] as? Bool ?? false) : false,
            vibrationEnabled: hasValidDevice ? (json["vibrationEnabled"] as? Bool ?? false) : false,
            co2History: hasValidDevice ? co2HistoryArray : [],
            greenUpperLimit: json["greenUpperLimit"] as? Int ?? 800,
            yellowUpperLimit: json["yellowUpperLimit"] as? Int ?? 1000,
            isConnected: isConnected,
            isRefreshing: hasValidDevice ? (json["isRefreshing"] as? Bool ?? false) : false
        )
    }
}

// MARK: - Widget Entry
struct Co2WidgetEntry: TimelineEntry {
    let date: Date
    let deviceId: String
    let deviceName: String
    let co2Value: Int
    let powerMode: String
    let batteryLevel: Int
    let isCharging: Bool
    let alarmEnabled: Bool
    let vibrationEnabled: Bool
    let co2History: [Int]
    let greenUpperLimit: Int
    let yellowUpperLimit: Int
    let isConnected: Bool
    let isRefreshing: Bool
}

// MARK: - Widget Views

// 2x2 Small Widget View
struct SmallWidgetView: View {
    var entry: Co2WidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 2) {
            if entry.deviceId.isEmpty || !entry.isConnected {
                // No device connected state
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "bluetooth.slash")
                        .foregroundColor(.gray)
                        .font(.system(size: 24, weight: .medium))
                    Text("No Device\nConnected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                Spacer()
            } else {
                // Normal device connected state
                // Top: Status icons only (no logo, no button)
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        // Bluetooth connection status
                        Image(systemName: "bluetooth")
                            .foregroundColor(entry.isConnected ? .blue : .gray)
                            .font(.system(size: 10, weight: .medium))
                        Image(systemName: batteryIcon(for: entry.batteryLevel, isCharging: entry.isCharging))
                            .foregroundColor(entry.isConnected ? batteryColor(for: entry.batteryLevel, isCharging: entry.isCharging) : .gray)
                            .font(.system(size: 8))
                        Image(systemName: entry.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(entry.isConnected ? (entry.alarmEnabled ? .blue : .gray) : .gray)
                            .font(.system(size: 8))
                        Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .foregroundColor(entry.isConnected ? (entry.vibrationEnabled ? .blue : .gray) : .gray)
                            .font(.system(size: 8))
                    }
                }
                
                Spacer()
                
                // CO2 Value (vertically centered)
                VStack(spacing: -2) {
                    Text(entry.co2Value > 0 ? "\(entry.co2Value)" : "----")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(co2Color(for: entry.co2Value))
                        .minimumScaleFactor(0.7)
                    Text("CO₂ ppm")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Device name below CO2 value
                if !entry.deviceName.isEmpty {
                    Text(entry.deviceName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
        .widgetURL(URL(string: "airspothealth://devices"))
    }
}

// 2x4 Medium Widget View (Like Live Activity)
struct MediumWidgetView: View {
    var entry: Co2WidgetProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            if entry.deviceId.isEmpty || !entry.isConnected {
                // No device connected state
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "bluetooth.slash")
                        .foregroundColor(.gray)
                        .font(.system(size: 28, weight: .medium))
                    Text("No Device Connected")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                // Top section with map, CO2, button, status, graph (matches Live Activity)
                ZStack {
                // Center refresh button (matches Live Activity style)
                ZStack {
                    if entry.isRefreshing && entry.isConnected {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                            .frame(width: 32, height: 32)
                    } else if entry.isConnected {
                        ZStack {
                            Circle()
                                .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                                .fill(.secondary.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .shadow(color: .secondary.opacity(0.2), radius: 1, x: 0, y: 0)
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                        }
                    } else {
                        Circle()
                            .fill(.gray.opacity(0.5))
                            .frame(width: 32, height: 32)
                    }
                }
                
                // Full width layout
                HStack {
                    // Left: Map + CO2
                    HStack(spacing: 6) {
                        // Map icon with navigation
                        Link(destination: URL(string: "airspothealth://map-handoff?deviceId=\(entry.deviceId)")!) {
                            Image("ic_map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text(entry.co2Value > 0 ? "\(entry.co2Value)" : "----")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(co2Color(for: entry.co2Value))
                            Text("CO₂ ppm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -4)
                        }
                        .padding(.leading, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right: Status + Graph
                    HStack(spacing: 6) {
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Image(systemName: batteryIcon(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .foregroundColor(batteryColor(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .font(.system(size: 10))
                                    Text(batteryText(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                Image(systemName: entry.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                    .foregroundColor(entry.alarmEnabled ? .blue : .gray)
                                    .font(.system(size: 10))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 4)
                            
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Image(systemName: "timer")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 10))
                                    Text(entry.powerMode)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                    .foregroundColor(entry.vibrationEnabled ? .blue : .gray)
                                    .font(.system(size: 10))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding()
                        
                        // Graph icon with navigation
                        Link(destination: URL(string: "airspothealth://devices/\(entry.deviceId)/graph")!) {
                            Image("ic_graph2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
                // Device name
                if !entry.deviceName.isEmpty {
                    Text(entry.deviceName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, -4)
                        .padding(.bottom, -4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
        .widgetURL(URL(string: "airspothealth://devices"))
    }
}

// 4x4 Large Widget View (Extended with Graph)
struct LargeWidgetView: View {
    var entry: Co2WidgetProvider.Entry

    var body: some View {
        VStack(spacing: 12) {
            if entry.deviceId.isEmpty || !entry.isConnected {
                // No device connected state
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bluetooth.slash")
                        .foregroundColor(.gray)
                        .font(.system(size: 36, weight: .medium))
                    Text("No Device Connected")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                // Top section with map, CO2, button, status, graph (matches Live Activity)
                ZStack {
                // Center refresh button (matches Live Activity style)
                ZStack {
                    if entry.isRefreshing && entry.isConnected {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.0)
                            .frame(width: 36, height: 36)
                    } else if entry.isConnected {
                        ZStack {
                            Circle()
                                .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                                .fill(.secondary.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .shadow(color: .secondary.opacity(0.2), radius: 1, x: 0, y: 0)
                            Circle()
                                .fill(.white)
                                .frame(width: 7, height: 7)
                        }
                    } else {
                        Circle()
                            .fill(.gray.opacity(0.5))
                            .frame(width: 36, height: 36)
                    }
                }
                
                // Full width layout
                HStack {
                    // Left: Map + CO2
                    HStack(spacing: 6) {
                        // Map icon with navigation
                        Link(destination: URL(string: "airspothealth://map-handoff?deviceId=\(entry.deviceId)")!) {
                            Image("ic_map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .center, spacing: 2) {
                            Text(entry.co2Value > 0 ? "\(entry.co2Value)" : "----")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(co2Color(for: entry.co2Value))
                            Text("CO₂ ppm")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -4)
                        }
                        .padding(.leading, 12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right: Status + Graph
                    HStack(spacing: 6) {
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Image(systemName: batteryIcon(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .foregroundColor(batteryColor(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .font(.system(size: 12))
                                    Text(batteryText(for: entry.batteryLevel, isCharging: entry.isCharging))
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                Image(systemName: entry.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                                    .foregroundColor(entry.alarmEnabled ? .blue : .gray)
                                    .font(.system(size: 12))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 4)
                            
                            HStack(spacing: 6) {
                                HStack(spacing: 2) {
                                    Image(systemName: "timer")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 12))
                                    Text(entry.powerMode)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                                    .foregroundColor(entry.vibrationEnabled ? .blue : .gray)
                                    .font(.system(size: 12))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding()
                        
                        // Graph icon with navigation
                        Link(destination: URL(string: "airspothealth://devices/\(entry.deviceId)/graph")!) {
                            Image("ic_graph2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            
                // Device name
                if !entry.deviceName.isEmpty {
                    Text(entry.deviceName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, -4)
                        .padding(.bottom, -4)
                }
                
                // CO2 History Graph
                if !entry.co2History.isEmpty {
                    Co2GraphView(
                        co2History: entry.co2History,
                        greenUpperLimit: entry.greenUpperLimit,
                        yellowUpperLimit: entry.yellowUpperLimit,
                        graphMaxValue: entry.co2History.max() ?? 1600,
                        graphMinValue: entry.co2History.min() ?? 400
                    )
                    .frame(height: 80)
                } else {
                    Text("No data available")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(height: 80)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
        )
        .widgetURL(URL(string: "airspothealth://devices"))
    }
}

// MARK: - Main Widget Entry View
struct Co2WidgetEntryView : View {
    var entry: Co2WidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Main Widget Configuration
struct Co2Widget: Widget {
    let kind: String = "Co2Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Co2WidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                Co2WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Co2WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("AirSpot CO₂ Monitor")
        .description("Monitor your CO₂ levels and device status")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Helper Functions
private func co2Color(for value: Int) -> Color {
    if value == 0 { return .white }
    if value <= 800 { return .green }
    if value <= 1000 { return .yellow }
    return .red
}

private func batteryIcon(for level: Int, isCharging: Bool) -> String {
    if isCharging { return "battery.100.bolt" }
    if level > 75 { return "battery.100" }
    if level > 50 { return "battery.75" }
    if level > 25 { return "battery.50" }
    if level > 10 { return "battery.25" }
    return "battery.0"
}

private func batteryColor(for level: Int, isCharging: Bool) -> Color {
    if isCharging { return .green }
    if level > 25 { return .white }
    if level > 10 { return .yellow }
    return .red
}

private func batteryText(for level: Int, isCharging: Bool) -> String {
    if isCharging { return "⚡" }
    return "\(level)%"
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    Co2Widget()
} timeline: {
    Co2WidgetEntry(
        date: .now,
        deviceId: "test123",
        deviceName: "Living Room",
        co2Value: 450,
        powerMode: "3 Min",
        batteryLevel: 85,
        isCharging: false,
        alarmEnabled: true,
        vibrationEnabled: true,
        co2History: [400, 420, 450, 480, 470],
        greenUpperLimit: 800,
        yellowUpperLimit: 1000,
        isConnected: true,
        isRefreshing: false
    )
}

#Preview(as: .systemMedium) {
    Co2Widget()
} timeline: {
    Co2WidgetEntry(
        date: .now,
        deviceId: "test123",
        deviceName: "Living Room",
        co2Value: 450,
        powerMode: "3 Min",
        batteryLevel: 85,
        isCharging: false,
        alarmEnabled: true,
        vibrationEnabled: true,
        co2History: [400, 420, 450, 480, 470],
        greenUpperLimit: 800,
        yellowUpperLimit: 1000,
        isConnected: true,
        isRefreshing: false
    )
}

#Preview(as: .systemLarge) {
    Co2Widget()
} timeline: {
    Co2WidgetEntry(
        date: .now,
        deviceId: "test123",
        deviceName: "Living Room",
        co2Value: 450,
        powerMode: "3 Min",
        batteryLevel: 85,
        isCharging: false,
        alarmEnabled: true,
        vibrationEnabled: true,
        co2History: [400, 420, 450, 480, 470, 460, 450, 440, 430, 450],
        greenUpperLimit: 800,
        yellowUpperLimit: 1000,
        isConnected: true,
        isRefreshing: false
    )
}