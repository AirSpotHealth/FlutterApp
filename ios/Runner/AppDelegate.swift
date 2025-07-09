import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  let channelName : String = "liveActivityChannel"
  var liveActivityManager: LiveActivityManager?
  var liveActivityChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Live Activity Channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    liveActivityChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger) 
    liveActivityManager = LiveActivityManager()
    
    // Set up notification listener for iOS 17+ LiveActivityIntent refresh requests
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleRefreshNotification),
        name: Notification.Name("RefreshDataRequested"),
        object: nil
    )
    
    liveActivityChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard let liveActivityManager = self?.liveActivityManager else {
            result(FlutterError(code: "MANAGER_NOT_INITIALIZED", message: "LiveActivityManager not initialized", details: nil))
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
        case "resetDismissalState":
            liveActivityManager.resetDismissalState()
            result(true)
            break
        case "wasUserDismissedThisSession":
            result(liveActivityManager.wasUserDismissedThisSession())
            break
        case "startRefreshState":
            liveActivityManager.startRefreshState()
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  // Reset dismissal state when app comes to foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
      super.applicationWillEnterForeground(application)
      // Reset dismissal state when app comes back to foreground
      // This allows live activity to start again after app was backgrounded/closed
      liveActivityManager?.resetDismissalState()
  }

  @objc func handleRefreshNotification() {
      print("🔄 Live Activity refresh via LiveActivityIntent (iOS 17+)")
      // Start the refresh state immediately to show blink animation
      liveActivityManager?.startRefreshState()
      // Also notify Flutter for any additional refresh logic
      liveActivityChannel?.invokeMethod("onRefreshRequested", arguments: nil)
  }
   
   deinit {
       NotificationCenter.default.removeObserver(self)
   }
}
