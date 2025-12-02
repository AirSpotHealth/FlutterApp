import 'package:shared_preferences/shared_preferences.dart';

/// App-level notification preferences (not device-specific)
/// Manages Firebase topic subscriptions for news and blogs
class AppNotificationPreferences {
  // Firebase topic subscriptions
  final bool newsNotifications;
  final bool blogsNotifications;

  const AppNotificationPreferences({
    this.newsNotifications = false,
    this.blogsNotifications = false,
  });

  AppNotificationPreferences copyWith({
    bool? newsNotifications,
    bool? blogsNotifications,
  }) {
    return AppNotificationPreferences(
      newsNotifications: newsNotifications ?? this.newsNotifications,
      blogsNotifications: blogsNotifications ?? this.blogsNotifications,
    );
  }

  // Firebase topic names
  static const String newsTopicName = 'news';
  static const String blogsTopicName = 'blogs';

  // SharedPreferences keys
  static const String _keyNewsNotifications = 'app_notif_news';
  static const String _keyBlogsNotifications = 'app_notif_blogs';

  // Save to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_keyNewsNotifications, newsNotifications),
      prefs.setBool(_keyBlogsNotifications, blogsNotifications),
    ]);
  }

  // Load from SharedPreferences
  static Future<AppNotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppNotificationPreferences(
      newsNotifications: prefs.getBool(_keyNewsNotifications) ?? false,
      blogsNotifications: prefs.getBool(_keyBlogsNotifications) ?? false,
    );
  }
}
