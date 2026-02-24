import 'package:airspothealth/core/providers/auto_sync_preference_provider.dart';
import 'package:airspothealth/core/providers/auto_sync_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sensorConfigurationProvider(widget.deviceId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorConfigState =
        ref.watch(sensorConfigurationProvider(widget.deviceId));
    final user = _supabaseService.currentUser;
    final isAutoSyncEnabled = ref.watch(autoSyncPreferenceProvider);

    // Get serial number
    String? serialNumber;
    bool serialReady = false;
    if (sensorConfigState.isSuccess) {
      final data = (sensorConfigState as AsyncSuccess).data;
      if (data is DeviceSensorConfigData) {
        serialNumber = data.serialNumber;
        serialReady = true;
      }
    }

    // Get sync state
    final syncState = serialNumber != null
        ? ref.watch(deviceSyncStateProvider(serialNumber))
        : const DeviceSyncState();

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? _buildSignInPrompt(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SyncStatusCard(
                    syncState: syncState,
                    serialNumber: serialNumber,
                    lastSyncTime: syncState.lastSyncTime,
                  ),
                  const SizedBox(height: 12),
                  _AutoSyncToggleCard(
                    isEnabled: isAutoSyncEnabled,
                    onToggle: (value) {
                      ref
                          .read(autoSyncPreferenceProvider.notifier)
                          .setEnabled(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _DeviceInfoCard(
                    deviceName: () {
                      final saved = ref
                          .watch(bleSavedDevicesProvider)
                          .where((d) => d.deviceId == widget.deviceId)
                          .firstOrNull;
                      if (saved != null) {
                        return (saved.alias?.isNotEmpty == true)
                            ? saved.alias!
                            : saved.name;
                      }
                      return serialNumber ?? 'Loading...';
                    }(),
                    userEmail: user.email ?? 'Unknown',
                  ),
                  const SizedBox(height: 24),
                  _SyncNowButton(
                    isEnabled:
                        serialReady && syncState.status != SyncStatus.syncing,
                    isSyncing: syncState.status == SyncStatus.syncing,
                    onPressed: () {
                      if (serialNumber == null) return;
                      ref.read(autoSyncProvider.notifier).syncNow(
                            serialNumber: serialNumber,
                            bleDeviceId: widget.deviceId,
                          );
                    },
                  ),
                  if (syncState.status == SyncStatus.error &&
                      syncState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBanner(message: syncState.errorMessage!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sign in to sync',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in with your Google account to sync device data to the cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _supabaseService.signInWithGoogle();
                    if (mounted) setState(() {});
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign in failed: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Card ──────────────────────────────────────────────────────

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.syncState,
    required this.serialNumber,
    required this.lastSyncTime,
  });

  final DeviceSyncState syncState;
  final String? serialNumber;
  final DateTime? lastSyncTime;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String title, String subtitle) =
        switch (syncState.status) {
      SyncStatus.syncing => (
          Icons.cloud_sync_outlined,
          AppColors.primaryColor,
          'Syncing...',
          'Uploading data to the cloud',
        ),
      SyncStatus.success => (
          Icons.cloud_done_outlined,
          AppColors.brandColorGreen,
          'Synced',
          lastSyncTime != null
              ? 'Last synced ${_formatTime(lastSyncTime!)}'
              : 'All data is up to date',
        ),
      SyncStatus.error => (
          Icons.cloud_off_outlined,
          AppColors.brandColorRed,
          'Sync Failed',
          'Tap Sync Now to retry',
        ),
      SyncStatus.idle => (
          Icons.cloud_outlined,
          AppColors.neutralGrey,
          'Not yet synced',
          'Data will sync automatically',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: syncState.status == SyncStatus.syncing
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}

// ── Auto-Sync Toggle ─────────────────────────────────────────────────

class _AutoSyncToggleCard extends StatelessWidget {
  const _AutoSyncToggleCard({
    required this.isEnabled,
    required this.onToggle,
  });

  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sync,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Sync',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sync data automatically when connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
                activeTrackColor: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Device Info Card ─────────────────────────────────────────────────

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({
    required this.deviceName,
    required this.userEmail,
  });

  final String deviceName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.memory,
            label: 'Device',
            value: deviceName,
          ),
          Divider(color: AppColors.neutralGreyLight, height: 20),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Account',
            value: userEmail,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Sync Now Button ──────────────────────────────────────────────────

class _SyncNowButton extends StatelessWidget {
  const _SyncNowButton({
    required this.isEnabled,
    required this.isSyncing,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isSyncing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: isSyncing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_upload_outlined, size: 18),
        label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutralGreyLight,
          disabledForegroundColor: AppColors.neutralGrey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Error Banner ─────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandColorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandColorRed.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: AppColors.brandColorRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.brandColorRed,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
