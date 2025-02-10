import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_dump_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceDataDumpWidget extends ConsumerWidget {
  const DeviceDataDumpWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue dataDumpState =
        ref.watch(deviceDataDumpProvider(deviceId));

    return SettingItemWidget(
      item: SettingItem(
        title: 'Dump Device Data',
        leadingWidget: IconBgWidget(
            backgroundColor: Colors.teal,
            child: const Icon(Icons.dataset_rounded)),
        suffixWidget: _buildSuffixWidget(ref, dataDumpState),
      ),
      onTap: () {
        if (dataDumpState is AsyncInProgress) return;

        ref.read(deviceDataDumpProvider(deviceId).notifier).startDataDump();
      },
    );
  }

  Widget _buildSuffixWidget(WidgetRef ref, AsyncProgressValue dataDumpState) {
    return dataDumpState.when(
      none: () => const Icon(Icons.arrow_forward_ios),
      inProgress: (progress, message) => CupertinoActivityIndicator(radius: 12),
      success: (data) => const Icon(Icons.check),
      failure: (error) => const Icon(Icons.error),
    );
  }
}
