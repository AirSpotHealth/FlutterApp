import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return 'Bar';
    }
  }

  static UIMode fromValue(int value) {
    return UIMode.values[value];
  }
}

class DeviceUIModeWidget extends ConsumerWidget {
  const DeviceUIModeWidget({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    final currentMode = deviceSettings.uiMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UI Mode',
          style: context.textTheme.bodyMedium?.weight600,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: UIMode.values.map((mode) {
              final isSelected = currentMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                        deviceSettings.copyWith(uiMode: mode),
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      mode.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryColorDark
                            : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getModeDescription(currentMode),
          style: context.textTheme.bodySmall?.weight500?.copyWith(
            color: context.textTheme.bodySmall?.color?.withValues(alpha: .7),
          ),
        ),
        if (currentMode == UIMode.graph) ...[
          const SizedBox(height: 20),
          _GraphMaxValueDropdown(
            deviceId: deviceId,
            currentValue: deviceSettings.graphMaxValue,
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
        return 'Displays ${Constants.co2Text} readings as a line graph with customizable maximum value.';
      case UIMode.bar:
        return 'Shows ${Constants.co2Text} value as a vertical bar indicator.';
    }
  }
}

// Keep the existing _GraphMaxValueDropdown widget as is

class _GraphMaxValueDropdown extends ConsumerWidget {
  final String deviceId;
  final int currentValue;

  // Generate values from 400 to 5000 in steps of 100
  static final List<int> _values = List.generate(
    47, // (5000 - 400) / 100 + 1
    (index) => 400 + (index * 100),
  );

  const _GraphMaxValueDropdown({
    required this.deviceId,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Graph Max Value',
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
              value: _values.contains(currentValue) ? currentValue : 1600,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: context.textTheme.bodyMedium,
              items: _values.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value ppm'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                        ref.read(deviceSettingsProvider(deviceId)).copyWith(
                              graphMaxValue: newValue,
                            ),
                      );
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

class _GraphMaxValueSelector extends ConsumerStatefulWidget {
  final String deviceId;
  final int currentValue;

  const _GraphMaxValueSelector({
    required this.deviceId,
    required this.currentValue,
  });

  @override
  ConsumerState<_GraphMaxValueSelector> createState() =>
      _GraphMaxValueSelectorState();
}

class _GraphMaxValueSelectorState
    extends ConsumerState<_GraphMaxValueSelector> {
  late final TextEditingController _controller;
  late int _currentValue;
  static const int _minValue = 400;
  static const int _maxValue = 5000;
  static const int _step = 100;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int value) {
    if (value >= _minValue && value <= _maxValue) {
      setState(() {
        _currentValue = value;
        _controller.text = value.toString();
      });

      ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSettings(
            ref.read(deviceSettingsProvider(widget.deviceId)).copyWith(
                  graphMaxValue: value,
                ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Graph Max Value (ppm)',
          style: context.textTheme.bodyMedium?.weight600,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _currentValue.toDouble(),
                min: _minValue.toDouble(),
                max: _maxValue.toDouble(),
                divisions: (_maxValue - _minValue) ~/ _step,
                label: '${_currentValue}ppm',
                activeColor: AppColors.primaryColorDark,
                onChanged: (value) => _updateValue(value.round()),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  suffixText: 'ppm',
                  suffixStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _MaxValueTextInputFormatter(_minValue, _maxValue),
                ],
                onSubmitted: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null) {
                    // Round to nearest step
                    final roundedValue =
                        ((intValue + _step / 2) ~/ _step) * _step;
                    _updateValue(roundedValue.clamp(_minValue, _maxValue));
                  } else {
                    _controller.text = _currentValue.toString();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_minValue}ppm',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${_maxValue}ppm',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _PresetButton(
              label: '1600',
              isSelected: _currentValue == 1600,
              onTap: () => _updateValue(1600),
            ),
            _PresetButton(
              label: '2000',
              isSelected: _currentValue == 2000,
              onTap: () => _updateValue(2000),
            ),
            _PresetButton(
              label: '3000',
              isSelected: _currentValue == 3000,
              onTap: () => _updateValue(3000),
            ),
            _PresetButton(
              label: '4000',
              isSelected: _currentValue == 4000,
              onTap: () => _updateValue(4000),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColorDark : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryColorDark : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '${label}ppm',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.primaryColorDark,
          ),
        ),
      ),
    );
  }
}

class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _MaxValueTextInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value > max) {
      return TextEditingValue(
        text: max.toString(),
        selection: TextSelection.collapsed(offset: max.toString().length),
      );
    }

    return newValue;
  }
}
