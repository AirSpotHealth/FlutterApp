import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/widgets/device_model_icon.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/add_device/providers/ble_search_results_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_forget_status_provider.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_error_provider.dart';
import 'package:airspothealth/features/devices/widgets/device_battery_level_widget.dart';
import 'package:airspothealth/features/devices/widgets/device_value_widget.dart';
import 'package:airspothealth/features/report_issue/providers/issue_reporting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BleDeviceWidget extends ConsumerWidget {
  const BleDeviceWidget({required this.bleDevice, super.key});

  final BleDevice bleDevice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BluetoothBondState deviceConnectionState =
        ref.watch(bleDeviceConnectionProvider(bleDevice.deviceId));

    final bool deviceConnected =
        deviceConnectionState == BluetoothBondState.bonded;

    return GestureDetector(
      onLongPress: () => _showForgetDeviceSheet(ref, bleDevice.deviceId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: deviceConnected
                ? AppColors.primaryColor.withValues(alpha: 0.25)
                : AppColors.dividerLight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device name and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deviceConnected
                        ? (bleDevice.alias ?? bleDevice.name)
                        : (bleDevice.alias == null ||
                                bleDevice.alias == "Airspot")
                            ? bleDevice.name
                            : bleDevice.alias!,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DeviceModelIcon(
                  model: bleDevice.deviceModel ?? DeviceModel.airspotScreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                if (deviceConnected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandColorGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandColorGreen,
                      ),
                    ),
                  )
                else if (deviceConnectionState == BluetoothBondState.bonding)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandColorAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Connecting...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandColorAmber,
                      ),
                    ),
                  ),
              ],
            ),
            if (deviceConnected) ...[
              const SizedBox(height: 16),
              // Main sensor data display
              Row(
                children: [
                  Expanded(
                    child: DeviceValueWidget(deviceId: bleDevice.deviceId),
                  ),
                  DeviceBatteryLevelWidget(deviceId: bleDevice.deviceId),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.bar_chart,
                      label: 'Activity Logs',
                      onTap: () => context.pushNamed(
                        RouteNames.deviceGraph,
                        pathParameters: {'deviceId': bleDevice.deviceId},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () => context.pushNamed(
                        RouteNames.deviceSettings,
                        pathParameters: {'deviceId': bleDevice.deviceId},
                      ),
                    ),
                  ),
                ],
              ),
              // Show sensor error row if error is detected
              _SensorErrorRow(
                deviceId: bleDevice.deviceId,
                firmware: bleDevice.firmwareVersion,
              ),
            ] else ...[
              const SizedBox(height: 16),
              ConnectButtonRow(
                deviceId: bleDevice.deviceId,
                bondState: deviceConnectionState,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showForgetDeviceSheet(WidgetRef ref, String deviceId) {
    showModalBottomSheet(
      context: ref.context,
      builder: (context) {
        return AppBottomSheet(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Forget Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to forget this device?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Button(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    ref
                        .read(deviceForgetStatusProvider(deviceId).notifier)
                        .forget();
                    ref.context.pop();
                  },
                  child: const Text('Forget Device'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class ConnectButtonRow extends ConsumerWidget {
  const ConnectButtonRow(
      {required this.deviceId, required this.bondState, super.key});

  final String deviceId;

  final BluetoothBondState bondState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch for the bluetooth devices..
    // if it is available tell not connected
    // if it is not available tell unavailable

    final (bool isScanning, List<BluetoothDevice> devices) =
        ref.watch(bluetoothSearchResultsProvider);

    final isDeviceAvailable =
        devices.map((e) => e.remoteId.str).contains(deviceId);

    debugPrint('bondState: $bondState');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            isDeviceAvailable ? 'Not Connected' : 'Unavailable',
            style: TextStyle(color: AppColors.neutralGrey),
          ),
        ),
        if (bondState == BluetoothBondState.bonded)
          const Text('Connected',
              style: TextStyle(color: AppColors.primaryColor))
        else
          TappableWidget(
            onTap: () {
              if (bondState == BluetoothBondState.bonding) return;

              ref
                  .read(bleDeviceConnectionProvider(deviceId).notifier)
                  .connect();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bondState == BluetoothBondState.bonding
                    ? 'Connecting...'
                    : 'Connect',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact inline widget for showing sensor error in device list
class _SensorErrorRow extends ConsumerWidget {
  const _SensorErrorRow({
    required this.deviceId,
    this.firmware,
  });

  final String deviceId;
  final String? firmware;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorError = ref.watch(sensorErrorProvider(deviceId));

    if (sensorError == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sensor issue detected. Try restarting or report the issue.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _reportIssue(context, ref),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reportIssue(BuildContext context, WidgetRef ref) {
    final sensorError = ref.read(sensorErrorProvider(deviceId));
    if (sensorError == null) return;

    ref.read(issueReportingProvider.notifier).prefillFromSensorError(
          deviceId: deviceId,
          firmware: firmware,
          errorCode: sensorError.errorCode,
          recoveryAttempts: sensorError.recoveryAttempts,
          errorMessage: sensorError.errorMessage,
        );

    context.pushNamed(RouteNames.reportIssue);
  }
}
