// an app bar with the app logo at center
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/bluetooth_state_widget.dart';
import 'package:flutter/material.dart';

class AirspotBar extends StatelessWidget implements PreferredSizeWidget {
  const AirspotBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      title: const Padding(padding: EdgeInsets.only(top: 12), child: AppLogo()),
      centerTitle: true,
      actions: const [BluetoothStateWidget()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
