//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by Niraj Bhatt on 06/07/2025.
//

import ActivityKit
import Charts
import SwiftUI
import WidgetKit

// AppIntents is only available in iOS 16.0+
#if canImport(AppIntents)
import AppIntents
#endif

// LiveActivityIntent for Live Activity buttons (iOS 17+ only)
#if canImport(AppIntents)
@available(iOS 17.0, *)
struct RefreshDataIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Refresh CO2 Data"
    static var description = IntentDescription(
        "Refreshes the current CO2 reading from the device"
    )

    func perform() async throws -> some IntentResult {
        print("Live Activity refresh via LiveActivityIntent (iOS 17+)")
        // Send notification to main app to refresh data
        NotificationCenter.default.post(
            name: Notification.Name("RefreshDataRequested"),
            object: nil
        )
        return .result()
    }
}

@available(iOS 17.0, *)
struct RestartLiveActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Restart Live Activity"
    static var description = IntentDescription("Restarts the live activity to extend its duration")
    
    @Parameter(title: "Device ID")
    var deviceId: String
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    init() {
        self.deviceId = ""
    }

    func perform() async throws -> some IntentResult {
        print("Live Activity restart requested via LiveActivityIntent (iOS 17+) for device: \(deviceId)")
        
        // Post notification (for when app/extension is active); opening the app is handled via widgetURL
        NotificationCenter.default.post(
            name: Notification.Name("RestartLiveActivityRequested"),
            object: nil,
            userInfo: ["deviceId": deviceId]
        )
        
        return .result()
    }
}


#endif

struct LiveActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Device ID
        var deviceId: String
        // Device Name/Alias
        var deviceName: String
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
        // Refresh State
        var isRefreshing: Bool
        // Connection State
        var isConnected: Bool
        // Last Updated
        var lastUpdated: Date
        // Activity Started Time (to calculate remaining time)
        var activityStartTime: Date
        // Show stale warning (when approaching 8 hours)
        var showStaleWarning: Bool
    }
}

// CO2 Value component with blink animation
struct Co2ValueView: View {
    let co2Value: Int
    let greenUpperLimit: Int
    let yellowUpperLimit: Int
    let isRefreshing: Bool
    let isConnected: Bool
    let fontSize: CGFloat

    @State private var isAnimating: Bool = false

    private func co2Color(for value: Int) -> Color {
        // Show grey when disconnected, normal colors when connected
        if !isConnected {
            return .gray
        }
        
        if value <= greenUpperLimit {
            return .green
        } else if value <= yellowUpperLimit {
            return .orange
        } else {
            return .red
        }
    }

    var body: some View {
        Text("\(co2Value)")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundColor(co2Color(for: co2Value))
            .opacity(isRefreshing ? (isAnimating ? 0.3 : 1.0) : 1.0)
            .animation(
                isRefreshing
                    ? .easeInOut(duration: 0.5).repeatForever(
                        autoreverses: true
                    ) : .easeInOut(duration: 0.2),
                value: isAnimating
            )
            .onChange(of: isRefreshing) { refreshing in
                if refreshing {
                    startBlinkAnimation()
                } else {
                    stopBlinkAnimation()
                }
            }
            .onAppear {
                if isRefreshing {
                    startBlinkAnimation()
                }
            }
    }

    private func startBlinkAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
    }

    private func stopBlinkAnimation() {
        isAnimating = false
    }
}

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
        GeometryReader { geometry in
            let maxHeight = geometry.size.height
            let maxBars = 40  // Maximum number of bars to display
            let actualBars = min(maxBars, co2History.count)
            let emptyBars = max(0, maxBars - actualBars)
            
            // Calculate dynamic bar width based on available space
            let graphHorizontalPadding: CGFloat = 8  // 4 on each side for the graph
            let spacing: CGFloat = 2
            let availableWidth = geometry.size.width - graphHorizontalPadding
            let totalSpacing = spacing * CGFloat(maxBars - 1)
            let barWidth = (availableWidth - totalSpacing) / CGFloat(maxBars)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.1))
                
                // Centered graph content
                HStack(alignment: .bottom, spacing: spacing) {
                    // Add empty bars on the left to show full timeline
                    ForEach(0..<emptyBars, id: \.self) { _ in
                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.clear)
                                .frame(height: 0)
                        }
                        .frame(width: barWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: maxHeight - 8)
                        )
                    }
                    
                    // Display actual CO2 data on the right side
                    ForEach(0..<actualBars, id: \.self) { index in
                        let dataIndex = co2History.count - actualBars + index
                        let value = co2History[dataIndex]
                        let heightRatio = normalizedHeight(for: value)
                        let barHeight = (maxHeight - 8) * heightRatio

                        VStack {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: 1)
                                .fill(co2Color(for: value))
                                .frame(height: barHeight)
                        }
                        .frame(width: barWidth)
                        .background(
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: maxHeight - 8)
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
        .frame(height: 70)

    }
}

