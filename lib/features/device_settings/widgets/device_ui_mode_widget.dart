import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UIMode {
  graph,
  bar,
  plain;

  String get displayName {
    switch (this) {
      case UIMode.plain:
        return 'Plain';
      case UIMode.graph:
        return 'Graph';
      case UIMode.bar:
        return 'Colour Bars';
    }
  }

  static UIMode fromValue(int value) {
    return UIMode.values[value];
  }

  String get imagePath {
    switch (this) {
      case UIMode.plain:
        return Assets.plain;
      case UIMode.graph:
        return Assets.barGraph;
      case UIMode.bar:
        return Assets.colorBlocks;
    }
  }
}

class DeviceUIModeWidget extends ConsumerWidget {
  const DeviceUIModeWidget({
    super.key,
    required this.deviceId,
    this.scrollController,
  });

  final String deviceId;
  final ScrollController? scrollController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    final currentMode = deviceSettings.uiMode;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screen Mode',
          style: context.textTheme.bodyMedium?.weight600,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: UIMode.values.map((mode) {
            final isSelected = currentMode == mode;
            return GestureDetector(
              onTap: () {
                ref
                    .read(deviceSettingsProvider(deviceId).notifier)
                    .updateSettings(
                      deviceSettings.copyWith(uiMode: mode),
                    );

                if (mode == UIMode.graph) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    scrollController?.animateTo(
                      scrollController?.position.maxScrollExtent ?? 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              child: Column(
                children: [
                  Container(
                    height: screenHeight * 0.2,
                    width: screenWidth / 3 - 16,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColorDark
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? AppColors.primaryColorDark.withValues(alpha: 0.05)
                          : Colors.white,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColorDark
                                    .withValues(alpha: 0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      mode.imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.primaryColorDark.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: Text(
                      mode.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryColorDark
                            : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: isSelected ? 15 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (currentMode == UIMode.graph) ...[
          const SizedBox(height: 20),
          _GraphValueDropdown(
            deviceId: deviceId,
            currentValue: deviceSettings.graphMaxValue,
            label: 'Graph Max Value',
            isMinValue: false,
            onValueChanged: (newValue) => ref
                .read(deviceSettingsProvider(deviceId).notifier)
                .updateSettings(
                  deviceSettings.copyWith(graphMaxValue: newValue),
                ),
          ),
          const SizedBox(height: 12),
          _GraphValueDropdown(
            deviceId: deviceId,
            currentValue: deviceSettings.graphMinValue,
            label: 'Graph Min Value',
            isMinValue: true,
            onValueChanged: (newValue) => ref
                .read(deviceSettingsProvider(deviceId).notifier)
                .updateSettings(
                  deviceSettings.copyWith(graphMinValue: newValue),
                ),
          ),
        ],
      ],
    );
  }

  String _getModeDescription(UIMode mode) {
    switch (mode) {
      case UIMode.plain:
        return 'Shows ${Constants.co2Text} value in plain text format.';
      case UIMode.graph:
        return 'Displays ${Constants.co2Text} readings as a bar graph with customizable maximum value and minimum value.';
      case UIMode.bar:
        return 'Shows Green, Yellow, Red ranges';
    }
  }
}

// Keep the existing _GraphMaxValueDropdown widget as is

class _GraphValueDropdown extends ConsumerWidget {
  final String deviceId;
  final int currentValue;
  final String label;
  final Function(int) onValueChanged;
  final bool isMinValue;

  // Generate values from 400 to 5000 in steps of 100
  static final List<int> _maxValues = List.generate(
    47, // (5000 - 400) / 100 + 1
    (index) => 400 + (index * 100),
  );

  // Generate values from 0 to 1600 in steps of 100
  static final List<int> _minValues = List.generate(
    17, // (1600 - 0) / 100 + 1
    (index) => index * 100,
  );

  const _GraphValueDropdown({
    required this.deviceId,
    required this.currentValue,
    required this.label,
    required this.onValueChanged,
    required this.isMinValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.weight600,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: isMinValue
                  ? _minValues.contains(currentValue)
                      ? currentValue
                      : 0
                  : _maxValues.contains(currentValue)
                      ? currentValue
                      : 1600,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: context.textTheme.bodyMedium,
              items: isMinValue
                  ? _minValues.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ppm'),
                      );
                    }).toList()
                  : _maxValues.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ppm'),
                      );
                    }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onValueChanged(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a value between 400 and 5000 ppm',
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
