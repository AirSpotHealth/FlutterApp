import 'dart:convert';

import 'package:airspothealth/core/models/factory_test_result.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final factoryTestResultsProvider =
    NotifierProvider<FactoryTestResultsNotifier, List<FactoryTestResult>>(
        FactoryTestResultsNotifier.new);

class FactoryTestResultsNotifier extends Notifier<List<FactoryTestResult>> {
  final IsarService _isarService = IsarService();

  @override
  List<FactoryTestResult> build() {
    // Load all test results sorted by completion date (newest first)
    final results = _isarService.read<List<FactoryTestResult>>((isar) {
      return isar.factoryTestResults.where().sortByCompletedAtDesc().findAll();
    });
    return results;
  }

  /// Save a factory test result to the database
  Future<void> saveTestResult({
    required String deviceId,
    required String testedBy,
    required DeviceFactoryTestState testState,
    String? comment,
    required int sensorVariant,
    required String deviceType,
  }) async {
    try {
      // Prepare automatic tests data
      final automaticTests = testState.automaticTests.tests
          .map((test) => {
                'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
                'value': _formatTestValue(test.testName, test.value),
                'testName': test.testName,
                'timestamp': test.timestamp?.toIso8601String(),
              })
          .toList();

      // Prepare manual tests data
      final manualTests = testState.manualTests.tests
          .map((test) => {
                'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
                'value': _formatTestValue(test.testName, test.value),
                'testName': test.testName,
                'timestamp': test.timestamp?.toIso8601String(),
              })
          .toList();

      // Calculate totals
      final totalTests = testState.automaticTests.totalCount +
          testState.manualTests.totalCount;
      final passedTests =
          testState.automaticTests.passCount + testState.manualTests.passCount;

      // Create test result
      final testResult = FactoryTestResult(
        id: _isarService.factoryTestResults.autoIncrement(),
        deviceId: deviceId,
        completedAt: DateTime.now(),
        status: testState.isOverallSuccess ? 'PASS' : 'FAIL',
        testedBy: testedBy,
        comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
        sensorVariant: sensorVariant,
        deviceType: deviceType,
        automaticTestsJson: jsonEncode(automaticTests),
        manualTestsJson: jsonEncode(manualTests),
        totalTests: totalTests,
        passedTests: passedTests,
      );

      // Save to database
      _isarService.write((isar) async {
        isar.factoryTestResults.put(testResult);
      });

      // Refresh the state
      _refreshResults();

      debugPrint('Factory test result saved for device: $deviceId');
    } catch (e) {
      debugPrint('Error saving test result: $e');
      rethrow;
    }
  }

  /// Delete a test result
  Future<void> deleteTestResult(int id) async {
    try {
      _isarService.write((isar) async {
        isar.factoryTestResults.delete(id);
      });

      // Refresh the state
      _refreshResults();

      debugPrint('Factory test result deleted: $id');
    } catch (e) {
      debugPrint('Error deleting test result: $e');
      rethrow;
    }
  }

  /// Clear all test results
  Future<void> clearAllResults() async {
    try {
      _isarService.write((isar) async {
        isar.factoryTestResults.clear();
      });

      // Refresh the state
      _refreshResults();

      debugPrint('All factory test results cleared');
    } catch (e) {
      debugPrint('Error clearing test results: $e');
      rethrow;
    }
  }

  /// Get results for a specific device
  List<FactoryTestResult> getResultsForDevice(String deviceId) {
    return state.where((result) => result.deviceId == deviceId).toList();
  }

  /// Get results count
  int get resultsCount => state.length;

  /// Get overall pass rate
  double get overallPassRate {
    if (state.isEmpty) return 0.0;
    final passedResults =
        state.where((result) => result.status == 'PASS').length;
    return (passedResults / state.length) * 100;
  }

  /// Refresh results from database
  void _refreshResults() {
    final results = _isarService.read<List<FactoryTestResult>>((isar) {
      return isar.factoryTestResults.where().sortByCompletedAtDesc().findAll();
    });
    state = results;
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
      default:
        return value; // Return raw value for unknown tests
    }
  }
}
