import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  let channelName : String = "liveActivityChannel"
  var liveActivityManager: Any?

  var liveActivityChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Live Activity Channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    liveActivityChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger) 
    if #available(iOS 16.2, *) {
      liveActivityManager = LiveActivityManager()
    }
    
    // Set up notification listener for iOS 17+ LiveActivityIntent refresh requests
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleRefreshNotification),
        name: Notification.Name("RefreshDataRequested"),
        object: nil
    )

    // Set up notification listener for live activity dismissal
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleDismissalNotification(_:)),
        name: Notification.Name("LiveActivityDismissed"),
        object: nil
    )

    // Setup notification listener for map click
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleMapClick),
        name: Notification.Name("MapClicked"),
        object: nil
    )

    // Setup notification listener for Live Activity restart requests
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleNavigateToDeviceSettings(_:)),
        name: Notification.Name("NavigateToDeviceSettings"),
        object: nil
    )

    // Setup notification listener for auto-disable live activity
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleAutoDisableLiveActivity(_:)),
        name: Notification.Name("AutoDisableLiveActivity"),
        object: nil
    )
    
    liveActivityChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard #available(iOS 16.2, *), let liveActivityManager = self?.liveActivityManager as? LiveActivityManager else {
            result(FlutterError(code: "MANAGER_NOT_INITIALIZED", message: "LiveActivityManager not initialized or not supported on this iOS version", details: nil))
            return
        }
        
        switch call.method {
        case "startLiveActivity":
            liveActivityManager.startLiveActivity(data: call.arguments as? Dictionary<String,Any>)
            result(true)
            break
        case "updateLiveActivity":
            liveActivityManager.updateLiveActivity(data: call.arguments as? Dictionary<String,Any>)
            result(true)
            break
        case "endLiveActivity":
            liveActivityManager.endLiveActivity()
            result(true)
            break
        case "isLiveActivityActive":
            result(liveActivityManager.isLiveActivityActive())
            break
        case "startRefreshState":
            liveActivityManager.startRefreshState()
            result(true)
            break
        case "resetDismissalState":
            liveActivityManager.resetDismissalState()
            result(true)
            break
        case "getLiveActivityState":
            if let arguments = call.arguments as? [String: Any],
               let deviceId = arguments["deviceId"] as? String {
                let state = liveActivityManager.getLiveActivityState(deviceId: deviceId)
                result(state)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing deviceId for getLiveActivityState", details: nil))
            }
            break
        case "addDeviceNotification":
            if let liveActivityManager = liveActivityManager as? LiveActivityManager,
               let arguments = call.arguments as? Dictionary<String, Any> {
                let deviceId = arguments["deviceId"] as? String
                let data = arguments["data"] as? Dictionary<String,Any>
                if let deviceId = deviceId, let data = data {
                    liveActivityManager.addDeviceData(deviceId: deviceId, data: data)
                }
            }
            result(true)
            break
        case "removeDeviceNotification":
            if let liveActivityManager = liveActivityManager as? LiveActivityManager,
               let arguments = call.arguments as? Dictionary<String, Any> {
                let deviceId = arguments["deviceId"] as? String
                if let deviceId = deviceId {
                    liveActivityManager.removeDeviceData(deviceId: deviceId)
                }
            }
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  @objc func handleRefreshNotification() {
      print("🔄 Live Activity refresh via LiveActivityIntent (iOS 17+)")
      if #available(iOS 16.2, *), let liveActivityManager = liveActivityManager as? LiveActivityManager {
        // Start the refresh state immediately to show blink animation
        liveActivityManager.startRefreshState()
      }
      // Also notify Flutter for any additional refresh logic
      liveActivityChannel?.invokeMethod("onRefreshRequested", arguments: nil)
  }

  @objc func handleDismissalNotification(_ notification: Notification) {
      print("📨 AppDelegate received LiveActivityDismissed notification")
      print("📨 Notification object: \(notification)")
      print("📨 UserInfo: \(notification.userInfo ?? [:])")
      
      // Get device ID from notification if available
      let deviceId = notification.userInfo?["deviceId"] as? String
      let arguments: [String: Any] = deviceId != nil ? ["deviceId": deviceId!] : [:]
      
      print("📱 Calling Flutter method 'onLiveActivityDismissed' with arguments: \(arguments)")
      print("📱 Channel available: \(liveActivityChannel != nil)")
      
      // Notify Flutter about the dismissal
      liveActivityChannel?.invokeMethod("onLiveActivityDismissed", arguments: arguments) { result in
          print("📱 Flutter method call result: \(result)")
      }
  }

  @objc func handleMapClick() {
      print("🔄 Map clicked")
      // Open the map in the browser
      UIApplication.shared.open(URL(string: "https://map.airspothealth.com/")!)
  }

  @objc func handleNavigateToDeviceSettings(_ notification: Notification) {
      print("🔄 Navigate to device settings requested")
      
      guard let userInfo = notification.userInfo,
            let deviceId = userInfo["deviceId"] as? String else {
          print("❌ No device ID found in navigation notification")
          return
      }
      
      print("📱 Navigating to device settings for: \(deviceId)")
      
      // Call Flutter method to navigate to device settings
      liveActivityChannel?.invokeMethod("onRestartLiveActivityRequested", arguments: ["deviceId": deviceId])
  }

  @objc func handleAutoDisableLiveActivity(_ notification: Notification) {
      print("🔄 Auto-disable live activity requested")
      
      guard let userInfo = notification.userInfo,
            let deviceId = userInfo["deviceId"] as? String else {
          print("❌ No device ID found in auto-disable notification")
          return
      }
      
      print("📱 Auto-disabling live activity for device: \(deviceId)")
      
      // Call Flutter method to auto-disable the live activity setting on main thread
      DispatchQueue.main.async { [weak self] in
          self?.liveActivityChannel?.invokeMethod("onAutoDisableLiveActivity", arguments: ["deviceId": deviceId])
      }
  }
   
   deinit {
       NotificationCenter.default.removeObserver(self)
   }
}
