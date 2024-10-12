import 'package:airspothealth/core/utils/assets.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 100,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.logo,
      width: width,
    );
  }
}
