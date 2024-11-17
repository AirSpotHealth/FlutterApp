import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Co2AlertSettingsPage extends ConsumerWidget {
  const Co2AlertSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    debugPrint('Co2HighAlertThreshold: ${deviceSettings.co2AlertThreshold}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: DeviceSettingsNameWidget(
        deviceId: deviceId,
        suffixText: 'High CO${Constants.subscript2} alert Settings',
      )),
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
              const SizedBox(width: 16),
              Flexible(
                child: DropdownButtonFormField<int>(
                    isDense: true,
                    value: deviceSettings.co2AlertThreshold ??
                        Constants.defaultco2AlertThreshold,
                    items: Constants.co2PPMValues
                        .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                        .toList(),
                    borderRadius: BorderRadius.circular(8),
                    alignment: Alignment.centerRight,
                    isExpanded: true,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      suffixText: 'ppm',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      enabled: deviceSettings.co2AlertThreshold != null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const SizedBox.shrink(),
                    dropdownColor: Colors.white,
                    onChanged: deviceSettings.co2AlertThreshold != null
                        ? (int? value) {
                            debugPrint('Dropdown value Co2: $value');
                            ref
                                .read(deviceSettingsProvider(deviceId).notifier)
                                .updateSettings(
                                  deviceSettings.copyWith(
                                    co2AlertThreshold: value,
                                  ),
                                );
                          }
                        : null),
              ),
              const SizedBox(width: 24),
              Switch(
                value: deviceSettings.co2AlertThreshold != null,
                onChanged: (value) {
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                        deviceSettings.copyWith(
                          co2AlertThreshold: value == true
                              ? Constants.defaultco2AlertThreshold
                              : null,
                        ),
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
