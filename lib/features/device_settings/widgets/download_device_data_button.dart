import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_download_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                  .downloadDeviceData(last7Days: true);
            },
      prefixIcon: FaIcon(FontAwesomeIcons.fileExport,
          size: 18,
          color: progress is AsyncSuccess
              ? AppColors.brandColorGreen
              : AppColors.primaryColorDark),
      suffixIcon: _buildSuffixIcon(progress),
      textColor: _getTextColor(progress),
      disabled: progress is AsyncInProgress || progress is AsyncSuccess,
      label: _getLabel(progress),
    );
  }

  Widget? _buildSuffixIcon(AsyncProgressValue progress) {
    return switch (progress) {
      AsyncInProgress() => CupertinoActivityIndicator(),
      AsyncSuccess() => Icon(Icons.check_circle_outline_rounded,
          size: 18, color: AppColors.brandColorGreen),
      AsyncFailure() => Icon(Icons.error_rounded, size: 18, color: Colors.red),
      _ => null
    };
  }

  Color _getTextColor(AsyncProgressValue progress) {
    return switch (progress) {
      AsyncSuccess() => AppColors.brandColorGreen,
      AsyncError() => Colors.red,
      _ => AppColors.primaryColorDark
    };
  }

  String _getLabel(AsyncProgressValue progress) {
    if (progress is AsyncInProgress) {
      return t.downloading;
    } else if (progress is AsyncSuccess) {
      return t.csvDataExported;
    } else {
      return t.exportCsvData;
    }
  }
}
