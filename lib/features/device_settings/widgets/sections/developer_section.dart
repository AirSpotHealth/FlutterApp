import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/widgets/section_header.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_data_dump_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_variant_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/populate_fake_data_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/sensor_error_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_plus/isar_plus.dart';

class DeveloperSection extends ConsumerWidget {
  final String deviceId;

  const DeveloperSection({
    required this.deviceId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Developer Settings'),
        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.settings_input_component,
              iconColor: AppColors.indigo,
              iconBgColor: AppColors.indigo.withValues(alpha: 0.1),
              title: 'Sensor Configuration',
              onTap: () {
                context.pushNamed(RouteNames.sensorConfiguration,
                    pathParameters: {'deviceId': deviceId});
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textTertiary),
            ),
            Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SensorErrorWidget(deviceId: deviceId),
                    const SizedBox(height: 8),
                    PopulateFakeDataWidget(deviceId: deviceId),
                    const SizedBox(height: 8),
                    _buildSimpleDevActionTile(
                        'Turn off Device BT',
                        Icons.bluetooth_disabled,
                        () => ref
                            .read(bleDeviceCommunicationProvider(deviceId)
                                .notifier)
                            .sendCommand(DeviceCmdUtils.turnOffBluetooth())),
                    const SizedBox(height: 8),
                    _buildSimpleDevActionTile(
                        'Delete Local Cache', Icons.delete, () {
                      ref.read(isarServiceProvider).write((isar) {
                        isar.deviceDatas
                            .where()
                            .deviceIdEqualTo(deviceId)
                            .deleteAll();
                      });
                      ref
                          .read(bleSavedDevicesProvider.notifier)
                          .resetDeviceFetchTime(deviceId);
                      ref.invalidate(
                          deviceHistoryDataRequestProvider(deviceId));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Local cache deleted')));
                    }),
                    const SizedBox(height: 8),
                    DeviceDataDumpWidget(deviceId: deviceId),
                    const SizedBox(height: 8),
                    DeviceVariantWidget(deviceId: deviceId),
                  ],
                ))
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleDevActionTile(
      String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.dividerLight))),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
