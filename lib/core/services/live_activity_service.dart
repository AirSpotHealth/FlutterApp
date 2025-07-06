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
      debugPrint("Failed to start live activity: '${e.message}'.");
    }
  }

  Future<void> endLiveActivity() async {
    try {
      await platform.invokeMethod(
        'endLiveActivity',
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to start live activity: '${e.message}'.");
    }
  }
}
