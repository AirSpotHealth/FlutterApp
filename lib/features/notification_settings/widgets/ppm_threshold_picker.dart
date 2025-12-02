import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PpmThresholdPicker extends ConsumerStatefulWidget {
  final String deviceId;
  final NotificationPreferences preferences;
  final NotificationThreshold threshold;
  final int thresholdIndex;

  const PpmThresholdPicker({
    super.key,
    required this.deviceId,
    required this.preferences,
    required this.threshold,
    required this.thresholdIndex,
  });

  @override
  ConsumerState<PpmThresholdPicker> createState() => _PpmThresholdPickerState();
}

class _PpmThresholdPickerState extends ConsumerState<PpmThresholdPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedValue;
  late List<int> _ppmValues;
  late Color _primaryColor;

  @override
  void initState() {
    super.initState();
    // Generate PPM values from 400 to 3000 in steps of 50
    _ppmValues = List.generate(53, (i) => 400 + (i * 50));

    // Find initial index
    int initialIndex = _ppmValues.indexOf(widget.threshold.co2Threshold);
    if (initialIndex == -1) {
      // Find closest value
      initialIndex = _ppmValues
              .indexWhere((value) => value > widget.threshold.co2Threshold) -
          1;
      initialIndex = initialIndex.clamp(0, _ppmValues.length - 1);
    }

    _selectedValue = _ppmValues[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Capture theme color during didChangeDependencies to avoid accessing it during disposal
    _primaryColor = Theme.of(context).primaryColor;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Validate against other thresholds to avoid conflicts
    bool hasConflict = false;
    for (int i = 0; i < widget.preferences.notificationThresholds.length; i++) {
      if (i != widget.thresholdIndex &&
          widget.preferences.notificationThresholds[i].co2Threshold ==
              _selectedValue &&
          widget.preferences.notificationThresholds[i].co2Threshold != 0) {
        hasConflict = true;
        break;
      }
    }

    if (hasConflict) {
      if (mounted) {
        Navigator.pop(context);
        context.showSnackBar(
            'This PPM value is already used by another threshold');
      }
      return;
    }

    ref
        .read(notificationPreferencesProvider(widget.deviceId).notifier)
        .updateThreshold(
          widget.thresholdIndex,
          widget.threshold.copyWith(co2Threshold: _selectedValue),
        );

    if (mounted) {
      Navigator.pop(context);
      context.showSnackBar('Threshold updated to $_selectedValue ppm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenHeight * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 4.0),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Title
          Text(
            'CO₂ Threshold (ppm)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Select the CO₂ level for this alert',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),

          const SizedBox(height: 24),

          // Picker
          Expanded(
            child: Stack(
              children: [
                // Selection highlight
                Center(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Wheel
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _ppmValues.length,
                    builder: (context, index) {
                      final value = _ppmValues[index];
                      final isSelected = value == _selectedValue;
                      return Center(
                        child: Text(
                          '$value ppm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? _primaryColor : Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedValue = _ppmValues[index];
                    });
                  },
                ),
              ],
            ),
          ),

          // Save button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Bottom padding
          SizedBox(
            height: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 16.0,
          ),
        ],
      ),
    );
  }
}
