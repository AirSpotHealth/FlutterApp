import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/models/factory_test_result.dart';
import 'package:airspothealth/core/providers/factory_test_results_provider.dart';
import 'package:airspothealth/features/factory_test/providers/tester_name_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ExportStatus { idle, exporting, success, error }

class ExportState {
  final ExportStatus status;
  final String? errorMessage;
  final String? successMessage;

  const ExportState({
    this.status = ExportStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  ExportState copyWith({
    ExportStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExportState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final factoryTestExportProvider =
    NotifierProvider<FactoryTestExportNotifier, ExportState>(
        FactoryTestExportNotifier.new);

class FactoryTestExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() {
    return const ExportState();
  }

  /// Download results as JSON file
  Future<void> downloadJson(String testedBy, String comment) async {
    if (testedBy.trim().isEmpty) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: 'Please enter your name',
      );
      return;
    }

    try {
      state = state.copyWith(status: ExportStatus.exporting);

      final results = ref.read(factoryTestResultsProvider);
      final jsonContent = _generateJsonContent(results, testedBy, comment);

      final fileName = _generateFileName();

      await FileSaver.instance.saveAs(
        name: fileName,
        bytes: utf8.encode(jsonContent),
        ext: 'json',
        mimeType: MimeType.json,
      );

      // Save tester name for future use
      await ref.read(testerNameProvider.notifier).updateTesterName(testedBy);

      state = state.copyWith(
        status: ExportStatus.success,
        successMessage: 'JSON file downloaded successfully',
      );
    } catch (e) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: 'Error downloading JSON: $e',
      );
    }
  }

  /// Send results by email
  Future<void> sendByEmail(String testedBy, String comment) async {
    if (testedBy.trim().isEmpty) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: 'Please enter your name',
      );
      return;
    }

    try {
      state = state.copyWith(status: ExportStatus.exporting);

      final results = ref.read(factoryTestResultsProvider);
      final jsonContent = _generateJsonContent(results, testedBy, comment);

      final fileName = _generateFileName();

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonContent);

      // Save tester name for future use
      await ref.read(testerNameProvider.notifier).updateTesterName(testedBy);

      // Share via email
      await SharePlus.instance.share(
        ShareParams(
          title:
              'Factory Test Results - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
          text: _generateEmailBody(testedBy, comment),
          subject:
              'Factory Test Results - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
          files: [XFile(tempFile.path)],
          downloadFallbackEnabled: true,
          mailToFallbackEnabled: true,
        ),
      );

      state = state.copyWith(
        status: ExportStatus.success,
        successMessage: 'Email app opened with results attached',
      );
    } catch (e) {
      state = state.copyWith(
        status: ExportStatus.error,
        errorMessage: 'Error sending email: $e',
      );
    }
  }

  /// Generate structured JSON content
  String _generateJsonContent(
      List<FactoryTestResult> results, String testedBy, String comment) {
    final Map<String, dynamic> data = {
      'export_info': {
        'generated_on':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'exported_by': testedBy,
        'comment': comment.isNotEmpty ? comment : null,
        'total_devices_tested': results.length,
        'overall_pass_rate': results.isEmpty
            ? 0
            : ((results.where((r) => r.status == 'PASS').length /
                        results.length) *
                    100)
                .toStringAsFixed(1),
      },
      'test_results': results.map((result) {
        final automaticTests = jsonDecode(result.automaticTestsJson) as List;
        final manualTests = jsonDecode(result.manualTestsJson) as List;

        return {
          'device_info': {
            'device_id': result.deviceId,
            'device_type': result.deviceType,
            'sensor_variant': result.sensorVariant,
          },
          'test_summary': {
            'overall_status': result.status,
            'completion_date':
                DateFormat('yyyy-MM-dd HH:mm:ss').format(result.completedAt),
            'tested_by': testedBy,
            'total_tests': result.totalTests,
            'passed_tests': result.passedTests,
            'pass_rate_percentage': result.passRate.toStringAsFixed(1),
            'comment': result.comment,
          },
          'automatic_tests': automaticTests
              .map((test) => {
                    'test_name': test['testName'],
                    'status': test['status'],
                    'value': test['value'],
                    'timestamp': test['timestamp'],
                  })
              .toList(),
          'manual_tests': manualTests
              .map((test) => {
                    'test_name': test['testName'],
                    'status': test['status'],
                    'value': test['value'],
                    'timestamp': test['timestamp'],
                  })
              .toList(),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Generate email body text
  String _generateEmailBody(String testedBy, String comment) {
    return 'Please find attached factory test results.\n\n'
        'Tested by: $testedBy\n'
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n'
        '${comment.isNotEmpty ? '\nComment: $comment' : ''}';
  }

  /// Generate filename with timestamp
  String _generateFileName() {
    return 'factory_test_results_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.json';
  }

  /// Reset the state
  void resetState() {
    state = const ExportState();
  }

  /// Get export statistics
  Map<String, dynamic> getExportStats() {
    final results = ref.read(factoryTestResultsProvider);
    final passedResults = results.where((r) => r.status == 'PASS').length;

    return {
      'total_devices': results.length,
      'passed_devices': passedResults,
      'failed_devices': results.length - passedResults,
      'overall_pass_rate':
          results.isEmpty ? 0 : (passedResults / results.length) * 100,
    };
  }
}
