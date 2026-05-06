import 'package:airspothealth/core/models/device_capabilities.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DeviceModelBadge extends StatelessWidget {
  const DeviceModelBadge({required this.capabilities, super.key});

  final DeviceCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final label = capabilities.hasScreen() ? 'AirSpot Screen' : 'AirSpot Slim';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neutralGreyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.neutralGreyDark,
        ),
      ),
    );
  }
}
