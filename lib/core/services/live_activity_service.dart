import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiveActivityService {
  static const platform = MethodChannel('liveActivityChannel');

  Future<void> startLiveActivity({required LiveActivityModel data}) async {
    try {
      await platform.invokeMethod(
        'startLiveActivity',
        data.toJson(),
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to start live activity: '${e.message}'.");
    }
  }

  Future<void> updateLiveActivity({required LiveActivityModel data}) async {
    try {
      await platform.invokeMethod(
        'updateLiveActivity',
        data.toJson(),
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to update live activity: '${e.message}'.");
    }
  }

  Future<void> endLiveActivity() async {
    try {
      await platform.invokeMethod(
        'endLiveActivity',
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to end live activity: '${e.message}'.");
    }
  }

  Future<bool> isLiveActivityActive() async {
    try {
      final bool isActive = await platform.invokeMethod('isLiveActivityActive');
      return isActive;
    } on PlatformException catch (e) {
      debugPrint("Failed to check live activity status: '${e.message}'.");
      return false;
    }
  }

  Future<void> resetDismissalState() async {
    try {
      await platform.invokeMethod('resetDismissalState');
    } on PlatformException catch (e) {
      debugPrint("Failed to reset dismissal state: '${e.message}'.");
    }
  }

  Future<bool> wasUserDismissedThisSession() async {
    try {
      final bool wasDismissed =
          await platform.invokeMethod('wasUserDismissedThisSession');
      return wasDismissed;
    } on PlatformException catch (e) {
      debugPrint("Failed to check user dismissal state: '${e.message}'.");
      return false;
    }
  }
}
