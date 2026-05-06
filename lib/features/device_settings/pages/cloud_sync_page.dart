import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/cloud_sync_provider.dart'
    show cloudSyncProvider;
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/cloud_sync_controls.dart';
import 'package:airspothealth/features/device_settings/widgets/cloud_sync_hero.dart';
import 'package:airspothealth/features/device_settings/widgets/cloud_sync_status_wrap.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudSyncPage extends ConsumerStatefulWidget {
  final String deviceId;

  const CloudSyncPage({super.key, required this.deviceId});

  @override
  ConsumerState<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends ConsumerState<CloudSyncPage> {
  final SupabaseService _supabaseService = SupabaseService();
  GraphDataDuration _selectedDuration = GraphDataDuration.today;
  bool _autoDurationSet = false;

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
    final lastSyncedDate = syncState.lastSyncedDate;

    if (lastSyncedDate != null) {
      _maybeAutoSelectDuration(lastSyncedDate);
    }

    final bool isSyncing = syncState.isLoading;
    final bool hasError = syncState.errorMessage != null;
    final bool hasSuccess = syncState.successMessage != null;
    final String primaryStatus = isSyncing
        ? (syncState.statusMessage ?? 'Syncing...')
        : hasError
            ? 'Sync failed'
            : hasSuccess
                ? syncState.successMessage!
                : 'Ready when you are';

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
        backgroundColor: AppColors.surfaceBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Cloud Sync'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CloudSyncHero(
                  isSyncing: isSyncing,
                  hasError: hasError,
                  hasSuccess: hasSuccess,
                  primaryStatus: primaryStatus,
                  statusMessage: syncState.statusMessage,
                ),
                const SizedBox(height: 16),
                SettingsCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CloudSyncStatusWrap(
                        isConnected: isConnected,
                        serialNumber: serialNumber,
                        userEmail: user?.email,
                        lastSyncedDate: lastSyncedDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CloudSyncControls(
                  userEmail: user?.email,
                  isSyncing: isSyncing,
                  isConnected: isConnected,
                  serialReady: serialNumber != 'Unknown' &&
                      serialNumber != 'Fetching...' &&
                      serialNumber != 'Error',
                  selectedDuration: _selectedDuration,
                  lastSyncedDate: lastSyncedDate,
                  onSignIn: () async {
                    try {
                      await _supabaseService.signInWithGoogle();
                      setState(() {});
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign in failed: $e')),
                      );
                    }
                  },
                  onSignOut: () async {
                    await _supabaseService.signOut();
                    if (mounted) setState(() {});
                  },
                  onRangeSelected: (range) {
                    setState(() {
                      _selectedDuration = range;
                    });
                  },
                  onSync: () {
                    ref
                        .read(cloudSyncProvider(widget.deviceId).notifier)
                        .sync(duration: _selectedDuration);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _maybeAutoSelectDuration(DateTime lastSyncedDate) {
    if (_autoDurationSet) return;
    final now = DateTime.now();
    final start = DateTime(
      lastSyncedDate.year,
      lastSyncedDate.month,
      lastSyncedDate.day,
    );
    final range = DateTimeRange(start: start, end: now);
    setState(() {
      _selectedDuration = GraphDataDuration.custom(range);
      _autoDurationSet = true;
    });
  }
}
