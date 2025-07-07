import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/factory_test/providers/test_results_export_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultExportButton extends ConsumerWidget {
  const ResultExportButton({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportState = ref.watch(testResultsExportProvider(deviceId));

    return IconButton(
      onPressed:
          exportState.isInProgress ? null : () => _showExportOptions(ref),
      icon: exportState.isInProgress
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.download_outlined, color: Colors.grey.shade600),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showExportOptions(WidgetRef ref) {
    showModalBottomSheet(
      context: ref.context,
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
                ref
                    .read(testResultsExportProvider(deviceId).notifier)
                    .exportResults('csv');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.code_outlined,
              title: 'Export as JSON',
              subtitle: 'Structured data format',
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(testResultsExportProvider(deviceId).notifier)
                    .exportResults('json');
              },
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              icon: Icons.share_outlined,
              title: 'Share Results',
              subtitle: 'Share via other apps',
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(testResultsExportProvider(deviceId).notifier)
                    .shareResults();
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
}
