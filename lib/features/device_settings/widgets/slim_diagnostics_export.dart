import 'dart:convert';
import 'dart:typed_data';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_diagnostics.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SlimDiagnosticsExport extends StatefulWidget {
  const SlimDiagnosticsExport({required this.deviceId, super.key});
  final String deviceId;
  @override
  State<SlimDiagnosticsExport> createState() => _SlimDiagnosticsExportState();
}

class _SlimDiagnosticsExportState extends State<SlimDiagnosticsExport> {
  bool busy = false;
  String? error;

  Future<void> export() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final communicator =
          BleCommunicatorService.instance.communicator(widget.deviceId);
      if (communicator.isSuspended || !await communicator.initialize()) {
        throw StateError(
            'Connect to Slim and finish any firmware update first.');
      }
      final json = await SlimDiagnostics.collect(
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
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : export,
            icon: const Icon(Icons.download_outlined),
            label: Text(busy ? 'Reading diagnostics…' : 'Export diagnostics'),
          ),
          const Text(
              'Read recent device faults and restart events to share with support.'),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                  liveRegion: true,
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error))),
            ),
        ],
      );
}
