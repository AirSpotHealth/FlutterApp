import 'package:airspothealth/core/models/app_notification_preferences.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that manages app notification preferences and syncs with Firebase topics
final appNotificationPreferencesProvider = NotifierProvider<
    AppNotificationPreferencesNotifier, AppNotificationPreferences>(
  AppNotificationPreferencesNotifier.new,
);

class AppNotificationPreferencesNotifier
    extends Notifier<AppNotificationPreferences> {
  @override
  AppNotificationPreferences build() {
    // Load preferences asynchronously without blocking
    _loadPreferences();
    return const AppNotificationPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      state = await AppNotificationPreferences.load();
      // Sync current preferences with Firebase topics
      // This will fail gracefully if Firebase isn't initialized yet
      await _syncAllTopics();
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<void> _syncAllTopics() async {
    // Subscribe/unsubscribe to all topics based on current state
    await _syncTopic(
      AppNotificationPreferences.newsTopicName,
      state.newsNotifications,
    );
    await _syncTopic(
      AppNotificationPreferences.blogsTopicName,
      state.blogsNotifications,
    );
  }

  Future<void> _syncTopic(String topic, bool shouldSubscribe) async {
    if (shouldSubscribe) {
      await NotificationService.subscribeToTopic(topic);
    } else {
      await NotificationService.unsubscribeFromTopic(topic);
    }
  }

  Future<void> toggleNews(bool value) async {
    state = state.copyWith(newsNotifications: value);
    await state.save();
    await _syncTopic(AppNotificationPreferences.newsTopicName, value);
  }

  Future<void> toggleBlogs(bool value) async {
    state = state.copyWith(blogsNotifications: value);
    await state.save();
    await _syncTopic(AppNotificationPreferences.blogsTopicName, value);
  }
}
