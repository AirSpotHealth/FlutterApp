import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Service to handle vibration patterns based on CO2 threshold levels
class VibrationPatternService {
  /// Get vibration pattern based on CO2 threshold
  /// Returns a list of durations in milliseconds for vibration pattern
  /// Pattern matches device: [ON_duration, OFF_duration, ON_duration, OFF_duration, ...]
  static List<int> getVibrationPattern(int threshold) {
    switch (threshold) {
      case 800:
        return [250, 250]; // 1 pulse: 250ms on, 250ms off
      case 1000:
        return [
          250,
          250,
          250,
          250
        ]; // 2 pulses: 250ms on, 250ms off, 250ms on, 250ms off
      case 1200:
        return [
          250,
          250,
          250,
          250,
          250,
          250
        ]; // 3 pulses: 250ms on, 250ms off, 250ms on, 250ms off, 250ms on, 250ms off
      case 1500:
        return [
          250,
          250,
          250,
          250,
          250,
          250,
          250,
          250,
          250,
          250
        ]; // 5 pulses: 250ms on, 250ms off, 250ms on, 250ms off, 250ms on, 250ms off, 250ms on, 250ms off, 250ms on, 250ms off
      default:
        // For any other threshold, use a default pattern
        if (threshold < 1000) {
          return [250, 250]; // 1 pulse for lower thresholds
        } else if (threshold < 1200) {
          return [250, 250, 250, 250]; // 2 pulses
        } else if (threshold < 1500) {
          return [250, 250, 250, 250, 250, 250]; // 3 pulses
        } else {
          return [250, 250, 250, 250, 250, 250, 250, 250, 250, 250]; // 5 pulses
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

      // Use the vibration package to trigger the pattern
      // Pattern is [ON, OFF, ON, OFF, ...] - alternate between vibrate and pause
      for (int i = 0; i < pattern.length; i += 2) {
        if (i < pattern.length) {
          // Vibrate for the ON duration
          await Vibration.vibrate(duration: pattern[i]);
          // Wait for the OFF duration (if there's a next element)
          if (i + 1 < pattern.length) {
            await Future.delayed(Duration(milliseconds: pattern[i + 1]));
          }
        }
      }
    } catch (e) {
      debugPrint('Error triggering vibration pattern: $e');
    }
  }

  /// Get vibration pattern description for UI
  static String getVibrationPatternDescription(int threshold) {
    switch (threshold) {
      case 800:
        return '1 pulse (250ms on/off)';
      case 1000:
        return '2 pulses (250ms on/off)';
      case 1200:
        return '3 pulses (250ms on/off)';
      case 1500:
        return '5 pulses (250ms on/off)';
      default:
        if (threshold < 1000) {
          return '1 pulse (250ms on/off)';
        } else if (threshold < 1200) {
          return '2 pulses (250ms on/off)';
        } else if (threshold < 1500) {
          return '3 pulses (250ms on/off)';
        } else {
          return '5 pulses (250ms on/off)';
        }
    }
  }
}
