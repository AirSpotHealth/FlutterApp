import 'dart:async';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/providers/tester_name_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubmissionStatus {
  idle,
  submitting,
  success,
  error,
}

class SubmissionState {
  final SubmissionStatus status;
  final String? errorMessage;
  final bool resultsSubmitted;
  final bool putDeviceToSleep;
  final String comment;

  const SubmissionState({
    this.status = SubmissionStatus.idle,
    this.errorMessage,
    this.resultsSubmitted = false,
    this.putDeviceToSleep = true,
    this.comment = '',
  });

  SubmissionState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    bool? resultsSubmitted,
    bool? putDeviceToSleep,
    String? comment,
  }) {
    return SubmissionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      resultsSubmitted: resultsSubmitted ?? this.resultsSubmitted,
      putDeviceToSleep: putDeviceToSleep ?? this.putDeviceToSleep,
      comment: comment ?? this.comment,
    );
  }
}

final submissionProvider =
    NotifierProvider.family<SubmissionNotifier, SubmissionState, String>(
  SubmissionNotifier.new,
);

class SubmissionNotifier extends FamilyNotifier<SubmissionState, String> {
  String get deviceId => arg;

  @override
  SubmissionState build(String deviceId) {
    return const SubmissionState();
  }

  /// Get the current tester name from the global provider
  String get testedBy => ref.read(testerNameProvider);

  /// Set the tester name globally for all devices
  Future<void> setTestedBy(String value) async {
    await ref.read(testerNameProvider.notifier).updateTesterName(value);
  }

  Future<void> startSubmission() async {
    try {
      try {
        state = state.copyWith(
          status: SubmissionStatus.submitting,
          errorMessage: null,
        );
      } catch (e) {
        // Ignore widget lifecycle errors - this happens when widgets are disposed
        // during async operations but it's safe to ignore
        if (e.toString().contains('_ElementLifecycle.defunct')) {
          return;
        }
        rethrow;
      }

      await _submitTestResults();

      await ref
          .read(factoryTestProvider(deviceId).notifier)
          .endFactoryTestMode(putDeviceToSleep: state.putDeviceToSleep);

      markSuccess();

      // Mark device as completed in queue after successful submission
      try {
        ref
            .read(factoryTestDevicesProvider.notifier)
            .markDeviceCompleted(deviceId, success: true);
      } catch (e) {
        // Ignore widget lifecycle errors - this is safe during cleanup
        if (!e.toString().contains('_ElementLifecycle.defunct')) {
          rethrow;
        }
      }

      // Clean up BT connection after successful completion
      ref.read(factoryTestProvider(deviceId).notifier).dispose();

      // Note: Device remains in queue as "completed" rather than being removed
      // so testers can see submission was successful
    } catch (e) {
      markError(e.toString());
    }
  }