// Refresh button with configurable size and activity indicator (iOS 17+ only)
struct CompactRefreshButton: View {
    let size: CGFloat
    let isRefreshing: Bool
    let isConnected: Bool

    var body: some View {
        #if canImport(AppIntents)
        if #available(iOS 17.0, *) {
            ZStack {
                if isRefreshing && isConnected {
                    // Show activity indicator when refreshing and connected
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(size / 40) // Scale based on button size
                        .frame(width: size, height: size)
                } else if isConnected {
                    // Show refresh button when connected but not refreshing
                    Button(intent: RefreshDataIntent()) {
                        ZStack {
                            // Dark circular background - lighter shade for visibility
                            Circle()
                                .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                                .fill(.secondary.opacity(0.3))
                                .frame(width: size, height: size)
                                .shadow(
                                    color: .secondary.opacity(0.2),
                                    radius: 1,
                                    x: 0,
                                    y: 0
                                )

                            // Small white circle in center - scales with button size
                            Circle()
                                .fill(.white)
                                .frame(width: size * 0.2, height: size * 0.2)
                        }
                                         }
                     .buttonStyle(.plain)
                 } else {
                     Image("ic_bt_off")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: size, height: size)
                 }
             }
        } else {
            // No refresh button on iOS 16.x - LiveActivityIntent not available
            EmptyView()
        }
        #else
        // No refresh button - AppIntents not available
        EmptyView()
        #endif
    }
}

