import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Service to handle vibration patterns based on CO2 threshold levels
class VibrationPatternService {
  /// Get vibration pattern based on CO2 threshold
  /// Returns a list of durations in milliseconds for vibration pattern
  /// Pattern format: [wait, vibrate, wait, vibrate, ...]
  static List<int> getVibrationPattern(int threshold) {
    switch (threshold) {
      case 800:
        return [0, 400]; // 1 pulse: no wait, vibrate 400ms
      case 1000:
        return [
          0,
          400,
          200,
          400
        ]; // 2 pulses: no wait, vibrate 400ms, wait 200ms, vibrate 400ms
      case 1200:
        return [
          0,
          400,
          200,
          400,
          200,
          400
        ]; // 3 pulses: no wait, vibrate 400ms, wait 200ms, vibrate 400ms, wait 200ms, vibrate 400ms
      case 1500:
        return [
          0,
          400,
          200,
          400,
          200,
          400,
          200,
          400,
          200,
          400
        ]; // 5 pulses: no wait, vibrate 400ms, wait 200ms, vibrate 400ms, wait 200ms, vibrate 400ms, wait 200ms, vibrate 400ms, wait 200ms, vibrate 400ms
      default:
        // For any other threshold, use a default pattern
        if (threshold < 1000) {
          return [0, 400]; // 1 pulse for lower thresholds
        } else if (threshold < 1200) {
          return [0, 400, 200, 400]; // 2 pulses
        } else if (threshold < 1500) {
          return [0, 400, 200, 400, 200, 400]; // 3 pulses
        } else {
          return [0, 400, 200, 400, 200, 400, 200, 400, 200, 400]; // 5 pulses
        }
    }
  }

  /// Trigger vibration pattern based on CO2 threshold
  static Future<void> triggerVibrationPattern(int threshold) async {
    try {
      // Check if device has vibration capability
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) {
        debugPrint('Device does not have vibration capability');
        return;
      }

      final pattern = getVibrationPattern(threshold);
      debugPrint(
          'Triggering vibration pattern for threshold $threshold: $pattern');

      // Use the vibration package's built-in pattern support
      // Pattern format: [wait, vibrate, wait, vibrate, ...]
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      debugPrint('Error triggering vibration pattern: $e');
    }
  }

  /// Get vibration pattern description for UI
  static String getVibrationPatternDescription(int threshold) {
    switch (threshold) {
      case 800:
        return '1 pulse (400ms)';
      case 1000:
        return '2 pulses (400ms each, 200ms apart)';
      case 1200:
        return '3 pulses (400ms each, 200ms apart)';
      case 1500:
        return '5 pulses (400ms each, 200ms apart)';
      default:
        if (threshold < 1000) {
          return '1 pulse (400ms)';
        } else if (threshold < 1200) {
          return '2 pulses (400ms each, 200ms apart)';
        } else if (threshold < 1500) {
          return '3 pulses (400ms each, 200ms apart)';
        } else {
          return '5 pulses (400ms each, 200ms apart)';
        }
    }
  }
}
