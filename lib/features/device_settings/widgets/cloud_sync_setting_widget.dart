import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/services/sync_service.dart';
import 'package:airspothealth/features/auth/auth_page.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudSyncSettingWidget extends ConsumerStatefulWidget {
  const CloudSyncSettingWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  ConsumerState<CloudSyncSettingWidget> createState() =>
      _CloudSyncSettingWidgetState();
}

class _CloudSyncSettingWidgetState
    extends ConsumerState<CloudSyncSettingWidget> {
  bool _isSyncEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  void _checkSyncStatus() {
    final user = SupabaseService().currentUser;
    setState(() {
      _isSyncEnabled = user != null;
    });
  }

  Future<void> _toggleSync(bool value) async {
    if (value) {
      // User wants to enable sync -> Check Auth
      final user = SupabaseService().currentUser;
      if (user == null) {
        // Not logged in -> Show Auth Page
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );

        if (result == true) {
          // Login success
          setState(() => _isSyncEnabled = true);
          // Claim device and start sync
          try {
            await SupabaseService().claimDevice(widget.deviceId);
            await SyncService().syncData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cloud Sync Enabled')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error enabling sync: $e')),
              );
            }
          }
        }
      } else {
        // Already logged in -> Just enable
        setState(() => _isSyncEnabled = true);
        await SupabaseService().claimDevice(widget.deviceId);
        await SyncService().syncData();
      }
    } else {
      // User wants to disable sync
      // For now, we just visually disable it, but maybe we should sign out?
      // Or just stop syncing this device?
      // Let's ask confirmation to sign out for now as a simple approach
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable Cloud Sync?'),
          content: const Text(
              'This will sign you out and stop syncing data to the cloud.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disable & Sign Out'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await SupabaseService().signOut();
        setState(() => _isSyncEnabled = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Cloud Sync',
        // Use a cloud icon
        assetIcon:
            'assets/icons/cloud_sync.png', // Placeholder, need to check assets
        // Or use a standard icon if asset not available
        leadingWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.cloud_upload, color: Colors.blue),
        ),
        suffixWidget: Switch(
          value: _isSyncEnabled,
          onChanged: _toggleSync,
        ),
      ),
      onTap: () {
        _toggleSync(!_isSyncEnabled);
      },
    );
  }
}
