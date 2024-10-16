import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Co2AlertSettingsPage extends ConsumerStatefulWidget {
  const Co2AlertSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Co2AlertSettingsPageState();
}

class _Co2AlertSettingsPageState extends ConsumerState<Co2AlertSettingsPage> {
  late int selectedAlertValue;

  @override
  void initState() {
    super.initState();

    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));

    selectedAlertValue =
        deviceSettings.co2AlertThreshold ?? Constants.defaultco2AlertThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('High CO2 Alert'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Alert Value',
                  style: context.textTheme.bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: selectedAlertValue,
                  items: Constants.co2PPMValues
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ))
                      .toList(),
                  borderRadius: BorderRadius.circular(8),
                  underline: const SizedBox(),
                  icon: const SizedBox.shrink(),
                  dropdownColor: Colors.white,
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedAlertValue = value;
                      });
                    }

                    if (deviceSettings.co2AlertThreshold != null) {
                      ref
                          .read(
                              deviceSettingsProvider(widget.deviceId).notifier)
                          .updateSettings(
                            deviceSettings.copyWith(co2AlertThreshold: value),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(width: 24),
              Switch(
                value: deviceSettings.co2AlertThreshold != null,
                onChanged: (value) {
                  ref
                      .read(deviceSettingsProvider(widget.deviceId).notifier)
                      .updateSettings(
                        deviceSettings.copyWith(
                            co2AlertThreshold:
                                value ? selectedAlertValue : null),
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'When turned on High Co2 alert will appear on your BlueTooth-linked mobile phone device.',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
