import 'package:airspothealth/core/utils/permission_utils.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/add_device/providers/ble_search_results_provider.dart';
import 'package:airspothealth/features/add_device/widgets/ble_new_device_item.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends ConsumerState<AddDevicePage>
    with WidgetsBindingObserver {
  bool _navigatedToSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('AppLifecycleState: $state');
    if (state == AppLifecycleState.resumed && _navigatedToSettings) {
      _requestPermissions();
      _navigatedToSettings = false;
    }
  }

  void _requestPermissions() {
    PermissionUtils.requestPermissions().then((deniedPermissions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (deniedPermissions?.isNotEmpty == true) {
          _showPermissionDeniedDialog(deniedPermissions!);
          return;
        }
        ref.read(bluetoothSearchResultsProvider.notifier).startScan();
      });
    });
  }

  void _showPermissionDeniedDialog(String deniedPermissions) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return AppBottomSheet(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                const Text(
                  'Please enable the following permissions to continue:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  deniedPermissions,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Button(
                  label: 'Open Settings',
                  onPressed: () {
                    _navigatedToSettings = true;
                    openAppSettings();
                    context.pop(true);
                  },
                ),
              ],
            ),
          ));
        }).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigatedToSettings == false) {
          context.pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final (bool isScanning, List<BluetoothDevice> devices) =
        ref.watch(bluetoothSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.devices.addDeviceTitle),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.read(bluetoothSearchResultsProvider.notifier).startScan();

          return Future.value();
        },
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            if (isScanning)
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CupertinoActivityIndicator(),
                ),
              ),
            if (devices.isEmpty && !isScanning)
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.bluetooth.noDevicesFoundSwipeRefresh,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: devices.length,
                primary: true,
                physics: const ClampingScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    BleNewDeviceItem(device: devices[index]),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
