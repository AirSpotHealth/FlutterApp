import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceValueRefreshWidget extends ConsumerStatefulWidget {
  const DeviceValueRefreshWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceValueRefreshWidgetState();
}

class _DeviceValueRefreshWidgetState
    extends ConsumerState<DeviceValueRefreshWidget> {
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: ValueKey(isRefreshing),
      icon: isRefreshing
          ? AnimateIcon(
              onTap: () {},
              iconType: IconType.continueAnimation,
              animateIcon: AnimateIcons.refresh,
              height: 24,
              width: 24,
            )
          : AnimateIcon(
              onTap: () {},
              iconType: IconType.onlyIcon,
              animateIcon: AnimateIcons.refresh,
              height: 24,
              width: 24,
            ),
      onPressed: _refreshValue,
    );
  }

  void _refreshValue() {
    if (isRefreshing) {
      return;
    }

    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.refreshCO2());
    setState(() {
      isRefreshing = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isRefreshing = false;
      });
    });
  }
}
