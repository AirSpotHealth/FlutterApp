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
            isRefreshing: false,
            greenZonePercentage: 75,
            yellowZonePercentage: 20,
            redZonePercentage: 5,
            dominantZone: "green",
            dominantZonePercentage: 75
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
            isRefreshing: hasValidDevice ? (json["isRefreshing"] as? Bool ?? false) : false,
            greenZonePercentage: hasValidDevice ? (json["greenZonePercentage"] as? Int ?? 0) : 0,
            yellowZonePercentage: hasValidDevice ? (json["yellowZonePercentage"] as? Int ?? 0) : 0,
            redZonePercentage: hasValidDevice ? (json["redZonePercentage"] as? Int ?? 0) : 0,
            dominantZone: hasValidDevice ? (json["dominantZone"] as? String ?? "none") : "none",
            dominantZonePercentage: hasValidDevice ? (json["dominantZonePercentage"] as? Int ?? 0) : 0
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
    let greenZonePercentage: Int
    let yellowZonePercentage: Int
    let redZonePercentage: Int
    let dominantZone: String
    let dominantZonePercentage: Int
}

// MARK: - Reusable Components

// Pie chart component for zone visualization
struct ZonePieChart: View {
    let greenPercentage: Int
    let yellowPercentage: Int
    let redPercentage: Int
    let size: CGFloat
    
    private var radius: CGFloat {
        size / 2
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: size, height: size)
            
            // Pie slices
            PieChartSlice(
                startAngle: .degrees(0),
                endAngle: .degrees(Double(greenPercentage) * 3.6),
                color: .green,
                radius: radius
            )
            
            PieChartSlice(
                startAngle: .degrees(Double(greenPercentage) * 3.6),
                endAngle: .degrees(Double(greenPercentage + yellowPercentage) * 3.6),
                color: .yellow,
                radius: radius
            )
            
            PieChartSlice(
                startAngle: .degrees(Double(greenPercentage + yellowPercentage) * 3.6),
                endAngle: .degrees(360),
                color: .red,
                radius: radius
            )
        }
        .frame(width: size, height: size)
    }
}

// Individual pie slice
struct PieChartSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let radius: CGFloat
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: radius, y: radius)
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.closeSubpath()
        }
        .fill(color)
    }
}

// Reusable widget content view
struct WidgetContentView: View {
    let entry: Co2WidgetProvider.Entry
    let fontSize: CGFloat
    let co2FontSize: CGFloat
    let iconSize: CGFloat
    let textSize: CGFloat
    
