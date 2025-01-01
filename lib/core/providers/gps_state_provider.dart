import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final gpsStateProvider =
    NotifierProvider<_GpsStateNotifier, ServiceStatus>(_GpsStateNotifier.new);

class _GpsStateNotifier extends Notifier<ServiceStatus> {
  @override
  ServiceStatus build() {
    Geolocator.getServiceStatusStream().listen((status) {
      state = status;
    });

    Geolocator.isLocationServiceEnabled().then((enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = enabled ? ServiceStatus.enabled : ServiceStatus.disabled;
      });
    });

    return ServiceStatus.enabled;
  }
}
