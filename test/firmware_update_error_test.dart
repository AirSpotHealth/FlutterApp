import 'dart:async';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/user_facing_error.dart';
import 'package:airspothealth/features/device_settings/service/firmware_update_error.dart';
import 'package:airspothealth/features/device_settings/service/slim_dfu_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_update_verification.dart';
import 'package:airspothealth/features/device_settings/widgets/device_firmware_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Slim power rejection gives charging steps without a made-up percentage',
      () {
    for (final cause in [
      'Bad state (RC: 6)',
      'Bad state',
      PlatformException(code: 'update', message: 'Bad state (RC: 6)'),
      'MGMT_ERR_EBADSTATE',
      'Battery too low',
    ]) {
      final error = firmwareUpdateError(cause, slim: true);
      expect(error.title, 'Charge Slim before updating');
      expect(error.message, contains('charging pad'));
      expect(error.message, contains('could not confirm'));
      expect(error.message, isNot(contains('RC:')));
      expect(error.message, isNot(contains('%')));
      expect(error.cause, same(cause));
    }
  });
  test('unrelated errors do not become a battery diagnosis', () {
    for (final cause in [
      'error 6',
      'Connection error 6',
      'Bad state (RC: 16)'
    ]) {
      expect(firmwareUpdateError(cause, slim: true).title,
          isNot('Charge Slim before updating'));
    }
    expect(firmwareUpdateError('Bad state (RC: 6)').title,
        isNot('Charge Slim before updating'));
  });
  test('installed, rolled-back and uncertain outcomes stay distinct', () {
    expect(
        firmwareUpdateError(
                const SlimUpdateHealthException('0.21.0', null, false))
            .title,
        'Update installed — reconnect needed');
    expect(
        firmwareUpdateError(StateError('transport'),
                installationConfirmed: true)
            .title,
        'Update installed — reconnect needed');
    expect(
        firmwareUpdateError(const SlimDfuException(SlimDfuFailure.rolledBack))
            .title,
        'Previous firmware restored');
    expect(
        firmwareUpdateError(const SlimDfuException(SlimDfuFailure.unavailable))
            .title,
        'Update could not be confirmed');
    expect(
        firmwareUpdateError(const SlimDfuException(SlimDfuFailure.unavailable))
            .retryable,
        false);
    expect(
        firmwareUpdateError('Bad state (RC: 6)', slim: true).retryable, true);
    expect(
        firmwareUpdateError(TimeoutException('private transport details'))
            .message,
        isNot(contains('private')));
    expect(firmwareUpdateError(const FormatException('hash mismatch')).title,
        'Firmware file cannot be used');
  });
  test('safe customer wording does not expose arbitrary exceptions', () {
    expect(
        userErrorMessage(StateError('/private/file secret'),
            fallback: 'Try again.'),
        'Try again.');
    final failure = firmwareUpdateError('Bad state (RC: 6)', slim: true);
    expect(firmwareUpdateError(failure), same(failure));
  });
  testWidgets('low battery notice fits a narrow dialog with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.theme,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!),
        home: Scaffold(
            body: AlertDialog(
                scrollable: true,
                content: FirmwareUpdateFailureNotice(
                    error: firmwareUpdateError('Bad state (RC: 6)',
                        slim: true))))));
    await tester.pumpAndSettle();
    expect(find.text('Charge Slim before updating'), findsOneWidget);
    expect(find.textContaining('charging pad'), findsOneWidget);
    expect(find.textContaining('RC:'), findsNothing);
    expect(tester.takeException(), null);
  });
}
