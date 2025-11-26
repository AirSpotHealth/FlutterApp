import 'dart:io';

import 'package:airspothealth/core/services/vibration_pattern_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

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
            '@drawable/ic_notification'); // Proper notification icon

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

    // Create Android Notification Channels
    const AndroidNotificationChannel alertsChannel = AndroidNotificationChannel(
      'alerts', // id
      'Alerts', // name
      description: 'Notification for announcements & blogs', // description
      importance: Importance.high,
      playSound: true,
      ledColor: AppColors.primaryColorDark,
      enableVibration: false,
    );

    const AndroidNotificationChannel co2Channel = AndroidNotificationChannel(
      'co2_notifications', // id - separate from FCM
      'CO₂ Notifications', // name
      description: 'High CO₂ level notifications', // description
      importance: Importance.max,
      playSound:
          true, // Enable sound by default - mobile ring settings will control it
      ledColor: AppColors.brandColorRed,
      enableVibration: false, // We use custom vibration patterns
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alertsChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(co2Channel);

    // Request permission for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Initialize Firebase Messaging
    try {
      await initFirebaseMessaging();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      // Continue even if Firebase fails
    }

    // For iOS, permissions are requested via DarwinInitializationSettings.
    // For older Android versions, permissions are granted at install time.

    final bool? initialized = await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Check iOS notification permissions after initialization
    if (Platform.isIOS) {
      final iosImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final bool? permissions = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('📱 iOS notification permissions granted: $permissions');
      }
    }

    return initialized ?? false;
  }

  static Future<void> initFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
        '📱 Firebase messaging permission status: ${settings.authorizationStatus}');
    debugPrint('📱 Alert setting: ${settings.alert}');
    debugPrint('📱 Badge setting: ${settings.badge}');
    debugPrint('📱 Sound setting: ${settings.sound}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        // Show local notification for foreground messages
        showNotificationFromFCM(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A message opened the app: ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a notification (when app was terminated)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage.data);
    }
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
      largeIcon: DrawableResourceAndroidBitmap(
          '@drawable/ic_launcher_foreground'), // Colorful logo
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

  /// Callback for when a notification is tapped (for local notifications)
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('notification payload: $payload');
      // If payload is a URL, open it
      if (payload.startsWith('http://') || payload.startsWith('https://')) {
        _openUrl(payload);
      }
      // You can add more payload handling logic here
    }
  }

  /// Handle notification tap with FCM data
  static void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Handling notification tap with data: $data');

    // Check if there's a URL in the data payload
    if (data.containsKey('url')) {
      final String url = data['url'];
      _openUrl(url);
    }
  }

  /// Open URL in browser
  static Future<void> _openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
        debugPrint('Opened URL: $url');
      } else {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  /// Show notification from FCM message with image support
  static Future<void> showNotificationFromFCM(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    final String title = notification.title ?? 'Notification';
    final String body = notification.body ?? '';
    final String? imageUrl = notification.android?.imageUrl ??
        notification.apple?.imageUrl ??
        data['image']; // Fallback to data payload
    final String? url = data['url']; // URL to open on tap

    // Download image if available
    String? imagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imagePath = await _downloadAndSaveImage(imageUrl);
    }

    // Prepare notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alerts',
      'Alerts',
      channelDescription: 'Notification alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      largeIcon: const DrawableResourceAndroidBitmap(
          '@drawable/ic_launcher_foreground'), // Colorful logo
      color: AppColors.primaryColor,
      styleInformation: imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              contentTitle: title,
              summaryText: body,
              htmlFormatContentTitle: true,
              htmlFormatSummaryText: true,
            )
          : BigTextStyleInformation(
              body,
              htmlFormatBigText: true,
              contentTitle: title,
              htmlFormatContentTitle: true,
            ),
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments:
          imagePath != null ? [DarwinNotificationAttachment(imagePath)] : null,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.limitToBitSize(31),
      title,
      body,
      notificationDetails,
      payload: url, // Pass URL as payload for tap handling
    );
  }

  /// Download and save image from URL for notification
  static Future<String?> _downloadAndSaveImage(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Image downloaded and saved: ${file.path}');
        return file.path;
      } else {
        debugPrint('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  /// Show CO2 notification based on preferences
  static Future<void> showCO2Notification({
    required String deviceName,
    required int co2Value,
    required int threshold,
    String? customMessage,
    bool vibrate = true,
  }) async {
    final message = customMessage ?? 'CO₂ level is $co2Value ppm';

    debugPrint('📱 CO2 Notification - Preparing to show notification');
    debugPrint('📱 Platform: ${Platform.operatingSystem}');
    debugPrint('📱 Device: $deviceName, CO2: $co2Value, Threshold: $threshold');
    debugPrint('📱 Sound: always on, Vibrate: $vibrate');

    // Check iOS permissions before showing notification
    if (Platform.isIOS) {
      final iosImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        try {
          final bool? hasPermissions = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          debugPrint('📱 iOS notification permissions check: $hasPermissions');
          if (hasPermissions == false) {
            debugPrint(
                '⚠️ iOS notification permissions not granted - notification may not appear');
          }
        } catch (e) {
          debugPrint('⚠️ Error checking iOS permissions: $e');
        }
      }
    }

    // Note: Vibration patterns are now handled by the vibration package
    // instead of AndroidNotificationDetails.vibrationPattern

    // Format time (e.g. 10:30 AM)
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeString = '$hour:$minute $period';

    final title = '$co2Value PPM ($timeString)';
    final body = '$deviceName\n$message';

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'co2_notifications', // Channel ID - separate from FCM
      'CO₂ Notifications', // Channel name
      channelDescription: 'High CO₂ level notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Always on - controlled by mobile ring settings
      enableVibration: Platform.isAndroid && vibrate
          ? false
          : vibrate, // Disable default vibration - we use custom patterns
      largeIcon: const DrawableResourceAndroidBitmap(
          '@drawable/ic_launcher_foreground'), // Colorful logo
      color: AppColors.brandColorRed,
      ledColor: AppColors.brandColorRed,
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: null, // Removed summary text to keep it clean
      ),
    );

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true, // Always on - controlled by mobile ring settings
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    final notificationId =
        co2Value.hashCode % 2147483647; // Ensure positive 32-bit int
    debugPrint('📱 Showing notification with ID: $notificationId');

    try {
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: 'co2_alert:$deviceName:$co2Value',
      );
      debugPrint('✅ Notification.show() called successfully');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }

    // Trigger vibration pattern if vibration is enabled
    if (vibrate && Platform.isAndroid) {
      await VibrationPatternService.triggerVibrationPattern(threshold);
    }
  }

  /// Check current notification permission status
  static Future<bool> checkNotificationPermissionStatus() async {
    if (Platform.isIOS) {
      final iosImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        try {
          final bool? hasPermissions = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          debugPrint('📱 iOS notification permission status: $hasPermissions');
          return hasPermissions ?? false;
        } catch (e) {
          debugPrint('⚠️ Error checking iOS notification permissions: $e');
          return false;
        }
      }
    } else if (Platform.isAndroid) {
      final androidImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        try {
          final bool? hasPermissions =
              await androidImpl.areNotificationsEnabled();
          debugPrint(
              '📱 Android notification permission status: $hasPermissions');
          return hasPermissions ?? false;
        } catch (e) {
          debugPrint('⚠️ Error checking Android notification permissions: $e');
          return false;
        }
      }
    }
    return false;
  }

  /// Test notification to verify system is working
  static Future<void> showTestNotification() async {
    debugPrint('📱 Sending test notification...');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'co2_notifications',
      'CO₂ Notifications',
      channelDescription: 'High CO₂ level notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      color: AppColors.brandColorRed,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        999999, // Unique test ID
        'Test Notification',
        'If you see this, notifications are working correctly!',
        notificationDetails,
        payload: 'test',
      );
      debugPrint('✅ Test notification sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
    }
  }

  /// Get FCM token for remote notifications
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic for remote notifications
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Handle the message here
}
