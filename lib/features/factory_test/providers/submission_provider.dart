import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
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
  final String testedBy;
  final String comment;

  const SubmissionState({
    this.status = SubmissionStatus.idle,
    this.errorMessage,
    this.resultsSubmitted = false,
    this.putDeviceToSleep = false,
    this.testedBy = '',
    this.comment = '',
  });

  SubmissionState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    bool? resultsSubmitted,
    bool? putDeviceToSleep,
    String? testedBy,
    String? comment,
  }) {
    return SubmissionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      resultsSubmitted: resultsSubmitted ?? this.resultsSubmitted,
      putDeviceToSleep: putDeviceToSleep ?? this.putDeviceToSleep,
      testedBy: testedBy ?? this.testedBy,
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

  Future<void> startSubmission() async {
    try {
      state = state.copyWith(
        status: SubmissionStatus.submitting,
        errorMessage: null,
      );

      await _submitTestResults();

      await ref
          .read(factoryTestProvider(deviceId).notifier)
          .endFactoryTestMode(putDeviceToSleep: state.putDeviceToSleep);

      markSuccess();

      ref.read(factoryTestDevicesProvider.notifier).removeDevice(deviceId);
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
        'tested_by': state.testedBy,
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

      // Submit to API with headers
      final response = await NetworkService.instance.post(
        '/device_tests',
        payload,
        headers: headers.isNotEmpty ? headers : null,
      );

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

  void markSuccess() {
    state = state.copyWith(
      status: SubmissionStatus.success,
      resultsSubmitted: true,
      errorMessage: null,
    );
  }

  void markError(String error) {
    state = state.copyWith(
      status: SubmissionStatus.error,
      errorMessage: error,
      resultsSubmitted: false,
    );
  }

  void setPutDeviceToSleep(bool value) {
    state = state.copyWith(putDeviceToSleep: value);
  }

  void setTestedBy(String value) {
    state = state.copyWith(testedBy: value);
  }

  void setComment(String value) {
    state = state.copyWith(comment: value);
  }

  void reset() {
    state = const SubmissionState();
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
