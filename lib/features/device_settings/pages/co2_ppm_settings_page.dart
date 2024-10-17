import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Co2PpmSettingsPage extends ConsumerStatefulWidget {
  const Co2PpmSettingsPage({required this.deviceId, super.key});
  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Co2PpmSettingsPageState();
}

class _Co2PpmSettingsPageState extends ConsumerState<Co2PpmSettingsPage> {
  late int selectedGreenUpperLimit;
  late int selectedAmberUpperLimit;

  @override
  void initState() {
    super.initState();

    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));

    selectedGreenUpperLimit = deviceSettings.greenUpperLimit;
    selectedAmberUpperLimit = deviceSettings.yellowUpperLimit;
  }

  @override
  Widget build(BuildContext context) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CO2 PPM Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BrandColors(),
          const SizedBox(height: 16),
          PpmRangePicker(
            title: 'Green upper limit',
            color: AppColors.brandColorGreen,
            initialValue: selectedGreenUpperLimit,
            onChanged: (int value) {
              selectedGreenUpperLimit = value;
            },
          ),
          const SizedBox(height: 16),
          PpmRangePicker(
            title: 'Amber upper limit',
            color: AppColors.brandColorAmber,
            initialValue: selectedAmberUpperLimit,
            onChanged: (int value) {
              selectedAmberUpperLimit = value;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (selectedGreenUpperLimit >= selectedAmberUpperLimit) {
                context.showSnackBar(
                  'Green upper limit should be less than Amber upper limit',
                );
                return;
              }

              debugPrint('Green upper limit: $selectedGreenUpperLimit');
              debugPrint('Amber upper limit: $selectedAmberUpperLimit');

              ref
                  .read(deviceSettingsProvider(widget.deviceId).notifier)
                  .updateSettings(deviceSettings);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class PpmRangePicker extends StatelessWidget {
  const PpmRangePicker({
    required this.title,
    required this.color,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String title;

  final Color color;

  final int initialValue;

  final Function(int) onChanged;

  List<int> get _range => Constants.co2PPMValues;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          height: 200,
          width: 120,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(
              initialItem: _range.indexOf(initialValue),
            ),
            itemExtent: 40,
            onSelectedItemChanged: (int index) {
              onChanged(_range[index]);
            },
            selectionOverlay: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.neutralGreyLight,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: AppColors.neutralGreyLight,
                    width: 1,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            children: _range.map(
              (int value) {
                return Center(
                  child: Text(
                    value.toString(),
                    style: context.textTheme.bodyMedium,
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class _BrandColors extends StatelessWidget {
  const _BrandColors();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandColorGreen,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandColorAmber,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandColorRed,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
