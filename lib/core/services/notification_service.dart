import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static void checkNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<bool> initNotification() async =>
      await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
            channelKey: 'alerts',
            channelName: 'Alerts',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            onlyAlertOnce: true,
            groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: AppColors.primaryColor,
            ledColor: AppColors.primaryColorDark,
          )
        ],
        debug: kDebugMode,
      );

  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    String? statusBarIcon,
    String? suffixIcon,
  }) async {
    await AwesomeNotifications().dismissNotificationsByChannelKey('alerts');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.limitToBitSize(32),
        channelKey: 'alerts',
        title: title,
        body: body,
        criticalAlert: true,
        autoDismissible: true,
        largeIcon: suffixIcon,
        icon: statusBarIcon,
        payload: payload,
      ),
    );
  }
}
