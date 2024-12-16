import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadDeviceDataButton extends ConsumerWidget {
  const DownloadDeviceDataButton(
      {required this.deviceId, this.builder, super.key});

  final String deviceId;

  final Widget Function(WidgetRef ref, AsyncProgressValue progress)? builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue progress =
        ref.watch(deviceDataDownloadProvider(deviceId));

    if (builder != null) {
      return builder!(ref, progress);
    }

    return Button(
      type: ButtonType.outlined,
      onPressed: progress is AsyncInProgress || progress is AsyncSuccess
          ? null
          : () {
              ref
                  .read(deviceDataDownloadProvider(deviceId).notifier)
                  .downloadDeviceData();
            },
      prefixIcon: _buildPrefixIcon(progress),
      textColor: _getTextColor(progress),
      disabled: progress is AsyncInProgress || progress is AsyncSuccess,
      loading: progress is AsyncInProgress,
      label: _getLabel(progress),
    );
  }

  Icon _buildPrefixIcon(AsyncProgressValue progress) {
    return Icon(
      progress is AsyncSuccess
          ? Icons.download_done_rounded
          : Icons.download_rounded,
      size: 18,
      color: _getTextColor(progress),
    );
  }

  Color _getTextColor(AsyncProgressValue progress) {
    return progress is AsyncInProgress || progress is AsyncSuccess
        ? AppColors.brandColorGreen
        : AppColors.primaryColorDark;
  }

  String _getLabel(AsyncProgressValue progress) {
    if (progress is AsyncInProgress) {
      return 'Downloading...';
    } else if (progress is AsyncSuccess) {
      return 'Device data downloaded';
    } else {
      return 'Download Device Data';
    }
  }
}
