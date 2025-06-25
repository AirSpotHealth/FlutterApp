import AppIntents
import Flutter
import Foundation
import home_widget

@available(iOS 16, *)
public struct BackgroundIntent: AppIntent {
   static public var title: LocalizedStringResource = "HomeWidget Background Intent"

   @Parameter(title: "Widget URI")
   var url: URL?

   @Parameter(title: "AppGroup")
   var appGroup: String?

   public init() {}

   public init(url: URL?, appGroup: String?) {
      self.url = url
      self.appGroup = appGroup
   }

   public func perform() async throws -> some IntentResult {
      if #available(iOS 17, *) {
         await HomeWidgetBackgroundWorker.run(url: url, appGroup: appGroup!)
      } else {
         // Optional: log, fallback, or just do nothing
      }

      return .result()
   }
}

@available(iOS 16, *)
@available(iOSApplicationExtension, unavailable)
extension BackgroundIntent: ForegroundContinuableIntent {}