  /// Submit factory test results to the API
  Future<void> _submitTestResults() async {
    try {
      final deviceTestState = ref.read(factoryTestProvider(deviceId));

      final deviceTestNotifier =
          ref.read(factoryTestProvider(deviceId).notifier);

      // Validate test results before submission
      _validateTestResults(deviceTestState);

      // Create automatic tests array
      final List<Map<String, dynamic>> automaticTests = [];
      for (final test in deviceTestState.automaticTests.tests) {
        automaticTests.add({
          'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
          'value': _formatTestValue(test.testName, test.value),
          'testName': test.testName,
        });
      }

      // Create manual tests array
      final List<Map<String, dynamic>> manualTests = [];
      for (final test in deviceTestState.manualTests.tests) {
        manualTests.add({
          'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
          'value': _formatTestValue(test.testName, test.value),
          'testName': test.testName,
        });
      }

      // Structure test_details as an object with automaticTests and manualTests
      final Map<String, dynamic> testDetails = {
        'automaticTests': automaticTests,
        'manualTests': manualTests,
      };

      // Prepare API payload according to the new structure
      final payload = {
        'mac_address': deviceId,
        'device_id': deviceId,
        'tested_by': testedBy,
        'status': deviceTestState.isOverallSuccess ? 'PASS' : 'FAIL',
        'comment': state.comment.trim().isEmpty ? null : state.comment.trim(),
        'sensor_variant': deviceTestState.selectedDeviceVariant ?? 0,
        'device_type': deviceTestNotifier.getDeviceType(deviceId),
        'test_details': testDetails,
      };

      debugPrint('Submitting factory test results: ${payload.toString()}');

      // Get API key from environment
      const apiKey = String.fromEnvironment('API_KEY');

      // Prepare headers
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }

      // Submit to API with headers and retry logic
      final response = await _submitWithRetry(payload, headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Factory test results submitted successfully');
      } else {
        final errorMessage = response.data != null
            ? 'Server error: ${response.data}'
            : 'Server responded with status ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Validate test results before submission to catch issues early
  void _validateTestResults(DeviceFactoryTestState deviceTestState) {
    // Check that all automatic tests have been completed
    if (!deviceTestState.automaticTests.isComplete) {
      throw Exception('Cannot submit: Automatic tests are not complete');
    }

    // Check that all manual tests have been completed
    if (!deviceTestState.manualTests.isComplete) {
      throw Exception('Cannot submit: Manual tests are not complete');
    }

    // Validate device ID format
    if (deviceId.isEmpty) {
      throw Exception('Invalid device ID format: $deviceId');
    }

    // Validate tester name is provided from global provider
    if (testedBy.trim().isEmpty) {
      throw Exception('Tester name is required before submission');
    }

    debugPrint('Test results validation passed');
  }

  /// Submit to API with retry logic for network resilience
  Future<Response> _submitWithRetry(
    Map<String, dynamic> payload,
    Map<String, String> headers,
  ) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Submission attempt $attempt of $maxRetries');

        final response = await NetworkService.instance.post(
          '/device_tests',
          payload,
          headers: headers.isNotEmpty ? headers : null,
        );

        return response;
      } catch (e) {
        debugPrint('Submission attempt $attempt failed: $e');

        if (attempt == maxRetries) {
          throw Exception('Failed to submit after $maxRetries attempts: $e');
        }

        // Exponential backoff delay
        final delay = Duration(seconds: baseDelay.inSeconds * attempt);
        debugPrint('Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    throw Exception('Unexpected error in submission retry logic');
  }

  void markSuccess() {
    try {
      state = state.copyWith(
        status: SubmissionStatus.success,
        resultsSubmitted: true,
        errorMessage: null,
      );
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (!e.toString().contains('_ElementLifecycle.defunct')) {
        rethrow;
      }
    }
  }

  void markError(String error) {
    try {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: error,
        resultsSubmitted: false,
      );
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (!e.toString().contains('_ElementLifecycle.defunct')) {
        rethrow;
      }
    }
  }

  void setPutDeviceToSleep(bool value) {
    try {
      state = state.copyWith(putDeviceToSleep: value);
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (!e.toString().contains('_ElementLifecycle.defunct')) {
        rethrow;
      }
    }
  }

  void setComment(String value) {
    try {
      state = state.copyWith(comment: value);
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (!e.toString().contains('_ElementLifecycle.defunct')) {
        rethrow;
      }
    }
  }

  void reset() {
    try {
      state = const SubmissionState();
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (!e.toString().contains('_ElementLifecycle.defunct')) {
        rethrow;
      }
    }
  }

  /// Format test value with appropriate suffix based on test name
  dynamic _formatTestValue(String testName, dynamic value) {
    if (value == null) return null;

    switch (testName) {
      case 'Sensor Test':
        return '$value ppm';
      case 'Battery Voltage Test':
        return '${value}mV';
      case 'LF Crystal Test':
        return '$value kHz';
      case 'Memory Test':
      case 'LCD Controller Test':
      case 'Charge Test':
      case 'Screen Edge Test':
      case 'Screen Black Test':
      case 'Screen White Test':
      case 'Button Test':
      case 'Buzzer Test':
      case 'Vibration Test':
      case 'Case Check':
      case 'LCD with OCA?':
        return null; // These tests typically don't have numeric values
      default:
        return value; // Return raw value for unknown tests
    }
  }
}
