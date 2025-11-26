import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThresholdEditor extends ConsumerStatefulWidget {
  final String deviceId;
  final NotificationPreferences preferences;
  final NotificationThreshold threshold;
  final int thresholdIndex;

  const ThresholdEditor({
    super.key,
    required this.deviceId,
    required this.preferences,
    required this.threshold,
    required this.thresholdIndex,
  });

  @override
  ConsumerState<ThresholdEditor> createState() => _ThresholdEditorState();
}

class _ThresholdEditorState extends ConsumerState<ThresholdEditor> {
  late FixedExtentScrollController _scrollController;
  late int _selectedPpmValue;
  late List<int> _ppmValues;
  late TextEditingController _messageController;
  late FocusNode _focusNode;
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

    _selectedPpmValue = _ppmValues[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);

    _messageController =
        TextEditingController(text: widget.threshold.message ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primaryColor = Theme.of(context).primaryColor;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Validate against other thresholds to avoid conflicts
    bool hasConflict = false;
    for (int i = 0; i < widget.preferences.notificationThresholds.length; i++) {
      if (i != widget.thresholdIndex &&
          widget.preferences.notificationThresholds[i].co2Threshold ==
              _selectedPpmValue &&
          widget.preferences.notificationThresholds[i].co2Threshold != 0) {
        hasConflict = true;
        break;
      }
    }

    if (hasConflict) {
      if (mounted) {
        context.showSnackBar(
            'This PPM value is already used by another threshold');
      }
      return;
    }

    ref
        .read(notificationPreferencesProvider(widget.deviceId).notifier)
        .updateThreshold(
          widget.thresholdIndex,
          widget.threshold.copyWith(
            co2Threshold: _selectedPpmValue,
            message: _messageController.text.isEmpty
                ? null
                : _messageController.text,
          ),
        );

    if (mounted) {
      Navigator.pop(context);
      context.showSnackBar('Threshold updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenHeight * 0.7, // Taller to accommodate both inputs
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
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
                  'Edit Alert Threshold',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 24),

                // PPM Picker Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'CO₂ Threshold',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 150,
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
                            final isSelected = value == _selectedPpmValue;
                            return Center(
                              child: Text(
                                '$value ppm',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? _primaryColor
                                      : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedPpmValue = _ppmValues[index];
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // Message Input Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.message, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Custom Message (Optional)',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onChanged: (value) {
                          setState(() {});
                        },
                        onTapOutside: (event) => _focusNode.unfocus(),
                        decoration: InputDecoration(
                          hintText: 'e.g., High CO₂ detected!',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _primaryColor,
                              width: 2,
                            ),
                          ),
                          suffixIcon: _messageController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _messageController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        maxLength: 100,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Save button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
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
          ),
        ],
      ),
    );
  }
}
