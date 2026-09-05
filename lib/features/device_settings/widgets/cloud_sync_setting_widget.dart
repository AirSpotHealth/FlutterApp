import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/pages/cloud_sync_page.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudSyncSettingWidget extends ConsumerWidget {
  const CloudSyncSettingWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(devModeProvider)) return const SizedBox.shrink();
    return SettingItemWidget(
      item: SettingItem(
        title: 'Cloud Sync',
        leadingWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.cloud_upload, color: Colors.blue),
        ),
        suffixWidget: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CloudSyncPage(deviceId: deviceId),
          ),
        );
      },
    );
  }
}
