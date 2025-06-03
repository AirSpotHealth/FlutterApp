import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_dump_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
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
        title: t.deviceSettings.deviceDataDump,
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
  final TextEditingController _numberOfPagesController = TextEditingController()
    ..text = '16384';

  @override
  void dispose() {
    _numberOfPagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncProgressValue dataDumpState =
        ref.watch(deviceDataDumpProvider(widget.deviceId));

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: ListView(
        children: [
          Text(t.deviceSettings.deviceDataDump,
              style: context.textTheme.bodyMedium?.weight700),
          const SizedBox(height: 16),
          if (dataDumpState is AsyncNone) ...[
            TextFormField(
              controller: _numberOfPagesController,
              decoration: InputDecoration(
                labelText: t.deviceSettings.numberOfPages,
                hintText: t.deviceSettings.enterNumberOfPages,
                border: OutlineInputBorder(),
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.deviceSettings.pleaseEnterNumberOfPages;
                }

                final int? numberOfPages = int.tryParse(value);

                if (numberOfPages == null ||
                    numberOfPages <= 1 ||
                    numberOfPages > 16384) {
                  return t.deviceSettings.pleaseEnterValidNumberOfPages;
                }
                return null; // added return for the successful case
              },
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) => _startDump(value),
            ),
            const SizedBox(height: 16),
            Button(
              onPressed: () {
                if (_numberOfPagesController.text.isEmpty) {
                  return;
                }

                _startDump(_numberOfPagesController.text);
              },
              child: Text(t.deviceSettings.startDataDump),
            ),
          ],
          if (dataDumpState is AsyncInProgress)
            _buildProgressWidget(dataDumpState),
          if (dataDumpState is AsyncFailure) _buildErrorWidget(dataDumpState),
          if (dataDumpState is AsyncSuccess) _buildSuccessWidget(dataDumpState),
        ],
      ),
    );
  }

  void _startDump(String value) {
    final int? numberOfPages = int.tryParse(value);
    if (numberOfPages != null) {
      ref
          .read(deviceDataDumpProvider(widget.deviceId).notifier)
          .startDataDump(numberOfPages: numberOfPages - 1);
    } else {
      ref
          .read(deviceDataDumpProvider(widget.deviceId).notifier)
          .startDataDump();
    }
  }

  Widget _buildProgressWidget(AsyncInProgress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(progress.message ?? t.deviceSettings.processingDeviceData),
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
        Text(t.deviceSettings.failedToDumpDeviceData(error: failure.error)),
        const SizedBox(height: 16),
        Button(
          wrapWidth: true,
          onPressed: () {
            ref
                .read(deviceDataDumpProvider(widget.deviceId).notifier)
                .startDataDump();
          },
          child: Text(t.common.retry),
        ),
      ],
    );
  }

  Widget _buildSuccessWidget(AsyncSuccess success) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(t.deviceSettings.deviceDataDumpedSuccessfully),
        const SizedBox(height: 16),
        Button(
          onPressed: () {
            ref.context.pop();
            ref.invalidate(deviceDataDumpProvider(widget.deviceId));
          },
          child: Text(t.common.close),
        ),
      ],
    );
  }
}
