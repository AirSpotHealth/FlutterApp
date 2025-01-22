import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/populate_fake_data_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopulateFakeDataWidget extends ConsumerWidget {
  const PopulateFakeDataWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue state =
        ref.watch(populateFakeDataProvider(deviceId));

    return SettingItemWidget(
      item: SettingItem(
        title: 'Populate Fake Data',
        leadingWidget: IconBgWidget(
          backgroundColor: Colors.pink,
          child: Icon(Icons.data_object),
        ),
        suffixWidget: state.when<Widget>(
          none: () => SizedBox(),
          inProgress: (_, __) => CupertinoActivityIndicator(),
          success: (_) => Icon(Icons.check, color: Colors.green),
          failure: (Object error) => Icon(Icons.error, color: Colors.red),
        ),
      ),
      onTap: () {
        if (state is AsyncInProgress) {
          return;
        }

        ref
            .read(populateFakeDataProvider(deviceId).notifier)
            .populateFakeData();
      },
    );
  }
}
