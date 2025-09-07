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
        case "forceCleanupAndRestart":
            liveActivityManager.forceCleanupAndRestart(data: call.arguments as? Dictionary<String,Any>)
            result(true)
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
   
   deinit {
       NotificationCenter.default.removeObserver(self)
   }
}
