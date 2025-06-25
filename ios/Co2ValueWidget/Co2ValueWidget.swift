//
//  Co2ValueWidget.swift
//  Co2ValueWidget
//
//  Created by Niraj Bhatt on 25/06/2025.
//
import WidgetKit
import SwiftUI
import AppIntents

// The data model for a single timeline entry
struct Provider: TimelineProvider {
    // Provides a default view for the widget gallery
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), co2Value: "0426", powerMode: "3 min", batteryLevel: "100", isCharging: false, alarmEnabled: true, vibrationEnabled: false)
    }

    // Provides the view for a transient state, e.g., in the widget gallery
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), co2Value: "0426", powerMode: "3 min", batteryLevel: "100", isCharging: false, alarmEnabled: true, vibrationEnabled: false)
        completion(entry)
    }

    // Provides the timeline (a sequence of entries) for the widget
    func getTimeline(in context:Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Access the shared data
        let userDefaults = UserDefaults(suiteName: "group.com.airspot.lohas")
        
        let co2Value = userDefaults?.string(forKey: "airspot_home_widget") ?? "----"
        let powerMode = userDefaults?.string(forKey: "power_mode") ?? "Now"
        let batteryLevel = userDefaults?.string(forKey: "battery_level") ?? "0"
        let isChargingString = userDefaults?.string(forKey: "is_charging") ?? "false"
        let alarmEnabledString = userDefaults?.string(forKey: "alarm_enabled") ?? "false"
        let vibrationEnabledString = userDefaults?.string(forKey: "vibration_enabled") ?? "false"
        
        let isCharging = isChargingString == "true"
        let alarmEnabled = alarmEnabledString == "true"
        let vibrationEnabled = vibrationEnabledString == "true"
        
        let entry = SimpleEntry(
            date: Date(),
            co2Value: co2Value,
            powerMode: powerMode,
            batteryLevel: batteryLevel,
            isCharging: isCharging,
            alarmEnabled: alarmEnabled,
            vibrationEnabled: vibrationEnabled
        )

        // Create a timeline that refreshes every 15 minutes.
        // The refresh button provides a manual override.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// The data structure for a widget entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let co2Value: String
    let powerMode: String
    let batteryLevel: String
    let isCharging: Bool
    let alarmEnabled: Bool
    let vibrationEnabled: Bool
}

// The AppIntent to refresh the widget timeline (requires iOS 17+)
struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"

    func perform() async throws -> some IntentResult {
        // Reload the timeline of our widget
        WidgetCenter.shared.reloadTimelines(ofKind: "Co2ValueWidget")
        return .result()
    }
}

// The SwiftUI view that displays the widget content
struct Co2ValueWidgetEntryView : View {
    var entry: Provider.Entry

    // Function to determine CO2 color
    private func co2Color() -> Color {
        if let value = Int(entry.co2Value) {
            if value < 800 {
                return Color(red: 76/255, green: 175/255, blue: 80/255) // Green #4CAF50
            } else if value < 1000 {
                return Color(red: 255/255, green: 152/255, blue: 0/255) // Orange #FF9800
            } else {
                return Color(red: 244/255, green: 67/255, blue: 54/255) // Red #F44336
            }
        }
        return Color(red: 76/255, green: 175/255, blue: 80/255) // Default Green
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header: AIRSPOT
            HStack(spacing: 0) {
                Text("AIR")
                    .font(.system(size: 18, weight: .bold))
                Text("SPOT")
                    .font(.system(size: 18))
            }
            .foregroundColor(.white)
            
            // Main Content Box
            VStack(spacing: 4) {
                // Top row: Icons and Battery
                HStack {
                    // Sound Icon
                    Image(systemName: entry.alarmEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)
                    
                    // Vibration Icon (Using an SF Symbol placeholder)
                    Image(systemName: entry.vibrationEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)

                    Spacer()
                    
                    // Battery Percentage rectangle
                    Text("\(entry.batteryLevel)%")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                
                // CO2 Value
                Text(entry.co2Value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(co2Color())

                // Bottom row: Time and Unit
                HStack(spacing: 12) {
                    Text(entry.powerMode)
                    Text("CO₂ppm")
                }
                .font(.system(size: 12))
                .foregroundColor(.white)
                .opacity(0.8)
            }
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.15))
            .cornerRadius(8)
            
            // Refresh Button
            Button(intent: RefreshWidgetIntent()) {
                // a 4 x 4 circle dot with white background
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 36, height: 36)
            .background(Circle()
                .fill(Color.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1))
            .clipShape(Circle())
            .buttonStyle(.plain)
            .padding(.top, 4)
            
        }
        .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        .containerBackground(for: .widget) {
            // This is the background of the entire widget
            Color(red: 30/255, green: 30/255, blue: 30/255) // Dark background
        }
    }
}

// The main widget definition
struct Co2ValueWidget: Widget {
    let kind: String = "Co2ValueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Co2ValueWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AirSpot CO2 Monitor")
        .description("Displays the latest CO2 reading from your AirSpot device.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

// A preview for use within Xcode
#Preview(as: .systemSmall) {
    Co2ValueWidget()
} timeline: {
    SimpleEntry(date: .now, co2Value: "426", powerMode: "3 min", batteryLevel: "100", isCharging: false, alarmEnabled: true, vibrationEnabled: false)
    SimpleEntry(date: .now, co2Value: "950", powerMode: "Now", batteryLevel: "75", isCharging: false, alarmEnabled: true, vibrationEnabled: true)
    SimpleEntry(date: .now, co2Value: "1550", powerMode: "1 min", batteryLevel: "20", isCharging: true, alarmEnabled: false, vibrationEnabled: false)
    SimpleEntry(date: .now, co2Value: "900", powerMode: "5 sec", batteryLevel: "45", isCharging: false, alarmEnabled: true, vibrationEnabled: true)
}
