import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:airspothealth/core/providers/gps_state_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final servicesStatusProvider =
    NotifierProvider<_ServicesStatusNotifier, Map<Service, bool>>(
        _ServicesStatusNotifier.new);

class _ServicesStatusNotifier extends Notifier<Map<Service, bool>> {
  @override
  Map<Service, bool> build() {
    final bluetoothEnabled =
        ref.watch(bluetoothStateProvider) == BluetoothAdapterState.on;

    final locationEnabled =
        ref.watch(gpsStateProvider) == ServiceStatus.enabled;

    return {
      Service.bluetoothService: bluetoothEnabled,
      Service.locationService: locationEnabled,
    };
  }
}

enum Service {
  bluetoothService,
  locationService,
}
