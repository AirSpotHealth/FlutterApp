import 'package:airspothealth/features/device_settings/widgets/cloud_sync_animation.dart';
import 'package:flutter/material.dart';

class CloudSyncHero extends StatelessWidget {
  const CloudSyncHero({
    super.key,
    required this.isSyncing,
    required this.hasError,
    required this.hasSuccess,
    required this.primaryStatus,
    required this.statusMessage,
  });

  final bool isSyncing;
  final bool hasError;
  final bool hasSuccess;
  final String primaryStatus;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasError
              ? [Colors.red.shade700, Colors.red.shade400]
              : [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          CloudSyncAnimation(
            isSyncing: isSyncing,
            isSuccess: hasSuccess,
            isError: hasError,
            size: 96,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusMessage ??
                      (isSyncing
                          ? 'Keeping your data safe in the cloud...'
                          : 'Pick a range and sync instantly'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (isSyncing) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white70,
                    ),
                    backgroundColor: Colors.white24,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
