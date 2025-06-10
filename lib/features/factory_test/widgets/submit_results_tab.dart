import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SubmitResultsTab extends ConsumerStatefulWidget {
  const SubmitResultsTab({super.key});

  @override
  ConsumerState<SubmitResultsTab> createState() => _SubmitResultsTabState();
}

class _SubmitResultsTabState extends ConsumerState<SubmitResultsTab> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _testedByController = TextEditingController();
  bool _isExporting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _testedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final factoryTestState = ref.watch(factoryTestProvider);

    if (!factoryTestState.isTestingComplete) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Complete All Tests First',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Results will be available after all tests are completed',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildCleanHeader(context, factoryTestState),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubmissionSection(factoryTestState),
                  const SizedBox(height: 16),
                  _buildDeviceInfo(factoryTestState),
                  const SizedBox(height: 16),
                  _buildResultsSummary(factoryTestState),
                  const SizedBox(height: 16),
                  _buildActionSection(context, factoryTestState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanHeader(BuildContext context, FactoryTestState state) {
    final automaticPassed = state.automaticTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final automaticTotal = state.automaticTests.tests.length;

    final manualPassed = state.manualTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final manualTotal = state.manualTests.tests.length;

    final totalPassed = automaticPassed + manualPassed;
    final totalTests = automaticTotal + manualTotal;
    final overallSuccess = totalTests > 0 && totalPassed == totalTests;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: overallSuccess ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              overallSuccess ? Icons.check_circle : Icons.cancel,
              size: 20,
              color:
                  overallSuccess ? Colors.green.shade600 : Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overallSuccess ? 'All Tests Passed' : 'Some Tests Failed',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '$totalPassed of $totalTests tests completed successfully',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSection(FactoryTestState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Results',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Tested By Field
          Text(
            'Tested By',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _testedByController,
            decoration: InputDecoration(
              hintText: 'Enter tester name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFF8C00), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          // Comments Field
          Text(
            'Comments (Optional)',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _commentController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add any additional notes about the test',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFF8C00), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmittingResults
                  ? null
                  : () => _submitResults(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: state.isSubmittingResults
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Test Results',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(FactoryTestState state) {
    final device = ref.read(factoryTestProvider).selectedDeviceId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Information',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.devices, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                'Device: $device',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (state.selectedDeviceVariant != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.memory, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  'Sensor: ${state.selectedDeviceVariant == 0 ? 'SCD40' : 'SCD41'}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary(FactoryTestState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Test Summary',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed:
                    _isExporting ? null : () => _showExportOptions(state),
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download_outlined,
                        color: Colors.grey.shade600),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTestCategory('Automatic Tests', state.automaticTests.tests),
          const SizedBox(height: 12),
          _buildTestCategory('Manual Tests', state.manualTests.tests),
        ],
      ),
    );
  }

  Widget _buildTestCategory(String title, List<TestResult> tests) {
    final passCount =
        tests.where((test) => test.status == TestStatus.pass).length;
    final totalCount = tests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: passCount == totalCount
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: passCount == totalCount
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Text(
                '$passCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: passCount == totalCount
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tests.map((test) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    test.status == TestStatus.pass
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: test.status == TestStatus.pass
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      test.testName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (test.comment != null && test.comment!.isNotEmpty)
                    Text(
                      _cleanupComment(test.comment!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, FactoryTestState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _restartTest(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text(
              'Start New Test',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Exit Factory Test',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isOverallSuccess(FactoryTestState state) {
    final automaticPassed = state.automaticTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final automaticTotal = state.automaticTests.tests.length;

    final manualPassed = state.manualTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final manualTotal = state.manualTests.tests.length;

    final totalPassed = automaticPassed + manualPassed;
    final totalTests = automaticTotal + manualTotal;

    return totalTests > 0 && totalPassed == totalTests;
  }

  String _cleanupComment(String comment) {
    // Handle special case for charge test with redundant auto-start + user confirmation
    if (comment.contains('Auto-started after automatic tests completed') &&
        comment.contains('User confirmed')) {
      // For charge test, just show "User confirmed" without the auto-start part
      return 'User confirmed';
    }

    // Keep other "User confirmed" comments as they are meaningful
    return comment;
  }

  void _showExportOptions(FactoryTestState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Export Test Results',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              icon: Icons.table_chart_outlined,
              title: 'Export as CSV',
              subtitle: 'Spreadsheet format',
              onTap: () {
                Navigator.pop(context);
                _exportResults(state, 'csv');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.code_outlined,
              title: 'Export as JSON',
              subtitle: 'Structured data format',
              onTap: () {
                Navigator.pop(context);
                _exportResults(state, 'json');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.share_outlined,
              title: 'Share Results',
              subtitle: 'Share via other apps',
              onTap: () {
                Navigator.pop(context);
                _shareResults(state);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _exportResults(FactoryTestState state, String format) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final deviceId = ref.read(factoryTestProvider).selectedDeviceId;
      final fileName = _generateFileName(deviceId!);

      if (format == 'csv') {
        await _exportAsCsv(state, deviceId, fileName);
      } else if (format == 'json') {
        await _exportAsJson(state, deviceId, fileName);
      }

      if (mounted) {
        context.showSnackBar('Results exported successfully!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportAsCsv(
      FactoryTestState state, String deviceId, String fileName) async {
    final csvContent = _generateCsvContent(state, deviceId);
    final bytes = utf8.encode(csvContent);

    await FileSaver.instance.saveAs(
      name: fileName,
      bytes: bytes,
      mimeType: MimeType.csv,
      ext: 'csv',
    );
  }

  Future<void> _exportAsJson(
      FactoryTestState state, String deviceId, String fileName) async {
    final jsonContent = _generateJsonContent(state, deviceId);
    final bytes = utf8.encode(jsonContent);

    await FileSaver.instance.saveAs(
      name: fileName,
      bytes: bytes,
      mimeType: MimeType.custom,
      ext: 'json',
    );
  }

  Future<void> _shareResults(FactoryTestState state) async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final deviceId = ref.read(factoryTestProvider).selectedDeviceId;
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _generateFileName(deviceId!);

      // Create both CSV and JSON files
      final csvFile = File('${directory.path}/$fileName.csv');
      final jsonFile = File('${directory.path}/$fileName.json');

      await csvFile.writeAsString(_generateCsvContent(state, deviceId));
      await jsonFile.writeAsString(_generateJsonContent(state, deviceId));

      await SharePlus.instance.share(ShareParams(
        files: [XFile(csvFile.path), XFile(jsonFile.path)],
        text: 'Factory Test Results for $deviceId',
      ));
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Share failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _generateFileName(String deviceId) {
    final timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    return '$deviceId-factory-test-$timestamp';
  }

  String _generateCsvContent(FactoryTestState state, String deviceId) {
    final buffer = StringBuffer();

    // Header information
    buffer.writeln('FACTORY TEST RESULTS');
    buffer.writeln('Device ID,$deviceId');
    buffer.writeln('Device Variant,${state.selectedDeviceVariant}');
    buffer.writeln(
        'Test Date,${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('Tested By,${_testedByController.text}');
    buffer.writeln(
        'Overall Status,${_isOverallSuccess(state) ? 'PASS' : 'FAIL'}');
    buffer.writeln('Comments,${_commentController.text}');
    buffer.writeln();

    // Test results
    buffer.writeln('Test Category,Test Name,Status,Comment,Value');

    for (final test in state.automaticTests.tests) {
      buffer.writeln(
          'Automatic,${test.testName},${test.status.name.toUpperCase()},"${test.comment ?? ''}",${test.value}');
    }

    for (final test in state.manualTests.tests) {
      buffer.writeln(
          'Manual,${test.testName},${test.status.name.toUpperCase()},"${test.comment ?? ''}",${test.value}');
    }

    return buffer.toString();
  }

  String _generateJsonContent(FactoryTestState state, String deviceId) {
    final data = {
      'deviceInfo': {
        'deviceId': deviceId,
        'deviceVariant': state.selectedDeviceVariant,
      },
      'testInfo': {
        'testDate': DateTime.now().toIso8601String(),
        'testedBy': _testedByController.text,
        'comment': _commentController.text,
        'overallStatus': _isOverallSuccess(state) ? 'PASS' : 'FAIL',
      },
      'testDetails': {
        'automaticTests': state.automaticTests.tests
            .map((test) => {
                  'testName': test.testName,
                  'status': test.status.name.toUpperCase(),
                  'comment': test.comment ?? '',
                })
            .toList(),
        'manualTests': state.manualTests.tests
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

  Future<void> _submitResults(FactoryTestState state) async {
    // Validate required fields
    if (_testedByController.text.trim().isEmpty) {
      context.showSnackBar('Please enter the tester name');
      return;
    }

    try {
      final device = ref.read(factoryTestProvider).selectedDeviceId;

      await ref.read(factoryTestProvider.notifier).submitTestResults(
            macAddress: device!,
            deviceId: device,
            testedBy: _testedByController.text.trim(),
            status: _isOverallSuccess(state) ? 'PASS' : 'FAIL',
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
            sensorVariant:
                ref.read(factoryTestProvider.notifier).getSensorVariant(device),
            deviceType:
                ref.read(factoryTestProvider.notifier).getDeviceType(device),
          );

      // Check if submission was successful
      final updatedState = ref.read(factoryTestProvider);
      if (updatedState.resultsSubmitted) {
        if (mounted) {
          context.showSnackBar('Test results submitted successfully!');
          _showSubmissionSuccessDialog();
        }
      } else if (updatedState.submissionError != null) {
        if (mounted) {
          context.showSnackBar(updatedState.submissionError!);
        }
      }
    } catch (e) {
      debugPrint('Error submitting results: $e');
      if (mounted) {
        context.showSnackBar('Failed to submit results: ${e.toString()}');
      }
    }
  }

  void _showSubmissionSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.cloud_done, color: Colors.green.shade600, size: 32),
        ),
        title: const Text(
          'Submission Successful',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Factory test results have been successfully submitted to the server.\n\n'
          'The device is now restarting in normal mode.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit factory test
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _restartTest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Start New Test',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to start a new factory test? '
          'This will reset all current results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(factoryTestProvider.notifier).resetFactoryTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start New Test'),
          ),
        ],
      ),
    );
  }
}
