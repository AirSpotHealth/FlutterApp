import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A robust custom bottom picker that can display a scrollable list of items
/// for selection with various customization options.
class CustomBottomPicker<T> extends StatefulWidget {
  /// Creates a custom bottom picker with enhanced UX and customizability.
  ///
  /// The [items] must not be null and must contain at least one item.
  /// The [onSubmit] callback is required to handle the selected item.
  const CustomBottomPicker({
    super.key,
    required this.items,
    required this.onSubmit,
    required this.itemBuilder,
    this.title,
    this.initialIndex = 0,
    this.itemHeight = 50.0,
    this.visibleItemCount = 5,
    this.submitButtonText = 'Submit',
    this.dismissable = true,
    this.hapticFeedback = true,
    this.selectedItemDecoration,
    this.pickerHeight,
    this.backgroundColor,
    this.submitButtonColor,
    this.submitButtonTextStyle,
    this.theme,
  });

  /// The list of items to display for selection.
  final List<T> items;

  /// The callback that is called when an item is selected and submitted.
  final Function(T selected) onSubmit;

  /// A builder function that takes an item and a boolean indicating whether
  /// the item is currently selected and returns a widget to display for that item.
  final Widget Function(T item, bool isSelected) itemBuilder;

  /// The initial index of the selected item. Defaults to 0.
  final int initialIndex;

  /// The title to display at the top of the picker.
  final Widget? title;

  /// The height of each item in the picker. Defaults to 50.0.
  final double itemHeight;

  /// The number of items visible in the picker at once. Defaults to 5.
  final int visibleItemCount;

  /// The text to display on the submit button. Defaults to 'Submit'.
  final String submitButtonText;

  /// Whether the picker can be dismissed by tapping outside of it. Defaults to true.
  final bool dismissable;

  /// Whether to use haptic feedback when the selected item changes. Defaults to true.
  final bool hapticFeedback;

  /// Optional decoration for the selected item.
  final BoxDecoration? selectedItemDecoration;

  /// Optional height for the entire picker.
  final double? pickerHeight;

  /// Optional background color for the picker.
  final Color? backgroundColor;

  /// Optional color for the submit button.
  final Color? submitButtonColor;

  /// Optional text style for the submit button.
  final TextStyle? submitButtonTextStyle;

  /// Optional theme for the picker.
  final ThemeData? theme;

