import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceVersionUpdateWidget extends ConsumerStatefulWidget {
  const DeviceVersionUpdateWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceVersionUpdateWidgetState();
}

class _DeviceVersionUpdateWidgetState
    extends ConsumerState<DeviceVersionUpdateWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firmwareRemoteVersionProvider.notifier).fetchRemoteVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(firmwareRemoteVersionProvider, (oldState, newState) {
      if (newState is AsyncError && oldState is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch remote version, ${newState.error}'),
          ),
        );
      }
    });

    final AsyncValue<String> deviceVersion =
        ref.watch(firmwareRemoteVersionProvider);

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text('Latest Version: '),
            const Spacer(),
            deviceVersion.when(
              data: (version) => Text(version),
              loading: () => const CircularProgressIndicator.adaptive(),
              error: (error, stackTrace) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref
                      .read(firmwareRemoteVersionProvider.notifier)
                      .fetchRemoteVersion();
                },
              ),
            ),
          ],
        ));
  }
}