    var body: some View {
        HStack {
            // Left: Device name and Time stacked
            VStack(alignment: .center, spacing: 2) {
                if !entry.deviceName.isEmpty {
                    Text(entry.deviceName)
                        .font(.system(size: fontSize, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                Text("at \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: fontSize - 2, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Center: CO2 value
            VStack(spacing: 2) {
                Text(entry.co2Value > 0 ? "\(entry.co2Value)" : "----")
                    .font(.system(size: co2FontSize, weight: .bold))
                    .foregroundColor(co2Color(for: entry.co2Value))
                Text("CO₂ ppm")
                    .font(.system(size: textSize, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Right: 2x2 grid of icons
            VStack(spacing: 2) {
                // Row 1: Battery+% and Alarm icon
                HStack(spacing: 8) {
                    // Col 1: Battery and percentage
                    HStack(spacing: 2) {
                        Image(systemName: batteryIcon(for: entry.batteryLevel, isCharging: entry.isCharging))
                            .foregroundColor(batteryColor(for: entry.batteryLevel, isCharging: entry.isCharging))
                            .font(.system(size: iconSize))
                        Text(batteryText(for: entry.batteryLevel, isCharging: entry.isCharging))
                            .font(.system(size: textSize, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    // Col 2: Alarm icon
                    Image(systemName: entry.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                        .foregroundColor(entry.alarmEnabled ? .blue : .gray)
                        .font(.system(size: iconSize))
                }
                
                // Row 2: Timer+mode and Vibration icon
                HStack(spacing: 8) {
                    // Col 1: Timer and mode
                    HStack(spacing: 2) {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                            .font(.system(size: iconSize))
                        Text(entry.powerMode)
                            .font(.system(size: textSize, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    
                    // Col 2: Vibration icon
                    Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                        .foregroundColor(entry.vibrationEnabled ? .blue : .gray)
                        .font(.system(size: iconSize))
                }
            }
        }
    }
}

// MARK: - Widget Views

// 2x2 Small Widget View
struct SmallWidgetView: View {
    var entry: Co2WidgetProvider.Entry
    @Environment(\.widgetContentMargins) var margins
    
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
                    HStack(spacing: 6) {
                        // Bluetooth connection status
                        Image(systemName: "bluetooth")
                            .foregroundColor(entry.isConnected ? .blue : .gray)
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: batteryIcon(for: entry.batteryLevel, isCharging: entry.isCharging))
                            .foregroundColor(entry.isConnected ? batteryColor(for: entry.batteryLevel, isCharging: entry.isCharging) : .gray)
                            .font(.system(size: 10))
                        Image(systemName: entry.alarmEnabled ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(entry.isConnected ? (entry.alarmEnabled ? .blue : .gray) : .gray)
                            .font(.system(size: 10))
                        Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                            .foregroundColor(entry.isConnected ? (entry.vibrationEnabled ? .blue : .gray) : .gray)
                            .font(.system(size: 10))
                    }
                }
                
                Spacer()
                
                // CO2 Value (vertically centered)
                VStack(spacing: -2) {
                    Text(entry.co2Value > 0 ? "\(entry.co2Value)" : "----")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(co2Color(for: entry.co2Value))
                        .minimumScaleFactor(0.7)
                    Text("CO₂ ppm")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Device name below CO2 value
                if !entry.deviceName.isEmpty {
                    Text(entry.deviceName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                
                // Last updated time at bottom
                Text("at \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Spacer()
            }
        }
        .padding(4)
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
    @Environment(\.widgetContentMargins) var margins

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
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                // Reusable widget content
                WidgetContentView(
                    entry: entry,
                    fontSize: 11,
                    co2FontSize: 24,
                    iconSize: 10,
                    textSize: 10
                )
                .padding(.bottom, 8)
                
                // CO2 History Graph
                if !entry.co2History.isEmpty {
                    Co2GraphView(
                        co2History: entry.co2History,
                        greenUpperLimit: entry.greenUpperLimit,
                        yellowUpperLimit: entry.yellowUpperLimit,
                        graphMaxValue: entry.co2History.max() ?? 1600,
                        graphMinValue: entry.co2History.min() ?? 400
                    )
                    .frame(height: 70)
                } else {
                    Text("No data available")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .frame(height: 70)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
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
    @Environment(\.widgetContentMargins) var margins

    var body: some View {
        VStack(spacing: 10) {
            if entry.deviceId.isEmpty || !entry.isConnected {
                // No device connected state
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bluetooth.slash")
                        .foregroundColor(.gray)
                        .font(.system(size: 36, weight: .medium))
                    Text("No Device Connected")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                // Reusable widget content
                WidgetContentView(
                    entry: entry,
                    fontSize: 13,
                    co2FontSize: 28,
                    iconSize: 12,
                    textSize: 12
                )
                .padding(.bottom, 8)
                
                // CO2 History Graph
                if !entry.co2History.isEmpty {
                    Co2GraphView(
                        co2History: entry.co2History,
                        greenUpperLimit: entry.greenUpperLimit,
                        yellowUpperLimit: entry.yellowUpperLimit,
                        graphMaxValue: entry.co2History.max() ?? 1600,
                        graphMinValue: entry.co2History.min() ?? 400
                    )
                    .frame(height: 76)
                } else {
                    Text("No data available")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(height: 76)
                }
                
                // Zone Analysis - Two equal halves
                HStack(spacing: 0) {
                    // Left half - Pie Chart (centered)
                    HStack {
                        Spacer()
                        ZonePieChart(
                            greenPercentage: entry.greenZonePercentage,
                            yellowPercentage: entry.yellowZonePercentage,
                            redPercentage: entry.redZonePercentage,
                            size: 100
                        )
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right half - Text (centered)
                    HStack {
                        Spacer()
                        Text("\(entry.dominantZonePercentage)% \(entry.dominantZone) zone air environment today")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }.padding(.top, 12)
            }
        }
        .padding(6)
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
                    .containerBackground(Color.black, for: .widget)
                    .padding(.all, 12)
            } else {
                Co2WidgetEntryView(entry: entry)
                    .padding(.all, 12)
                    .background(Color.black)
            }
        }
        .configurationDisplayName("AirSpot CO₂ Monitor")
        .description("Monitor your CO₂ levels and device status")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
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
        isRefreshing: false,
        greenZonePercentage: 75,
        yellowZonePercentage: 20,
        redZonePercentage: 5,
        dominantZone: "green",
        dominantZonePercentage: 75
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
        isRefreshing: false,
        greenZonePercentage: 75,
        yellowZonePercentage: 20,
        redZonePercentage: 5,
        dominantZone: "green",
        dominantZonePercentage: 75
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
        isRefreshing: false,
        greenZonePercentage: 75,
        yellowZonePercentage: 20,
        redZonePercentage: 5,
        dominantZone: "green",
        dominantZonePercentage: 75
    )
}
