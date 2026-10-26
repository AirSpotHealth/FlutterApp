import 'dart:async';
import 'package:airspothealth/core/utils/user_facing_error.dart';
import 'slim_dfu_service.dart';
import 'slim_update_verification.dart';

UserFacingError firmwareUpdateError(Object error,
    {bool slim = false, bool installationConfirmed = false}) {
  if (error is UserFacingError) return error;
  if (installationConfirmed || error is SlimUpdateHealthException) {
    return UserFacingError('Update installed — reconnect needed',
        'The firmware was installed, but we could not finish checking your device. Keep it powered, reconnect, and check that live readings return. If they do not, contact support.',
        cause: error, retryable: false);
  }
  if (error is SlimDfuException) {
    return switch (error.failure) {
      SlimDfuFailure.rolledBack => UserFacingError('Previous firmware restored',
          'Slim could not complete its startup checks and returned to its previous firmware. Reconnect and check your readings. Contact support before trying this update again.',
          cause: error, retryable: false),
      SlimDfuFailure.previousImageActive => UserFacingError(
          'Update not installed',
          'Slim is still using its previous firmware. Charge it, reconnect, and try the update again.',
          cause: error),
      _ => UserFacingError('Update could not be confirmed',
          'Keep Slim powered and reconnect to check its firmware version and live readings. If it does not reconnect, contact support.',
          cause: error, retryable: false),
    };
  }
  final detail = error.toString().toLowerCase();
  // Slim rejects writes with MCUmgr EBADSTATE (6) if battery voltage is low
  // OR cannot be read. The native plugin currently exposes localized strings.
  // Do not classify an arbitrary "6" or another device's bad state as battery.
  if (slim &&
      (detail.contains('bad state (rc: 6)') ||
          detail.trim() == 'bad state' ||
          detail.contains('mgmt_err_ebadstate') ||
          detail.contains('low battery') ||
          detail.contains('battery too low'))) {
    return UserFacingError('Charge Slim before updating',
        'Slim could not confirm enough battery power to start the update. Place it on its charging pad and let it charge, then reconnect and try again. If this keeps happening after charging, contact support.',
        cause: error);
  }
  if (error is FormatException) {
    return UserFacingError('Firmware file cannot be used',
        'Choose a compatible firmware file for this device, or download the update again from the app.',
        cause: error);
  }
  if (error is TimeoutException ||
      detail.contains('timed out') ||
      detail.contains('timeout')) {
    return UserFacingError('Update connection timed out',
        'Keep the device powered and close to your phone. Reconnect and check its firmware version before trying again.',
        cause: error);
  }
  if (detail.contains('connect to the device') ||
      detail.contains('disconnected')) {
    return UserFacingError('Connect your device',
        'Keep the device close to your phone and reconnect before starting the update.',
        cause: error);
  }
  return UserFacingError('Update could not be completed',
      'Keep the device powered and close to your phone. Check your internet and Bluetooth connections, then reconnect and try again. If it still fails, contact support.',
      cause: error);
}