@available(iOS 16.2, *)
struct LiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            let shouldShow = shouldShowStaleWarning(state: context.state)
            Group {
                if shouldShow {
                    staleWarningBannerView(context: context)
                } else {
                    normalLiveActivityBannerView(context: context)
                }
            }
            .widgetURL(
                URL(
                    string: shouldShow
                        ? "airspothealth://devices/\(context.state.deviceId)?from=expired"
                        : "airspothealth://devices"
                )
            )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Updated logo text for Dynamic Island
                        HStack(spacing: 0) {
                            Text("AIR")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .semibold))
                            Text("SPOT")
                                .foregroundColor(.primary)
                                .font(.system(size: 16, weight: .light))
                        }
                        
                        // Device Name
                        if !context.state.deviceName.isEmpty {
                            Text(context.state.deviceName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        }

                        HStack(alignment: .bottom, spacing: 2) {
                            Co2ValueView(
                                co2Value: context.state.co2Value,
                                greenUpperLimit: context.state.greenUpperLimit,
                                yellowUpperLimit: context.state
                                    .yellowUpperLimit,
                                isRefreshing: context.state.isRefreshing,
                                isConnected: context.state.isConnected,
                                fontSize: 20
                            )
                            Text("CO₂ ppm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -2)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        CompactRefreshButton(
                            size: 24,
                            isRefreshing: context.state.isRefreshing,
                            isConnected: context.state.isConnected
                        )

                        HStack(spacing: 4) {
                            Image(
                                systemName: batteryIcon(
                                    for: context.state.batteryLevel,
                                    isCharging: context.state.isCharging
                                )
                            )
                            .foregroundColor(
                                batteryColor(
                                    for: context.state.batteryLevel,
                                    isCharging: context.state.isCharging
                                )
                            )
                            .font(.system(size: 14, weight: .medium))
                            Text(
                                batteryText(
                                    for: context.state.batteryLevel,
                                    isCharging: context.state.isCharging
                                )
                            )
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
                    if context.state.showStaleWarning {
                        // Show stale warning with restart button
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 12, weight: .medium))
                                Text("Live Activity expires soon")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            
                            // Auto-disable handles this, just show info message
                            Text("Will auto-disable - tap to open settings")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        // Normal status display
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(
                                    systemName: context.state.alarmEnabled
                                        ? "bell.fill" : "bell.slash.fill"
                                )
                                .foregroundColor(
                                    context.state.alarmEnabled ? .blue : .gray
                                )
                                .font(.system(size: 12, weight: .medium))
                                Text("Alarm")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            HStack(spacing: 6) {
                                Image(
                                    systemName: context.state.vibrationEnabled
                                        ? "iphone.radiowaves.left.and.right"
                                        : "iphone.slash"
                                )
                                .foregroundColor(
                                    context.state.vibrationEnabled ? .blue : .gray
                                )
                                .font(.system(size: 12, weight: .medium))
                                Text("Vibration")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            Text(
                                "Updated \(context.state.lastUpdated.formatted(date: .omitted, time: .shortened))"
                            )
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white)
                        }
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text("AS")
                        .foregroundColor(
                            co2Color(
                                for: context.state.co2Value,
                                green: context.state.greenUpperLimit,
                                yellow: context.state.yellowUpperLimit,
                                isConnected: context.state.isConnected
                            )
                        )
                        .font(.system(size: 10, weight: .bold))
                    Co2ValueView(
                        co2Value: context.state.co2Value,
                        greenUpperLimit: context.state.greenUpperLimit,
                        yellowUpperLimit: context.state.yellowUpperLimit,
                        isRefreshing: context.state.isRefreshing,
                        isConnected: context.state.isConnected,
                        fontSize: 12
                    )
                }
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(
                        systemName: batteryIcon(
                            for: context.state.batteryLevel,
                            isCharging: context.state.isCharging
                        )
                    )
                    .foregroundColor(
                        batteryColor(
                            for: context.state.batteryLevel,
                            isCharging: context.state.isCharging
                        )
                    )
                    .font(.system(size: 12, weight: .medium))
                    Text(
                        batteryText(
                            for: context.state.batteryLevel,
                            isCharging: context.state.isCharging
                        )
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                }
            } minimal: {
                Text("\(context.state.co2Value)")
                    .foregroundColor(
                        co2Color(
                            for: context.state.co2Value,
                            green: context.state.greenUpperLimit,
                            yellow: context.state.yellowUpperLimit,
                            isConnected: context.state.isConnected
                        )
                    )
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }

    // Compute stale warning based on start time and build mode
    private func shouldShowStaleWarning(state: LiveActivityWidgetAttributes.ContentState) -> Bool {
        let start = state.activityStartTime
        let elapsed = Date().timeIntervalSince(start)
        
        // DEBUG MODE: Use shorter times for testing
        // Production: 8 hours total, 10 minutes warning
        // Debug: 2 minutes total, 30 seconds warning
        #if DEBUG
        let total: TimeInterval = 2 * 60 // 2 minutes for testing
        let warn: TimeInterval = 30 // 30 seconds warning
        #else
        let total: TimeInterval = 8 * 60 * 60 // 8 hours
        let warn: TimeInterval = 10 * 60 // 10 minutes
        #endif
        
        let shouldShow = elapsed >= (total - warn) || state.showStaleWarning
        
        // If we should show stale warning, trigger auto-disable notification
        if shouldShow && !state.showStaleWarning {
            // Send notification to auto-disable the live activity setting
            // Use DispatchQueue.main to ensure it's on the main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("AutoDisableLiveActivity"),
                    object: nil,
                    userInfo: ["deviceId": state.deviceId]
                )
            }
        }
        
        return shouldShow
    }

    // MARK: - Helper functions for dynamic colors and icons

    private func co2Color(for value: Int, green: Int, yellow: Int, isConnected: Bool = true) -> Color {
        // Show grey when disconnected
        if !isConnected {
            return .gray
        }
        
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
            return .green  // Always green when charging
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
            return "battery.100percent.bolt"
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

    // MARK: - Helper Views for Live Activity Banner

    @available(iOS 16.2, *)
    @ViewBuilder
    private func staleWarningBannerView(context: ActivityViewContext<LiveActivityWidgetAttributes>) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.orange)

                Text("Live Activity expired")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if !context.state.deviceName.isEmpty {
                Text(context.state.deviceName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }

            Text("Live Activity will auto-disable. Tap to open settings and restart if needed.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    .black.opacity(0.8)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .activityBackgroundTint(Color.clear)
        .activitySystemActionForegroundColor(Color.primary)
    }

    @available(iOS 16.2, *)
    @ViewBuilder
    private func normalLiveActivityBannerView(context: ActivityViewContext<LiveActivityWidgetAttributes>) -> some View {
        VStack(spacing: 4) {
            // Top section with CO2 value and status
            ZStack {
                // Center refresh button – visually centered
                CompactRefreshButton(
                    size: context.state.isRefreshing ? 32 : 36,
                    isRefreshing: context.state.isRefreshing,
                    isConnected: context.state.isConnected
                )

                // Full width HStack to layout left and right sections
                HStack {
                    // Left Section (Map + CO2)
                    HStack(spacing: 6) {
                        Link(
                            destination: URL(
                                string: "airspothealth://map-handoff?deviceId=\(context.state.deviceId)"
                            )!
                        ) {
                            Image("ic_map")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)


                        VStack(alignment: .center, spacing: 2) {
                            Co2ValueView(
                                co2Value: context.state.co2Value,
                                greenUpperLimit: context.state
                                    .greenUpperLimit,
                                yellowUpperLimit: context.state
                                    .yellowUpperLimit,
                                isRefreshing: context.state.isRefreshing,
                                isConnected: context.state.isConnected,
                                fontSize: 24
                            )
                            Text("CO₂ ppm")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .offset(y: -4)
                        }
                        .padding(.leading, 28)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right Section (Status + Graph icon)
                    HStack(spacing: 6) {
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(alignment: .top, spacing: 6) {
                                HStack(spacing: 3) {
                                    Image(
                                        systemName: batteryIcon(
                                            for: context.state.batteryLevel,
                                            isCharging: context.state
                                                .isCharging
                                        )
                                    )
                                    .foregroundColor(
                                        batteryColor(
                                            for: context.state.batteryLevel,
                                            isCharging: context.state
                                                .isCharging
                                        )
                                    )
                                    .font(
                                        .system(size: 12, weight: .medium)
                                    )
                                    Text(
                                        batteryText(
                                            for: context.state.batteryLevel,
                                            isCharging: context.state
                                                .isCharging
                                        )
                                    )
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                }
                                 Image(
                                     systemName: context.state.alarmEnabled
                                         ? "bell.fill" : "bell.slash.fill"
                                 )
                                 .foregroundColor(
                                     context.state.alarmEnabled
                                         ? .blue : .gray
                                 )
                                 .font(.system(size: 12, weight: .medium))
                             }
                             .frame(
                                 maxWidth: .infinity,
                                 alignment: .trailing,
                             ).padding(.trailing, 4)

                             HStack(alignment: .top, spacing: 6) {
                                 HStack(spacing: 3) {
                                     Image(systemName: "timer")
                                         .foregroundColor(.blue)
                                         .font(
                                             .system(
                                                 size: 12,
                                                 weight: .medium
                                             )
                                         )
                                     Text(context.state.powerMode)
                                         .font(
                                             .system(
                                                 size: 10,
                                                 weight: .medium
                                             )
                                         )
                                         .foregroundColor(.white)
                                 }
                                 Image(
                                     systemName: context.state
                                         .vibrationEnabled
                                         ? "iphone.radiowaves.left.and.right"
                                         : "iphone.slash"
                                 )
                                 .foregroundColor(
                                     context.state.vibrationEnabled
                                         ? .blue : .gray
                                 )
                                 .font(.system(size: 12, weight: .medium))
                             }
                             .frame(
                                 maxWidth: .infinity,
                                 alignment: .trailing
                             )

                        }.padding()

                        Link(
                            destination: URL(
                                string:
                                    "airspothealth://devices/\(context.state.deviceId)/graph"
                            )!
                        ) {
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

            // Device Name Section
            if !context.state.deviceName.isEmpty {
                Text(context.state.deviceName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -4) // Reduce spacing from top section
                    .padding(.bottom, -4) // Reduce spacing to bottom section
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
        .padding(.horizontal, 16)
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
    }
}

extension LiveActivityWidgetAttributes {
    fileprivate static var preview: LiveActivityWidgetAttributes {
        LiveActivityWidgetAttributes()
    }
}

extension LiveActivityWidgetAttributes.ContentState {
    fileprivate static var sampleData: LiveActivityWidgetAttributes.ContentState
    {
        LiveActivityWidgetAttributes.ContentState(
            deviceId: "1234567890",
            deviceName: "Living Room",
            co2Value: 450,
            powerMode: "3 Min",
            batteryLevel: 85,
            isCharging: false,
            alarmEnabled: true,
            vibrationEnabled: true,
            co2History: [
                400, 420, 450, 480, 500, 520, 540, 560, 580, 600, 620, 640, 660,
                680, 700, 720, 740, 760, 780, 800, 820, 840, 860, 880, 900, 920,
                940, 960, 980, 1000, 1020, 1040, 1060, 1080, 1100, 1120, 1140,
                1160, 1180, 1200, 1220, 1240, 1260, 1280, 1300, 1320, 1340,
                1360, 1380, 1400, 1420, 1440, 1460, 1480, 1500, 1520, 1540,
                1560,
            ],
            greenUpperLimit: 800,
            yellowUpperLimit: 1000,
            graphMaxValue: 1600,
            graphMinValue: 0,
            isRefreshing: false,
            isConnected: true,
            lastUpdated: Date(),
            activityStartTime: Date(),
            showStaleWarning: false
        )
    }

    fileprivate static var lowBatteryData:
        LiveActivityWidgetAttributes.ContentState
    {
        LiveActivityWidgetAttributes.ContentState(
            deviceId: "1234567890",
            deviceName: "Bedroom",
            co2Value: 1200,
            powerMode: "1 Min",
            batteryLevel: 25,
            isCharging: true,
            alarmEnabled: false,
            vibrationEnabled: true,
            co2History: [1000, 1100, 1200, 1250, 1300],
            greenUpperLimit: 1000,
            yellowUpperLimit: 1100,
            graphMaxValue: 1600,
            graphMinValue: 0,
            isRefreshing: false,
            isConnected: true,
            lastUpdated: Date(),
            activityStartTime: Date(),
            showStaleWarning: false
        )
    }

    fileprivate static var refreshingData:
        LiveActivityWidgetAttributes.ContentState
    {
        LiveActivityWidgetAttributes.ContentState(
            deviceId: "1234567890",
            deviceName: "Office",
            co2Value: 850,
            powerMode: "3 Min",
            batteryLevel: 65,
            isCharging: false,
            alarmEnabled: true,
            vibrationEnabled: true,
            co2History: [800, 820, 840, 860, 850],
            greenUpperLimit: 800,
            yellowUpperLimit: 1000,
            graphMaxValue: 1600,
            graphMinValue: 0,
            isRefreshing: true,
            isConnected: true,
            lastUpdated: Date(),
            activityStartTime: Date(),
            showStaleWarning: false
        )
    }

    fileprivate static var disconnectedData:
        LiveActivityWidgetAttributes.ContentState
    {
        LiveActivityWidgetAttributes.ContentState(
            deviceId: "1234567890",
            deviceName: "Kitchen",
            co2Value: 750,
            powerMode: "3 Min",
            batteryLevel: 45,
            isCharging: false,
            alarmEnabled: true,
            vibrationEnabled: false,
            co2History: [700, 720, 740, 760, 750],
            greenUpperLimit: 800,
            yellowUpperLimit: 1000,
            graphMaxValue: 1600,
            graphMinValue: 0,
            isRefreshing: false,
            isConnected: false,
            lastUpdated: Date(),
            activityStartTime: Date(),
            showStaleWarning: false
        )
    }

    fileprivate static var staleWarningData:
        LiveActivityWidgetAttributes.ContentState
    {
        LiveActivityWidgetAttributes.ContentState(
            deviceId: "1234567890",
            deviceName: "Living Room",
            co2Value: 850,
            powerMode: "3 Min",
            batteryLevel: 75,
            isCharging: false,
            alarmEnabled: true,
            vibrationEnabled: true,
            co2History: [800, 820, 840, 860, 850, 845, 840, 835],
            greenUpperLimit: 800,
            yellowUpperLimit: 1000,
            graphMaxValue: 1600,
            graphMinValue: 0,
            isRefreshing: false,
            isConnected: true,
            lastUpdated: Date(),
            activityStartTime: Date().addingTimeInterval(-7.5 * 60 * 60), // 7.5 hours ago (triggers warning)
            showStaleWarning: true
        )
    }
}

@available(iOS 17.0, *)
#Preview(
    "Notification",
    as: .content,
    using: LiveActivityWidgetAttributes.preview
) {
    LiveActivityWidgetLiveActivity()
} contentStates: {
    LiveActivityWidgetAttributes.ContentState.sampleData
    LiveActivityWidgetAttributes.ContentState.lowBatteryData
    LiveActivityWidgetAttributes.ContentState.refreshingData
    LiveActivityWidgetAttributes.ContentState.disconnectedData
    LiveActivityWidgetAttributes.ContentState.staleWarningData
}
