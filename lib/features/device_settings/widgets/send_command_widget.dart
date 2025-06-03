import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SendCommandWidget extends ConsumerWidget {
  const SendCommandWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: t.deviceSettings.sendCommand,
        leadingWidget: const Icon(Icons.send),
        suffixWidget: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SendCommandSheet(deviceId),
          showDragHandle: true,
          constraints: BoxConstraints.tight(
            const Size.fromHeight(500),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }
}

class SendCommandSheet extends ConsumerStatefulWidget {
  const SendCommandSheet(this.deviceId, {super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SendCommandSheetState();
}

class _SendCommandSheetState extends ConsumerState<SendCommandSheet> {
  String get deviceId => widget.deviceId;

  final TextEditingController _commandController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final device = ref.read(bleDeviceProvider(deviceId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(t.deviceSettings
              .sendCommandTo(deviceName: device.alias ?? device.name)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commandController,
            decoration: InputDecoration(
              labelText: t.deviceSettings.command,
              hintText: t.deviceSettings.enterCommand,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final String command = _commandController.text;
                // Send command

                if (command.isEmpty) {
                  return;
                }

                // check if command doesnot start with 0x
                if (!command.startsWith('0x')) {
                  return;
                }

                ref
                    .read(bleDeviceCommunicationProvider(deviceId).notifier)
                    .sendCommand(command.hexToBytes);
                _commandController.clear();
                context.pop();
              },
              child: Text(t.common.send),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
