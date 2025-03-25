import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/csv_data_import_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportCsvDataWidget extends ConsumerWidget {
  const ImportCsvDataWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(csvDataImportProvider(deviceId));

    return SettingItemWidget(
      item: SettingItem(
        title: 'Import CSV Data',
        assetIcon: Assets.autoConnectSettings,
        suffixWidget: importState.when(
          none: () => const SizedBox(),
          inProgress: (progress, message) => SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
          ),
          success: (_) => Icon(Icons.check_circle, color: Colors.green),
          failure: (error) => Icon(Icons.error, color: Colors.red),
        ),
        leadingWidget: IconBgWidget(
          backgroundColor: Colors.lightGreen,
          child: Icon(Icons.upload_file, color: Colors.black),
        ),
      ),
      onTap: () {
        ref.read(csvDataImportProvider(deviceId).notifier).importCsvData();
      },
    );
  }
}
