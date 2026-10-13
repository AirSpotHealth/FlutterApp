import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/app_action_sheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/service/slim_diagnostics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class SlimDiagnosticsExport extends ConsumerStatefulWidget {
  const SlimDiagnosticsExport({required this.deviceId, super.key});
  final String deviceId;
  @override
  ConsumerState<SlimDiagnosticsExport> createState() =>
      _SlimDiagnosticsExportState();
}

class _SlimDiagnosticsExportState extends ConsumerState<SlimDiagnosticsExport> {
  Future<void> export() async {
    final communicator =
        BleCommunicatorService.instance.communicator(widget.deviceId);
    if (communicator.isSuspended || !await communicator.initialize()) {
      throw StateError('Connect to Slim and finish any firmware update first.');
    }
    if (!mounted) return;
    final json = await SlimDiagnostics.collect(
      device: ref.read(bleDeviceProvider(widget.deviceId)),
      connectedAtCollectionStart: communicator.device.isConnected,
      responses: communicator.dataStream,
      send: (frame) => communicator.sendCommand(frame),
    );
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(Uint8List.fromList(utf8.encode(json)),
            mimeType: 'application/json')
      ],
      fileNameOverrides: ['slim-diagnostics.json'],
      subject: 'AirSpot Slim diagnostics',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  @override
  Widget build(BuildContext context) => SettingItemWidget(
        item: SettingItem(
            title: 'Export Diagnostics',
            assetIcon: Assets.reportIssue,
            suffixWidget: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey)),
        onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.white,
            builder: (_) => DiagnosticsExportSheet(onExport: export)),
      );
}

class DiagnosticsExportSheet extends StatefulWidget {
  const DiagnosticsExportSheet({required this.onExport, super.key});
  final Future<void> Function() onExport;
  @override
  State<DiagnosticsExportSheet> createState() => _DiagnosticsExportSheetState();
}

class _DiagnosticsExportSheetState extends State<DiagnosticsExportSheet> {
  bool busy = false;
  String? error;
  Future<void> export() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onExport();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => error =
            'Couldn’t read diagnostics. Connect to this Slim, finish any firmware update, then try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !busy,
      child: AppActionSheet(
        asset: Assets.reportIssue,
        title: 'Device diagnostics',
        description:
            'Share recent sensor faults and restart events with AirSpot support. Keep your Slim connected while we collect the report.',
        canBeDismissed: !busy,
        details: error == null
            ? null
            : Semantics(
                liveRegion: true,
                child: Text(error!,
                    style: const TextStyle(color: AppColors.brandColorRed),
                    textAlign: TextAlign.center)),
        actions: [
          Button(
              label: busy ? 'Reading diagnostics…' : 'Export & Share',
              loading: busy,
              onPressed: export),
          Button(
              label: 'Cancel',
              type: ButtonType.outlined,
              disabled: busy,
              onPressed: () => Navigator.of(context).pop())
        ],
      ));
}