  /// Shows the picker at the bottom of the screen.
  static Future<void> show<T>({
    required BuildContext context,
    required List<T> items,
    required Function(T selected) onSubmit,
    required Widget Function(T item, bool isSelected) itemBuilder,
    Widget? title,
    int initialIndex = 0,
    double itemHeight = 50.0,
    int visibleItemCount = 5,
    String submitButtonText = 'Submit',
    bool dismissable = true,
    bool hapticFeedback = true,
    BoxDecoration? selectedItemDecoration,
    double? pickerHeight,
    Color? backgroundColor,
    Color? submitButtonColor,
    TextStyle? submitButtonTextStyle,
    ThemeData? theme,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: dismissable,
      enableDrag: dismissable,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Theme(
          data: theme ?? Theme.of(context),
          child: CustomBottomPicker<T>(
            items: items,
            onSubmit: onSubmit,
            itemBuilder: itemBuilder,
            title: title,
            initialIndex: initialIndex,
            itemHeight: itemHeight,
            visibleItemCount: visibleItemCount,
            submitButtonText: submitButtonText,
            dismissable: dismissable,
            hapticFeedback: hapticFeedback,
            selectedItemDecoration: selectedItemDecoration,
            pickerHeight: pickerHeight,
            backgroundColor: backgroundColor,
            submitButtonColor: submitButtonColor,
            submitButtonTextStyle: submitButtonTextStyle,
            theme: theme,
          ),
        );
      },
    );
  }

  /// Shows a picker for selecting a numeric value from a range
  static Future<void> showNumeric({
    required BuildContext context,
    required int min,
    required int max,
    required Function(int) onSubmit,
    int? initialValue,
    int step = 1,
    String title = 'Select a value',
    String submitButtonText = 'Confirm',
    String? suffix,
    Color? selectedTextColor,
    double fontSize = 18.0,
  }) {
    final values =
        List.generate((max - min) ~/ step + 1, (i) => min + i * step);

    int initialIndex = 0;
    if (initialValue != null) {
      initialIndex = values.indexOf(initialValue);
      if (initialIndex == -1) {
        // Find closest value
        initialIndex = values.indexWhere((value) => value > initialValue) - 1;
        initialIndex = initialIndex.clamp(0, values.length - 1);
      }
    }

    return CustomBottomPicker.show<int>(
      context: context,
      items: values,
      initialIndex: initialIndex,
      itemBuilder: (item, isSelected) => Center(
        child: Text(
          suffix != null ? '$item $suffix' : '$item',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? selectedTextColor ?? Theme.of(context).primaryColor
                : null,
          ),
        ),
      ),
      onSubmit: onSubmit,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      submitButtonText: submitButtonText,
    );
  }

  /// Shows a time picker with hours and minutes
  static Future<void> showTimePicker({
    required BuildContext context,
    required Function(TimeOfDay) onSubmit,
    TimeOfDay? initialTime,
    String title = 'Select Time',
    String submitButtonText = 'Confirm',
    bool use24HourFormat = false,
    Color? selectedTextColor,
    double fontSize = 18.0,
  }) {
    final initialTimeValue = initialTime ?? TimeOfDay.now();

    // Create lists for hours and minutes
    final List<int> hours = use24HourFormat
        ? List.generate(24, (i) => i) // 0-23 for 24-hour format
        : List.generate(12, (i) => i + 1); // 1-12 for 12-hour format

    final List<int> minutes = List.generate(60, (i) => i);
    final List<String> amPm = ['AM', 'PM'];

    // Find initial indices
    final initialHourIndex = hours.indexOf(use24HourFormat
        ? initialTimeValue.hour
        : (initialTimeValue.hourOfPeriod == 0
            ? 12
            : initialTimeValue.hourOfPeriod));
    final initialMinuteIndex = minutes.indexOf(initialTimeValue.minute);
    final initialAmPmIndex = initialTimeValue.period == DayPeriod.am ? 0 : 1;

    // Use separate controllers for hour, minute, and AM/PM
    final hourController =
        FixedExtentScrollController(initialItem: initialHourIndex);
    final minuteController =
        FixedExtentScrollController(initialItem: initialMinuteIndex);
    final amPmController =
        FixedExtentScrollController(initialItem: initialAmPmIndex);

    // Build a stateful time picker
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          int selectedHourIndex = initialHourIndex;
          int selectedMinuteIndex = initialMinuteIndex;
          int selectedAmPmIndex = initialAmPmIndex;

          void updateSelectedTime(int hourIdx, int minuteIdx, int amPmIdx) {
            setState(() {
              selectedHourIndex = hourIdx;
              selectedMinuteIndex = minuteIdx;
              selectedAmPmIndex = amPmIdx;
            });
          }

          return Container(
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header with handle and close button
                Stack(
                  children: [
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
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.neutralGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Time pickers - horizontally arranged
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hours
                      SizedBox(
                        width: 70,
                        child: _buildWheelPicker(
                          context: context,
                          items: hours,
                          controller: hourController,
                          onSelectedItemChanged: (index) {
                            updateSelectedTime(
                                index, selectedMinuteIndex, selectedAmPmIndex);
                          },
                          selectedTextColor: selectedTextColor ??
                              Theme.of(context).primaryColor,
                          itemBuilder: (item, isSelected) => Center(
                            child: Text(
                              item.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? selectedTextColor ??
                                        Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Text(':',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),

                      // Minutes
                      SizedBox(
                        width: 70,
                        child: _buildWheelPicker(
                          context: context,
                          items: minutes,
                          controller: minuteController,
                          onSelectedItemChanged: (index) {
                            updateSelectedTime(
                                selectedHourIndex, index, selectedAmPmIndex);
                          },
                          selectedTextColor: selectedTextColor ??
                              Theme.of(context).primaryColor,
                          itemBuilder: (item, isSelected) => Center(
                            child: Text(
                              item.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? selectedTextColor ??
                                        Theme.of(context).primaryColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // AM/PM (only show if not using 24-hour format)
                      if (!use24HourFormat) ...[
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 70,
                          child: _buildWheelPicker(
                            context: context,
                            items: amPm,
                            controller: amPmController,
                            onSelectedItemChanged: (index) {
                              updateSelectedTime(selectedHourIndex,
                                  selectedMinuteIndex, index);
                            },
                            selectedTextColor: selectedTextColor ??
                                Theme.of(context).primaryColor,
                            itemBuilder: (item, isSelected) => Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? selectedTextColor ??
                                          Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Convert selected indices back to TimeOfDay
                        int hour = hours[selectedHourIndex];
                        final minute = minutes[selectedMinuteIndex];

                        // Handle 12-hour format conversion
                        if (!use24HourFormat) {
                          final isPm = amPm[selectedAmPmIndex] == 'PM';
                          if (isPm && hour < 12) {
                            hour += 12;
                          } else if (!isPm && hour == 12) {
                            hour = 0;
                          }
                        }

                        Navigator.of(context).pop();
                        onSubmit(TimeOfDay(hour: hour, minute: minute));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        submitButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom padding for safe area
                SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16.0),
              ],
            ),
          );
        });
      },
    );
  }

  // Helper method to build a wheel picker
  static Widget _buildWheelPicker<T>({
    required BuildContext context,
    required List<T> items,
    required FixedExtentScrollController controller,
    required Function(int) onSelectedItemChanged,
    required Widget Function(T item, bool isSelected) itemBuilder,
    Color? selectedTextColor,
    double itemHeight = 50.0,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Not used here but could be used for additional behaviors
        return false;
      },
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: itemHeight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Wheel
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: itemHeight,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = controller.selectedItem == index;
                return Center(
                  child: itemBuilder(items[index], isSelected),
                );
              },
            ),
            onSelectedItemChanged: onSelectedItemChanged,
          ),
        ],
      ),
    );
  }

  @override
  State<CustomBottomPicker<T>> createState() => _CustomBottomPickerState<T>();
}

