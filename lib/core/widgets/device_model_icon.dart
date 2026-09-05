import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Circular icon that visually distinguishes AirSpot device models.
/// Screen → monitor icon, Slim → sensors icon.
class DeviceModelIcon extends StatelessWidget {
  const DeviceModelIcon({
    required this.model,
    this.size = 22,
    super.key,
  });

  final DeviceModel model;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isSlim = model == DeviceModel.airspotSlim;
    return Container(
      width: size * 2,
      height: size * 2,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSlim ? Icons.rectangle_rounded : Icons.phone_android,
        size: size,
        color: AppColors.primaryColor,
      ),
    );
  }
}
