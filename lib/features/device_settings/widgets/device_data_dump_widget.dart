import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_dump_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeviceDataDumpWidget extends ConsumerWidget {
  const DeviceDataDumpWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Dump Device Data',
        leadingWidget: IconBgWidget(
            backgroundColor: Colors.teal,
            child: const Icon(Icons.dataset_rounded)),
        suffixWidget: const Icon(Icons.download),
      ),
      onTap: () => _showDumpSheet(ref),
    );
  }

  void _showDumpSheet(WidgetRef ref) {
    showModalBottomSheet<void>(
      context: ref.context,
      builder: (context) {
        return AppBottomSheet(
          canBeDismissed: true,
          child: DataDumpSheetWidget(deviceId: deviceId),
        );
      },
    );
  }
}

class DataDumpSheetWidget extends ConsumerStatefulWidget {
  const DataDumpSheetWidget({
    required this.deviceId,
    super.key,
  });

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataDumpSheetWidgetState();
}

class _DataDumpSheetWidgetState extends ConsumerState<DataDumpSheetWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(deviceDataDumpProvider(widget.deviceId)) is AsyncNone ||
          ref.read(deviceDataDumpProvider(widget.deviceId)) is AsyncSuccess) {
        ref
            .read(deviceDataDumpProvider(widget.deviceId).notifier)
            .startDataDump();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncProgressValue dataDumpState =
        ref.watch(deviceDataDumpProvider(widget.deviceId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Device data dump',
              style: context.textTheme.bodyMedium?.weight700),
          const SizedBox(height: 16),
          if (dataDumpState is AsyncInProgress)
            _buildProgressWidget(dataDumpState),
          if (dataDumpState is AsyncFailure) _buildErrorWidget(dataDumpState),
          if (dataDumpState is AsyncSuccess) _buildSuccessWidget(dataDumpState),
        ],
      ),
    );
  }

  Widget _buildProgressWidget(AsyncInProgress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(progress.message ?? 'Processing device data....'),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: progress.progress),
      ],
    );
  }

  Widget _buildErrorWidget(AsyncFailure failure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Failed to dump device data: ${failure.error}'),
        const SizedBox(height: 16),
        Button(
          wrapWidth: true,
          onPressed: () {
            ref
                .read(deviceDataDumpProvider(widget.deviceId).notifier)
                .startDataDump();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildSuccessWidget(AsyncSuccess success) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Device data dumped successfully'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ref.context.pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
