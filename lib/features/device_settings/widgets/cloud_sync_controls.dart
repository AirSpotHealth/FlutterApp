import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_range_selector.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CloudSyncControls extends StatelessWidget {
  const CloudSyncControls({
    super.key,
    required this.userEmail,
    required this.isSyncing,
    required this.isConnected,
    required this.serialReady,
    required this.selectedDuration,
    required this.lastSyncedDate,
    required this.onSignIn,
    required this.onSignOut,
    required this.onRangeSelected,
    required this.onSync,
  });

  final String? userEmail;
  final bool isSyncing;
  final bool isConnected;
  final bool serialReady;
  final GraphDataDuration selectedDuration;
  final DateTime? lastSyncedDate;
  final Future<void> Function() onSignIn;
  final Future<void> Function() onSignOut;
  final void Function(GraphDataDuration) onRangeSelected;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sync to cloud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lastSyncedDate != null)
                    Text(
                      'Last sync: ${DateFormat('MMM d • h:mm a').format(lastSyncedDate!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (userEmail == null)
                ElevatedButton.icon(
                  onPressed: onSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google to sync'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Signed in as\n$userEmail',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sign out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select duration',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                AbsorbPointer(
                  absorbing: isSyncing,
                  child: Opacity(
                    opacity: isSyncing ? 0.5 : 1,
                    child: DateRangeSelector(
                      selectedRange: selectedDuration,
                      onRangeSelected: onRangeSelected,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isSyncing || !isConnected || !serialReady)
                        ? null
                        : onSync,
                    icon: Icon(
                      isSyncing ? Icons.sync : Icons.cloud_upload,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        isSyncing
                            ? 'Syncing... stay on this screen'
                            : 'Start sync now',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isConnected
                      ? 'Keep your device nearby during sync.'
                      : 'Turn on Bluetooth and keep the device close.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
