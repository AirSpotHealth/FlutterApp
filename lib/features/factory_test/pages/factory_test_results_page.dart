import 'dart:convert';

import 'package:airspothealth/core/models/factory_test_result.dart';
import 'package:airspothealth/core/providers/factory_test_export_provider.dart';
import 'package:airspothealth/core/providers/factory_test_results_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/providers/tester_name_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FactoryTestResultsPage extends ConsumerStatefulWidget {
  const FactoryTestResultsPage({super.key});

  @override
  ConsumerState<FactoryTestResultsPage> createState() =>
      _FactoryTestResultsPageState();
}

class _FactoryTestResultsPageState
    extends ConsumerState<FactoryTestResultsPage> {
  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(factoryTestResultsProvider);
    final exportState = ref.watch(factoryTestExportProvider);

    // Listen to export state changes for UI feedback
    ref.listen<ExportState>(factoryTestExportProvider, (previous, current) {
      if (current.status == ExportStatus.success &&
          current.successMessage != null) {
        context.showSnackBar(current.successMessage!);
        ref.read(factoryTestExportProvider.notifier).resetState();
      } else if (current.status == ExportStatus.error &&
          current.errorMessage != null) {
        context.showSnackBar(current.errorMessage!);
        ref.read(factoryTestExportProvider.notifier).resetState();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Factory Test Results'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        actions: [
          if (results.isNotEmpty) ...[
            if (exportState.status == ExportStatus.exporting)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _showExportDialog,
                tooltip: 'Send Results',
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _showClearAllDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Results'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: results.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildSummaryCard(results),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        _buildResultCard(results[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Test Results',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete factory tests to see results here',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<FactoryTestResult> results) {
    final passedResults = results.where((r) => r.status == 'PASS').length;
    final passRate = (passedResults / results.length) * 100;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem('Total Tests', results.length.toString()),
          ),
          Expanded(
            child: _buildSummaryItem('Passed', passedResults.toString()),
          ),
          Expanded(
            child: _buildSummaryItem(
                'Pass Rate', '${passRate.toStringAsFixed(1)}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(FactoryTestResult result) {
    final isExpanded = _expandedItems.contains(result.id);
    final automaticTests = jsonDecode(result.automaticTestsJson) as List;
    final manualTests = jsonDecode(result.manualTestsJson) as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedItems.remove(result.id);
              } else {
                _expandedItems.add(result.id);
              }
            });
          },
          onLongPress: () => _showDeleteDialog(result),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: result.status == 'PASS'
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        result.status,
                        style: TextStyle(
                          color: result.status == 'PASS'
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.displayDeviceId,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      result.testedBy,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(result.completedAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.passedTests}/${result.totalTests} tests passed (${result.passRate.toStringAsFixed(1)}%)',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                if (result.comment != null && result.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Comment: ${result.comment}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildTestDetails('Automatic Tests', automaticTests),
                  const SizedBox(height: 12),
                  _buildTestDetails('Manual Tests', manualTests),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestDetails(String title, List tests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...tests.map((test) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    test['status'] == 'Pass'
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: test['status'] == 'Pass' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      test['testName'],
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  if (test['value'] != null)
                    Text(
                      test['value'].toString(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  void _showDeleteDialog(FactoryTestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test Result'),
        content: Text(
            'Are you sure you want to delete the test result for ${result.displayDeviceId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(factoryTestResultsProvider.notifier)
                  .deleteTestResult(result.id);
              context.showSnackBar('Test result deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Results'),
        content: const Text(
            'Are you sure you want to delete all test results? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(factoryTestResultsProvider.notifier).clearAllResults();
              context.showSnackBar('All test results cleared');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final testerNameController = TextEditingController(
      text: ref.read(testerNameProvider),
    );
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: testerNameController,
              decoration: const InputDecoration(
                labelText: 'Tested By *',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (Optional)',
                hintText: 'Add any notes about these results',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(factoryTestExportProvider.notifier).downloadJson(
                    testerNameController.text.trim(),
                    commentController.text.trim(),
                  );
            },
            child: const Text('Download'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(factoryTestExportProvider.notifier).sendByEmail(
                    testerNameController.text.trim(),
                    commentController.text.trim(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }
}
