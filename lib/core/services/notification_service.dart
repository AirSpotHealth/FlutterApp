import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void checkNotificationPermission() async {
    // For iOS, permission is requested during initialization or first notification.
    // For Android 13+, explicit permission is needed.
    // This method might need to be called before showing notifications on Android 13+.
    // Or, we can request permission during initNotification for simplicity.
    // For now, let's assume permissions are handled or will be handled.
    // The plugin itself handles checking if notifications are allowed.
    // If specific permission check UI is needed, platform-specific code might be required.
    // print("Permissions should be checked/requested if needed.");
  }

  static Future<bool> initNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Or your app icon

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Optional callback
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    // Create Android Notification Channel (equivalent to AwesomeNotifications channel)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alerts', // id
      'Alerts', // name
      description: 'Notification tests as alerts', // description
      importance: Importance.high,
      playSound: true,
      ledColor: AppColors.primaryColorDark,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // For iOS, permissions are requested via DarwinInitializationSettings.
    // For older Android versions, permissions are granted at install time.

    return await _notificationsPlugin.initialize(
          initializationSettings,
          // onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // Optional callback
        ) ??
        false;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    String?
        statusBarIcon, // Note: flutter_local_notifications uses a single icon for Android.
    // It's typically set in AndroidInitializationSettings.
    // Customizing per notification is limited.
    String? suffixIcon, // Note: largeIcon is supported on Android.
  }) async {
    // Dismiss previous notifications if that's the desired behavior.
    // For 'alerts' channel, this would mean cancelling all notifications.
    await _notificationsPlugin
        .cancelAll(); // Or cancel by a specific ID if known

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alerts', // Channel ID
      'Alerts', // Channel name
      channelDescription: 'Notification tests as alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      // icon: statusBarIcon, // Set in AndroidInitializationSettings
      // largeIcon: suffixIcon != null ? FilePathAndroidBitmap(suffixIcon) : null, // Requires path
      color: AppColors.primaryColor,
      ledColor: AppColors.primaryColorDark,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now()
          .millisecondsSinceEpoch
          .limitToBitSize(31), // ID must be a 32-bit int
      title,
      body,
      notificationDetails,
      payload: payload?.toString(), // Payload needs to be a String
    );
  }

  // Optional: Callback for when a notification is tapped and the app is in the foreground (iOS)
  // static void onDidReceiveLocalNotification(
  //     int id, String? title, String? body, String? payload) async {
  //   // display a dialog with the notification details, tap ok to go to another page
  // }

  // Optional: Callback for when a notification is tapped
  // static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  //   final String? payload = notificationResponse.payload;
  //   if (notificationResponse.payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   // Example: navigate to a specific screen
  //   // await Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  //   // );
  // }
}
