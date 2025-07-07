import 'dart:async';

import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/providers/submission_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FactoryTestDevicesState {
  final List<FactoryTestDevice> devices;
  final List<FactoryTestDevice> scannedDevices;
  final bool isScanning;
  final String? error;
  final int maxConcurrentDevices;

  FactoryTestDevicesState({
    required this.devices,
    required this.scannedDevices,
    this.isScanning = false,
    this.error,
    this.maxConcurrentDevices = 4,
  });

  FactoryTestDevicesState copyWith({
    List<FactoryTestDevice>? devices,
    List<FactoryTestDevice>? scannedDevices,
    bool? isScanning,
    String? error,
    int? maxConcurrentDevices,
  }) {
    return FactoryTestDevicesState(
      devices: devices ?? this.devices,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      isScanning: isScanning ?? this.isScanning,
      error: error ?? this.error,
      maxConcurrentDevices: maxConcurrentDevices ?? this.maxConcurrentDevices,
    );
  }

  /// Get devices grouped by queue status
  List<FactoryTestDevice> get queuedDevices =>
      devices.where((d) => d.queueStatus == DeviceQueueStatus.queued).toList();

  List<FactoryTestDevice> get runningDevices =>
      devices.where((d) => d.queueStatus == DeviceQueueStatus.running).toList();

  List<FactoryTestDevice> get readyToSubmitDevices => devices
      .where((d) => d.queueStatus == DeviceQueueStatus.readyToSubmit)
      .toList();

  List<FactoryTestDevice> get completedDevices => devices
      .where((d) => d.queueStatus == DeviceQueueStatus.completed)
      .toList();

  List<FactoryTestDevice> get errorDevices =>
      devices.where((d) => d.queueStatus == DeviceQueueStatus.error).toList();

  /// Check if we can start more devices (ready to submit devices free up running slots)
  bool get canStartMoreDevices => runningDevices.length < maxConcurrentDevices;

  /// Get queue statistics for UI display
  String get queueSummary {
    final running = runningDevices.length;
    final queued = queuedDevices.length;
    final readyToSubmit = readyToSubmitDevices.length;
    final completed = completedDevices.length;

    if (running == 0 && queued == 0 && readyToSubmit == 0 && completed == 0) {
      return 'No devices';
    }

    List<String> parts = [];
    if (running > 0) parts.add('$running running');
    if (queued > 0) parts.add('$queued queued');
    if (readyToSubmit > 0) parts.add('$readyToSubmit ready');
    if (completed > 0) parts.add('$completed completed');

    return parts.join(' • ');
  }
}

final factoryTestDevicesProvider = NotifierProvider.autoDispose<
    FactoryTestDevicesNotifier,
    FactoryTestDevicesState>(FactoryTestDevicesNotifier.new);

