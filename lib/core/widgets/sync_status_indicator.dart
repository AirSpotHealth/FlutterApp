import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/core/providers/auto_sync_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact sync status indicator for device cards.
/// Accepts a BLE deviceId and looks up the serial number internally.
/// Shows a small cloud icon with status colors:
/// - Green cloud: synced
/// - Blue pulsing cloud: sync in progress
/// - Red cloud: sync error
/// - Grey cloud: idle / no serial number
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    super.key,
    required this.deviceId,
    this.size = 16.0,
    this.showLabel = false,
  });

  /// BLE MAC address (deviceId) — serial number is looked up from sensor config.
  final String deviceId;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(devModeProvider)) return const SizedBox.shrink();
    // Look up the serial number from sensor configuration
    final sensorConfigState = ref.watch(sensorConfigurationProvider(deviceId));
    String? serialNumber;
    if (sensorConfigState is AsyncSuccess<DeviceSensorConfigData?>) {
      serialNumber =
          (sensorConfigState.data as DeviceSensorConfigData?)?.serialNumber;
    }

    // If no serial number yet, show idle grey cloud
    if (serialNumber == null || serialNumber.isEmpty) {
      return Icon(
        Icons.cloud_outlined,
        color: AppColors.neutralGrey.withValues(alpha: 0.4),
        size: size,
      );
    }

    final syncState = ref.watch(deviceSyncStateProvider(serialNumber));

    final (IconData icon, Color color, String? label) =
        switch (syncState.status) {
      SyncStatus.syncing => (
          Icons.cloud_sync_outlined,
          AppColors.primaryColor,
          'Syncing...'
        ),
      SyncStatus.success => (
          Icons.cloud_done_outlined,
          AppColors.brandColorGreen,
          'Synced'
        ),
      SyncStatus.error => (
          Icons.cloud_off_outlined,
          AppColors.brandColorRed,
          'Error'
        ),
      SyncStatus.idle => (
          Icons.cloud_outlined,
          AppColors.neutralGrey,
          null,
        ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingCloudIcon(
          icon: icon,
          color: color,
          size: size,
          isSyncing: syncState.status == SyncStatus.syncing,
        ),
        if (showLabel && label != null) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: size * 0.7,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// A cloud icon that pulses when syncing.
class _PulsingCloudIcon extends StatefulWidget {
  const _PulsingCloudIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.isSyncing,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool isSyncing;

  @override
  State<_PulsingCloudIcon> createState() => _PulsingCloudIconState();
}

class _PulsingCloudIconState extends State<_PulsingCloudIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isSyncing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingCloudIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !oldWidget.isSyncing) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSyncing && oldWidget.isSyncing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSyncing) {
      return FadeTransition(
        opacity: _opacityAnimation,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: widget.size,
        ),
      );
    }

    return Icon(
      widget.icon,
      color: widget.color,
      size: widget.size,
    );
  }
}
