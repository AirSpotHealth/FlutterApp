import 'package:airspothealth/features/device_settings/providers/cloud_sync_provider.dart';
import 'package:flutter/material.dart';

class CloudSyncLiveStatus extends StatelessWidget {
  const CloudSyncLiveStatus({
    super.key,
    required this.syncState,
    required this.isSyncing,
    required this.hasError,
    required this.hasSuccess,
  });

  final CloudSyncState syncState;
  final bool isSyncing;
  final bool hasError;
  final bool hasSuccess;

  @override
  Widget build(BuildContext context) {
    final Color bannerColor = hasError
        ? Colors.red.shade50
        : hasSuccess
            ? Colors.green.shade50
            : Colors.blue.shade50;
    final Color textColor = hasError
        ? Colors.red.shade800
        : hasSuccess
            ? Colors.green.shade800
            : Colors.blue.shade800;

    final String message = hasError
        ? (syncState.errorMessage ?? 'Sync failed')
        : hasSuccess
            ? (syncState.successMessage ?? 'Sync complete')
            : (syncState.statusMessage ??
                (isSyncing ? 'Working...' : 'Ready to sync when you are'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasError
                ? Icons.error_outline
                : hasSuccess
                    ? Icons.check_circle
                    : Icons.info_outline,
            color: textColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSyncing
                      ? 'Please keep this screen open until finished.'
                      : hasError
                          ? 'Check your connection or sign-in status, then try again.'
                          : 'You can safely leave after the sync completes.',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
