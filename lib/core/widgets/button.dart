import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A custom button widget that supports loading and disabled state
class Button extends StatelessWidget {
  /// Constructor
  const Button({
    required this.onPressed,
    required this.label,
    super.key,
    this.disabled = false,
    this.loading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.suffixIcon,
    this.debounceDurationMillis,
    this.wrapWidth = false,
    this.height,
    this.color,
  }) : assert(
          type != ButtonType.icon || icon != null,
          'Icon must be provided for icon button',
        );

  /// callback when the button is pressed
  final VoidCallback? onPressed;

  /// label of the button
  final String label;

  /// disabled state of the button
  final bool disabled;

  /// loading state of the button
  final bool loading;

  /// button type
  final ButtonType type;

  /// icon of the button
  final IconData? icon;

  /// suffix icon of the button
  final IconData? suffixIcon;

  /// debounce duration
  final int? debounceDurationMillis;

  /// whether the button should wrap its width or take the full width
  final bool wrapWidth;

  /// height of the button
  final double? height;

  /// background color of the button
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final button = switch (type) {
      ButtonType.primary => _buildPrimaryButton(context),
      ButtonType.secondary => _buildSecondaryButton(context),
      ButtonType.text => _buildTextButton(),
      ButtonType.outlined => _buildOutlinedButton(),
      ButtonType.icon => _buildIconButton(context),
    };

    return SizedBox(
      width: wrapWidth ? null : double.infinity,
      height: height,
      child: button,
    );
  }

  Widget _buildIconButton(BuildContext context) => TextButton.icon(
        icon: loading
            ? null
            : Icon(
                icon,
                color: context.textTheme.labelLarge?.color,
                size: 20,
              ),
        onPressed: disabled || loading ? null : _onButtonPressed,
        label: loading
            ? CupertinoActivityIndicator()
            : Text(label, style: context.textTheme.labelLarge),
      );

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled || loading ? null : _onButtonPressed,
      style: context.theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor:
            WidgetStateProperty.all(color ?? AppColors.primaryColor),
      ),
      child: loading
          ? const CupertinoActivityIndicator()
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (suffixIcon != null) const SizedBox(width: 8),
                if (suffixIcon != null)
                  Icon(suffixIcon, color: AppColors.textOnPrimary),
              ],
            ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return FilledButton(
      onPressed: disabled || loading ? null : _onButtonPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color?.withOpacity(0.2) ?? AppColors.primaryColorLight,
      ),
      child: loading
          ? const CupertinoActivityIndicator()
          : Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: color ?? AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _buildTextButton() => TextButton(
        onPressed: disabled || loading ? null : _onButtonPressed,
        child: loading
            ? const CupertinoActivityIndicator()
            : Text(label, textAlign: TextAlign.center),
      );

  Widget _buildOutlinedButton() => OutlinedButton(
        onPressed: disabled || loading ? null : _onButtonPressed,
        child: loading
            ? const CupertinoActivityIndicator()
            : Text(label, textAlign: TextAlign.center),
      );

  void _onButtonPressed() {
    if (!loading) onPressed?.call();
  }
}

/// button type enum
enum ButtonType {
  /// primary button
  primary,

  /// secondary button
  secondary,

  /// text button
  text,

  /// outlined button
  outlined,

  /// icon button
  icon,
}