class FactoryTestDevicesNotifier
    extends AutoDisposeNotifier<FactoryTestDevicesState> {
  final BLEService _bleService = BLEService.instance;

  @override
  FactoryTestDevicesState build() {
    _bleService.startScan();

    FlutterBluePlus.isScanning.listen((isScanning) {
      state = state.copyWith(isScanning: isScanning);
    });

    return FactoryTestDevicesState(devices: [], scannedDevices: []);
  }

  /// Start device scanning
  void startScanning() {
    if (state.isScanning) return;
    final devices = state.devices;

    state = state.copyWith(
      isScanning: true,
      error: null, // Clear any previous errors
      devices: devices,
      scannedDevices: [],
    );

    _bleService.startScan();

    // Use scan results with ScanResult to get RSSI
    FlutterBluePlus.scanResults.listen(
      (scanResults) {
        final factoryTestDevices = scanResults
            .where((scanResult) =>
                scanResult.device.advName.startsWith('AirSpot-'))
            .map((scanResult) => FactoryTestDevice(
                  deviceId: scanResult.device.remoteId.str,
                  name: scanResult.device.advName,
                  rssi: scanResult.rssi,
                  bluetoothDevice: scanResult.device,
                ))
            .toList();

        // Sort by RSSI (strongest signal first)
        factoryTestDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

        state = state.copyWith(
          scannedDevices: factoryTestDevices
              .where((device) =>
                  !state.devices.any((d) => d.deviceId == device.deviceId))
              .toList(),
        );
      },
      onError: (error) {
        debugPrint('Scan error: $error');
        state = state.copyWith(
          isScanning: false,
          error: 'Scan error: $error',
        );
      },
    );
  }

  /// Stop device scanning
  void stopScanning({bool clearDevices = false}) {
    if (!state.isScanning) return;

    _bleService.stopScan();

    state = state.copyWith(
      isScanning: false,
      devices: clearDevices ? [] : state.devices,
      scannedDevices: [],
    );
  }

  void addDevice(String deviceId) {
    final device = state.scannedDevices
        .firstWhereOrNull((device) => device.deviceId == deviceId);

    if (device == null) {
      return;
    }

    // Check if device is already added
    if (state.devices.any((d) => d.deviceId == deviceId)) {
      return;
    }

    // Add device to queue with timestamp
    final deviceWithQueue = device.copyWith(
      queueStatus: DeviceQueueStatus.queued,
      queuedAt: DateTime.now(),
      queuePosition: state.queuedDevices.length,
    );

    state = state.copyWith(devices: [...state.devices, deviceWithQueue]);

    // Update queue positions for all devices
    _updateQueuePositions();

    // Try to start the device if there's capacity
    _processQueue();
  }

  void removeDevice(String deviceId) {
    if (!state.devices.any((d) => d.deviceId == deviceId)) {
      return;
    }

    // Reset the factory test for this device
    ref.read(factoryTestProvider(deviceId).notifier).resetFactoryTest();

    ref.invalidate(factoryTestProvider(deviceId));
    ref.invalidate(submissionProvider(deviceId));

    state = state.copyWith(
      devices:
          state.devices.where((device) => device.deviceId != deviceId).toList(),
    );

    // Update queue positions and try to start next device
    _updateQueuePositions();
    _processQueue();
  }

  /// Update queue positions for all queued devices
  void _updateQueuePositions() {
    try {
      final devices = state.devices.map((device) {
        if (device.queueStatus == DeviceQueueStatus.queued) {
          final queuePosition = state.queuedDevices.indexOf(device);
          return device.copyWith(
              queuePosition: queuePosition >= 0 ? queuePosition : 0);
        }
        return device;
      }).toList();

      state = state.copyWith(devices: devices);
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (e.toString().contains('_ElementLifecycle.defunct')) {
        return;
      }
      rethrow;
    }
  }

  /// Process the queue to start devices if slots are available
  void _processQueue() {
    try {
      if (!state.canStartMoreDevices || state.queuedDevices.isEmpty) {
        return;
      }

      // Get the first queued device
      final nextDevice = state.queuedDevices.first;

      // Update device status to running
      final updatedDevices = state.devices.map((device) {
        if (device.deviceId == nextDevice.deviceId) {
          return device.copyWith(
            queueStatus: DeviceQueueStatus.running,
            startedAt: DateTime.now(),
          );
        }
        return device;
      }).toList();

      state = state.copyWith(devices: updatedDevices);

      // Start the factory test for this device
      ref
          .read(factoryTestProvider(nextDevice.deviceId).notifier)
          .connectToDeviceAndStartFactoryTest();

      // Update queue positions after starting a device
      _updateQueuePositions();

      // Check if we can start more devices
      _processQueue();
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (e.toString().contains('_ElementLifecycle.defunct')) {
        return;
      }
      rethrow;
    }
  }

  /// Mark a device as ready to submit results
  void markDeviceReadyToSubmit(String deviceId) {
    try {
      final devices = state.devices.map((device) {
        if (device.deviceId == deviceId) {
          return device.copyWith(
            queueStatus: DeviceQueueStatus.readyToSubmit,
          );
        }
        return device;
      }).toList();

      state = state.copyWith(devices: devices);

      // Update queue positions and try to start next device (ready to submit devices free up running slots)
      _updateQueuePositions();
      _processQueue();
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (e.toString().contains('_ElementLifecycle.defunct')) {
        return;
      }
      rethrow;
    }
  }

  /// Mark a device as completed and move it to the end
  void markDeviceCompleted(String deviceId, {bool success = true}) {
    try {
      if (success) {
        // For successful completion, show completed state briefly then remove
        _showCompletedThenRemove(deviceId);
      } else {
        // For errors, keep the device in the list so user can see the error and retry
        final devices = state.devices.map((device) {
          if (device.deviceId == deviceId) {
            return device.copyWith(
              queueStatus: DeviceQueueStatus.error,
              completedAt: DateTime.now(),
            );
          }
          return device;
        }).toList();

        state = state.copyWith(devices: devices);
      }

      // Update queue positions and try to start next device
      _updateQueuePositions();
      _processQueue();
    } catch (e) {
      // Ignore widget lifecycle errors - this happens when widgets are disposed
      // during async operations but it's safe to ignore
      if (e.toString().contains('_ElementLifecycle.defunct')) {
        return;
      }
      rethrow;
    }
  }

  /// Show completed state briefly, then remove device from list
  void _showCompletedThenRemove(String deviceId) {
    // First, mark as completed
    final devices = state.devices.map((device) {
      if (device.deviceId == deviceId) {
        return device.copyWith(
          queueStatus: DeviceQueueStatus.completed,
          completedAt: DateTime.now(),
        );
      }
      return device;
    }).toList();

    state = state.copyWith(devices: devices);

    // After 250 milliseconds, remove the device from the list
    Future.delayed(const Duration(milliseconds: 250), () {
      _removeCompletedDevice(deviceId);
    });
  }

  /// Remove a completed device from the list
  void _removeCompletedDevice(String deviceId) {
    try {
      final updatedDevices =
          state.devices.where((device) => device.deviceId != deviceId).toList();

      state = state.copyWith(devices: updatedDevices);

      // Clean up the factory test provider for this device
      ref.read(factoryTestProvider(deviceId).notifier).dispose();

      debugPrint(
          'Device $deviceId removed from queue after successful completion');
    } catch (e) {
      // Ignore widget lifecycle errors
      if (e.toString().contains('_ElementLifecycle.defunct')) {
        return;
      }
      rethrow;
    }
  }

  /// Mark a device as having an error
  void markDeviceError(String deviceId, String? error) {
    markDeviceCompleted(deviceId, success: false);
  }

  /// Restart a completed or error device
  void restartDevice(String deviceId) {
    final devices = state.devices.map((device) {
      if (device.deviceId == deviceId &&
          (device.isCompleted || device.hasError)) {
        return device.copyWith(
          queueStatus: DeviceQueueStatus.queued,
          queuedAt: DateTime.now(),
          startedAt: null,
          completedAt: null,
          queuePosition: state.queuedDevices.length,
        );
      }
      return device;
    }).toList();

    state = state.copyWith(devices: devices);

    // Reset the factory test for this device
    ref.read(factoryTestProvider(deviceId).notifier).resetFactoryTest();

    // Update queue positions and try to start the device
    _updateQueuePositions();
    _processQueue();
  }

  /// Dispose the provider and all other providers
  void dispose() {
    _bleService.stopScan();
    for (var device in state.devices) {
      ref.read(factoryTestProvider(device.deviceId).notifier).dispose();
    }
  }
}
