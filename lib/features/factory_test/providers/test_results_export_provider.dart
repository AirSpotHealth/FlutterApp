import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final testResultsExportProvider = NotifierProvider.family
    .autoDispose<TestResultsExportNotifier, AsyncProgressValue<bool>, String>(
        TestResultsExportNotifier.new);

class TestResultsExportNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue<bool>, String> {
  final String _testedByText = '';
  final String _commentText = '';

  String get deviceId => arg;

  @override
  AsyncProgressValue<bool> build(String deviceId) {
    return const AsyncNone();
  }

  String _generateFileName(String deviceId) {
    final timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    return '$deviceId-factory-test-$timestamp';
  }

  String _generateCsvContent() {
    final testState = ref.read(factoryTestProvider(deviceId));
    final buffer = StringBuffer();

    // Header information
    buffer.writeln('FACTORY TEST RESULTS');
    buffer.writeln('Device ID,$deviceId');
    buffer.writeln('Device Variant,${testState.selectedDeviceVariant}');
    buffer.writeln(
        'Test Date,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('Tested By,$_testedByText');
    buffer.writeln('Comments,$_commentText');
    buffer.writeln(
        'Overall Status,${testState.isOverallSuccess ? 'PASS' : 'FAIL'}');
    buffer.writeln();

    // Test results
    buffer.writeln('Test Category,Test Name,Status,Comment,Value');

    for (final test in testState.automaticTests.tests) {
      buffer.writeln(
          'Automatic,${test.testName},${test.status.name.toUpperCase()},"${test.comment ?? ''}",${test.value}');
    }

    for (final test in testState.manualTests.tests) {
      buffer.writeln(
          'Manual,${test.testName},${test.status.name.toUpperCase()},"${test.comment ?? ''}",${test.value}');
    }

    return buffer.toString();
  }

  String _generateJsonContent() {
    final testState = ref.read(factoryTestProvider(deviceId));
    final data = {
      'deviceInfo': {
        'deviceId': deviceId,
        'deviceVariant': testState.selectedDeviceVariant,
      },
      'testInfo': {
        'testDate': DateTime.now().toIso8601String(),
        'testedBy': _testedByText,
        'comment': _commentText,
        'overallStatus': testState.isOverallSuccess ? 'PASS' : 'FAIL',
      },
      'testDetails': {
        'automaticTests': testState.automaticTests.tests
            .map((test) => {
                  'testName': test.testName,
                  'status': test.status.name.toUpperCase(),
                  'comment': test.comment ?? '',
                })
            .toList(),
        'manualTests': testState.manualTests.tests
            .map((test) => {
                  'testName': test.testName,
                  'status': test.status.name.toUpperCase(),
                  'comment': test.comment ?? '',
                })
            .toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> exportResults(String format) async {
    if (state.isInProgress) return;

    try {
      final fileName = _generateFileName(deviceId);

      if (format == 'csv') {
        await _exportAsCsv(fileName);
      } else if (format == 'json') {
        await _exportAsJson(fileName);
      }

      state = const AsyncSuccess(true);
    } catch (e) {
      state = AsyncFailure(e.toString());
    }
  }

  Future<void> _exportAsCsv(String fileName) async {
    final csvContent = _generateCsvContent();
    final bytes = utf8.encode(csvContent);

    await FileSaver.instance.saveAs(
      name: fileName,
      bytes: bytes,
      mimeType: MimeType.csv,
      ext: 'csv',
    );
  }

  Future<void> _exportAsJson(String fileName) async {
    final jsonContent = _generateJsonContent();
    final bytes = utf8.encode(jsonContent);

    await FileSaver.instance.saveAs(
      name: fileName,
      bytes: bytes,
      mimeType: MimeType.custom,
      ext: 'json',
    );
  }

  Future<void> shareResults() async {
    if (state.isInProgress) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _generateFileName(deviceId);

      // Create both CSV and JSON files
      final csvFile = File('${directory.path}/$fileName.csv');
      final jsonFile = File('${directory.path}/$fileName.json');

      await csvFile.writeAsString(_generateCsvContent());
      await jsonFile.writeAsString(_generateJsonContent());

      await SharePlus.instance.share(ShareParams(
        files: [XFile(csvFile.path), XFile(jsonFile.path)],
        text: 'Factory Test Results for $deviceId',
      ));
    } catch (e) {
      state = AsyncFailure(e.toString());
    }
  }
}