class _CustomBottomPickerState<T> extends State<CustomBottomPicker<T>> {
  late FixedExtentScrollController _scrollController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate total picker height
    final totalItemHeight = widget.itemHeight * widget.visibleItemCount;
    final titleHeight = widget.title != null ? 60.0 : 20.0;
    final submitButtonHeight = 60.0;
    final calculatedPickerHeight = titleHeight +
        totalItemHeight +
        submitButtonHeight +
        40.0; // Extra padding

    final pickerHeight = widget.pickerHeight ??
        calculatedPickerHeight.clamp(0.0, screenHeight * 0.9);

    return Container(
      height: pickerHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle and close button
          _buildHeader(context),

          // Title
          if (widget.title != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: widget.title!,
            ),
          ],

          // Picker wheel
          Expanded(
            child: _buildPickerWheel(context),
          ),

          // Submit button
          _buildSubmitButton(context),

          // Bottom padding for safe area
          SizedBox(
              height: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 16.0),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Handle bar
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
        if (widget.dismissable)
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.neutralGrey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPickerWheel(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          setState(() {
            _selectedIndex = _scrollController.selectedItem;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: widget.selectedItemDecoration ??
                  BoxDecoration(
                    color: Colors.grey.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
            ),
          ),

          // Wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: widget.itemHeight,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final isSelected = index == _selectedIndex;
                return Center(
                  child: widget.itemBuilder(widget.items[index], isSelected),
                );
              },
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSubmit(widget.items[_selectedIndex]);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.submitButtonColor ?? Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.submitButtonText,
            style: widget.submitButtonTextStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
