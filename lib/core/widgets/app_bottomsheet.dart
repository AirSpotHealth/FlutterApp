import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet(
      {required this.child, this.canBeDismissed = true, super.key});

  final Widget child;

  final bool canBeDismissed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: child,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: SheetCloseButton(
                onPressed: () {
                  if (canBeDismissed) Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 18,
              top: 5,
              child: Container(
                height: 5,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.neutralGreyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// close button widget
/// This widget is used to show a close button with grey background and a dark grey cross icon
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({
    required this.onPressed,
    super.key,
  });

  /// onPressed callback
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey[200],
        child: const Icon(
          Icons.close,
          size: 18,
          color: AppColors.neutralGrey,
        ),
      ),
    );
  }
}
