import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/cloud_sync_provider.dart'
    show cloudSyncProvider;
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CloudSyncPage extends ConsumerStatefulWidget {
  final String deviceId;

  const CloudSyncPage({super.key, required this.deviceId});

  @override
  ConsumerState<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends ConsumerState<CloudSyncPage> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    // Fetch sensor config to get serial number
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sensorConfigurationProvider(widget.deviceId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorConfigState =
        ref.watch(sensorConfigurationProvider(widget.deviceId));

    final connectedDevices = ref.watch(bleConnectedDevicesProvider);
    final isConnected =
        connectedDevices.any((d) => d.remoteId.str == widget.deviceId);

    final syncState = ref.watch(cloudSyncProvider(widget.deviceId));
    final user = _supabaseService.currentUser;

    String serialNumber = 'Unknown';
    if (sensorConfigState.isSuccess) {
      final data = (sensorConfigState as AsyncSuccess).data;
      if (data is DeviceSensorConfigData) {
        serialNumber = data.serialNumber;
      }
    } else if (sensorConfigState.isInProgress) {
      serialNumber = 'Fetching...';
    } else if (sensorConfigState.isFailure) {
      serialNumber = 'Error';
    }

    return PopScope(
      canPop: !syncState.isLoading,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sync in Progress'),
            content: const Text(
                'Leaving this page will cancel the sync process. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Sync'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(
                title: 'Device Connection',
                value: isConnected ? 'Connected' : 'Disconnected',
                icon: Icons.bluetooth,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                title: 'Serial Number',
                value: serialNumber,
                icon: Icons.qr_code,
                color: Colors.blue,
              ),
              if (syncState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 16),
              if (syncState.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        Text(
                          syncState.statusMessage ?? 'Syncing...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please do not quit the app or leave this page.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (syncState.lastSyncedDate != null)
                _buildStatusCard(
                  title: 'Last Synced',
                  value: DateFormat('MMM d, yyyy h:mm a')
                      .format(syncState.lastSyncedDate!),
                  icon: Icons.cloud_done,
                  color: Colors.purple,
                ),
              const SizedBox(height: 32),
              if (user == null) ...[
                const Text(
                  'Sign in to sync your data to the cloud.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _supabaseService.signInWithGoogle();
                      setState(() {}); // Refresh UI
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign in failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Signed in as:\n${user.email}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await _supabaseService.signOut();
                        setState(() {});
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (syncState.isLoading ||
                            !isConnected ||
                            serialNumber == 'Unknown' ||
                            serialNumber == 'Fetching...' ||
                            serialNumber == 'Error')
                        ? null
                        : () {
                            ref
                                .read(
                                    cloudSyncProvider(widget.deviceId).notifier)
                                .sync();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: syncState.isLoading
                        ? const Text('Syncing in Progress...')
                        : const Text('Sync Device Data'),
                  ),
                ),
                if (syncState.successMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    syncState.successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (syncState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Sync Failed: ${syncState.errorMessage}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
