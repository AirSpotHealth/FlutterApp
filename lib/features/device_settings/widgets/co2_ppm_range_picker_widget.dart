import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/delayed_function_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class Co2PpmRangePickerWidget extends ConsumerWidget {
  const Co2PpmRangePickerWidget({required this.deviceId, super.key});

  static const labelValues = <int>[400, 4000];

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));
    return SfRangeSlider(
      max: 4000,
      min: 400,
      values: SfRangeValues(
        deviceSettings.greenUpperLimit.toDouble(),
        deviceSettings.yellowUpperLimit.toDouble(),
      ),
      onChangeEnd: (value) {
        DelayedFunctionCaller().call(() {
          ref
              .read(bleDeviceCommunicationProvider(deviceId).notifier)
              .sendCommand(deviceSettings.thresholdsCmd);
        });
      },
      onChanged: (SfRangeValues values) {
        ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
              deviceSettings.copyWith(
                thresholds: DeviceThresholds(
                  greenUpperLimit: values.start.toInt(),
                  yellowUpperLimit: values.end.toInt(),
                ),
              ),
            );
      },
      showLabels: true,
      interval: 400,
      minorTicksPerInterval: 1,
      stepSize: 50,
      showTicks: true,
      shouldAlwaysShowTooltip: true,
      enableTooltip: true,
      labelFormatterCallback: (dynamic actualValue, String formattedText) {
        return labelValues.contains(actualValue)
            ? actualValue.toInt().toString()
            : '';
      },
      tooltipShape: const _CustomTooltipShape(
          AppColors.brandColorGreen, AppColors.brandColorAmber),
      thumbShape: const _ThumbShape(
          AppColors.brandColorGreen, AppColors.brandColorAmber),
      overlayShape: const _OverlayShape(
          AppColors.brandColorGreen, AppColors.brandColorAmber),
      trackShape: _TrackShape(LinearGradient(
        colors: const <Color>[
          AppColors.brandColorGreen,
          AppColors.brandColorAmber,
          AppColors.brandColorRed
        ],
        stops: <double>[
          0.0,
          deviceSettings.greenUpperLimit / 4000,
          deviceSettings.yellowUpperLimit / 4000,
        ],
      )),
    );
  }
}

class _CustomTooltipShape extends SfTooltipShape {
  const _CustomTooltipShape(this.leftThumbColor, this.rightThumbColor);

  final Color leftThumbColor;
  final Color rightThumbColor;

  @override
  void paint(
    PaintingContext context,
    Offset thumbCenter,
    Offset offset,
    TextPainter textPainter, {
    required RenderBox parentBox,
    required SfSliderThemeData sliderThemeData,
    required Paint paint,
    required Animation<double> animation,
    required Rect trackRect,
  }) {
    textPainter.text = TextSpan(
      text: textPainter.text?.toPlainText(),
      style: textPainter.text?.style?.copyWith(
        color: Colors.black,
        fontSize: 12,
      ),
    );

    textPainter.paint(
        context.canvas,
        Offset(thumbCenter.dx - textPainter.width / 2,
            thumbCenter.dy - 24 - textPainter.height / 2));
  }
}

class _ThumbShape extends SfThumbShape {
  const _ThumbShape(this.leftThumbColor, this.rightThumbColor);

  final Color leftThumbColor;
  final Color rightThumbColor;

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    super.paint(context, center,
        parentBox: parentBox,
        child: child,
        themeData: themeData.copyWith(thumbColor: Colors.white),
        currentValues: currentValues,
        paint: paint,
        enableAnimation: enableAnimation,
        textDirection: textDirection,
        thumb: thumb);

    context.canvas.drawCircle(
        center,
        getPreferredSize(themeData).width / 2,
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..color = thumb == SfThumb.start ? leftThumbColor : rightThumbColor);
  }
}

class _OverlayShape extends SfOverlayShape {
  const _OverlayShape(this.leftThumbColor, this.rightThumbColor);

  final Color leftThumbColor;
  final Color rightThumbColor;

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> animation,
      required SfThumb? thumb}) {
    final double radius = getPreferredSize(themeData).width / 2;
    final Tween<double> tween = Tween<double>(begin: 0.0, end: radius);

    context.canvas.drawCircle(
        center,
        tween.evaluate(animation),
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 0
          ..color = (thumb == SfThumb.start ? leftThumbColor : rightThumbColor)
              .withValues(alpha: 0.12));
  }
}

class _TrackShape extends SfTrackShape {
  const _TrackShape(this.gradient);

  final Gradient gradient;

  @override
  void paint(PaintingContext context, Offset offset, Offset? thumbCenter,
      Offset? startThumbCenter, Offset? endThumbCenter,
      {required RenderBox parentBox,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Animation<double> enableAnimation,
      required Paint? inactivePaint,
      required Paint? activePaint,
      required TextDirection textDirection}) {
    final Radius radius = Radius.circular(themeData.trackCornerRadius!);
    final Rect actualTrackRect = getPreferredRect(parentBox, themeData, offset);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0
      ..color = themeData.inactiveTrackColor!;

    // Drawing active track.
    Rect trackRect = Rect.fromLTRB(
        24, actualTrackRect.top, actualTrackRect.right, actualTrackRect.bottom);
    paint.shader = gradient.createShader(trackRect);
    final RRect centerRRect = RRect.fromRectAndCorners(trackRect,
        topLeft: radius,
        bottomLeft: radius,
        topRight: radius,
        bottomRight: radius);
    context.canvas.drawRRect(centerRRect, paint);
  }
}
