import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  let channelName : String = "liveActivityChannel"
  var liveActivityManager: LiveActivityManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Live Activity Channel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let liveActivityChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger) 
    liveActivityManager = LiveActivityManager()
    liveActivityChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
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
        default:
            result(FlutterMethodNotImplemented)
        }}
      
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
}
