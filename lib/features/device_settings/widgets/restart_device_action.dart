import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/app_action_sheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';

/// UI for a device reboot request. A successful write is not reboot confirmation.
class RestartDeviceAction extends StatefulWidget {
  const RestartDeviceAction({required this.sendRestart, super.key});

  final Future<bool> Function() sendRestart;

  @override
  State<RestartDeviceAction> createState() => _RestartDeviceActionState();
}

class _RestartDeviceActionState extends State<RestartDeviceAction> {
  bool busy = false;
  bool sending = false;

  Future<void> restart() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) => AppActionSheet(
          asset: Assets.deviceUpdate,
          title: 'Restart device?',
          description:
              'Restarts the device and initializes its sensors again. Your saved settings, calibration and readings are kept. Any calibration in progress will stop.\n\n'
              'Bluetooth will disconnect briefly. Wait for the device to start, then reconnect if needed.',
          actions: [
            Button(
                label: 'Restart',
                onPressed: () => Navigator.pop(context, true)),
            Button(
                label: 'Cancel',
                type: ButtonType.outlined,
                onPressed: () => Navigator.pop(context, false)),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => sending = true);
      final sent =
          await widget.sendRestart().timeout(const Duration(seconds: 10));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sent
            ? 'Restart requested. Wait for the device to start, then reconnect if needed.'
            : 'Could not send the restart request. Connect to the device and finish any firmware update before trying again.'),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Restart could not be confirmed. Check whether the device reconnects before trying again.',
          ),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SettingItemWidget(
        item: SettingItem(
          title: sending ? 'Requesting restart…' : 'Restart Device',
          assetIcon: Assets.deviceUpdate,
          suffixWidget: sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const SizedBox(),
        ),
        onTap: () {
          if (!busy) restart();
        },
      );
}
