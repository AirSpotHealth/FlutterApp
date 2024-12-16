import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A custom button widget that supports loading and disabled state
class Button extends StatelessWidget {
  /// Constructor
  const Button({
    required this.onPressed,
    this.label,
    this.child,
    super.key,
    this.disabled = false,
    this.loading = false,
    this.type = ButtonType.primary,
    this.prefixIcon,
    this.suffixIcon,
    this.wrapWidth = false,
    this.height,
    this.backgroundColor,
    this.textColor,
  });

  /// callback when the button is pressed
  final VoidCallback? onPressed;

  /// label of the button
  final String? label;

  /// child widget of the button
  final Widget? child;

  /// disabled state of the button
  final bool disabled;

  /// loading state of the button
  final bool loading;

  /// button type
  final ButtonType type;

  /// prefix icon of the button
  final Widget? prefixIcon;

  /// suffix icon of the button
  final Widget? suffixIcon;

  /// whether the button should wrap its width or take the full width
  final bool wrapWidth;

  /// height of the button
  final double? height;

  /// background color of the button
  final Color? backgroundColor;

  /// text color of the button
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final button = switch (type) {
      ButtonType.primary => _buildPrimaryButton(context),
      ButtonType.outlined => _buildOutlinedButton(context),
      ButtonType.text => _buildTextButton(context),
    };

    return SizedBox(
      width: wrapWidth ? null : double.infinity,
      height: height,
      child: button,
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled || loading ? null : onPressed,
      style: context.theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor:
            WidgetStateProperty.all(backgroundColor ?? AppColors.primaryColor),
      ),
      child: loading
          ? const CupertinoActivityIndicator()
          : _buildButtonContent(context, textColor ?? AppColors.textOnPrimary),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: disabled || loading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        side: WidgetStateProperty.all(
          BorderSide(color: backgroundColor ?? AppColors.neutralGreyLight),
        ),
        foregroundColor: WidgetStateProperty.all(disabled || loading
            ? AppColors.neutralGrey
            : AppColors.textPrimary),
      ),
      child: loading
          ? const CupertinoActivityIndicator()
          : _buildButtonContent(context, textColor ?? AppColors.textPrimary),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: disabled || loading ? null : onPressed,
      child: loading
          ? const CupertinoActivityIndicator()
          : _buildButtonContent(context, textColor ?? AppColors.textPrimary),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) prefixIcon!,
        if (prefixIcon != null) const SizedBox(width: 6),
        if (child != null)
          child!
        else
          Flexible(
            child: Text(
              label ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (suffixIcon != null) const SizedBox(width: 6),
        if (suffixIcon != null) suffixIcon!,
      ],
    );
  }
}

/// button type enum
enum ButtonType {
  /// primary button
  primary,

  /// outlined button
  outlined,

  /// text button
  text,
}
