import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceSelectionSheet extends ConsumerStatefulWidget {
  const DeviceSelectionSheet({super.key});

  @override
  ConsumerState<DeviceSelectionSheet> createState() =>
      _DeviceSelectionSheetState();
}

class _DeviceSelectionSheetState extends ConsumerState<DeviceSelectionSheet> {
  Future<void> _handleRefresh() async {
    final notifier = ref.read(factoryTestDevicesProvider.notifier);

    // Stop current scan if running
    if (ref.read(factoryTestDevicesProvider).isScanning) {
      notifier.stopScanning();
    }

    // Wait a moment and start fresh scan
    await Future.delayed(const Duration(milliseconds: 500));
    notifier.startScanning();

    // Auto-stop scanning after 30 seconds to prevent forever scanning
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && ref.read(factoryTestDevicesProvider).isScanning) {
        notifier.stopScanning();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final factoryTestState = ref.watch(factoryTestDevicesProvider);

    return Container(
      height: MediaQuery.of(context).size.height *
          0.75, // Limit height to 75% of screen
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Factory Test Device',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primaryColor,
              backgroundColor: AppColors.backgroundPrimary,
              child: Column(
                children: [
                  _buildDevicesTitle(factoryTestState),
                  Expanded(
                    child: factoryTestState.scannedDevices.isEmpty
                        ? _buildEmptyState(factoryTestState.isScanning)
                        : _buildDeviceList(factoryTestState.scannedDevices),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTitle(FactoryTestDevicesState state) {
    // Calculate available devices (not already being tested)
    final deviceState = ref.watch(factoryTestDevicesProvider);
    final existingDeviceIds =
        deviceState.devices.map((d) => d.deviceId).toSet();
    final availableDevicesCount = state.scannedDevices
        .where((device) => !existingDeviceIds.contains(device.deviceId))
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Search bar with scan controls
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderPrimary),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowPrimary,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Device count and scanning status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$availableDevicesCount available devices',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (state.isScanning) ...[
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.brandColorGreen,
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                // Manual scan toggle button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (state.isScanning) {
                          ref
                              .read(factoryTestDevicesProvider.notifier)
                              .stopScanning();
                        } else {
                          _handleRefresh();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          state.isScanning ? Icons.stop : Icons.refresh,
                          size: 20,
                          color: state.isScanning
                              ? AppColors.brandColorRed
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Pull to refresh hint
          if (!state.isScanning && state.scannedDevices.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or tap the refresh button',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: .7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isScanning) {
    if (isScanning) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Searching for devices...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Make sure devices are powered on and nearby',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Scanning will automatically stop after 30 seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 24),
              Text(
                'No devices found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pull down to refresh or tap the refresh button to scan again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<FactoryTestDevice> scannedDevices) {
    // Filter out devices that are already being tested
    final deviceState = ref.watch(factoryTestDevicesProvider);
    final existingDeviceIds =
        deviceState.devices.map((d) => d.deviceId).toSet();
    final availableDevices = scannedDevices
        .where((device) => !existingDeviceIds.contains(device.deviceId))
        .toList();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: availableDevices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = availableDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(FactoryTestDevice device) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Signal strength icon
          Icon(
            _getSignalIcon(device.rssi),
            color: _getSignalColor(device.rssi),
            size: 20,
          ),
          const SizedBox(width: 12),

          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatMacAddress(device.deviceId),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.rssi} dBm • ${_getSignalStrength(device.rssi)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getSignalColor(device.rssi),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Start button
          ElevatedButton(
            onPressed: () => _connectToDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorGreen,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMacAddress(String deviceId) {
    // Format device ID to look like a MAC address (take first 12 chars and format)
    String cleanId = deviceId.replaceAll(RegExp(r'[^a-fA-F0-9]'), '');
    if (cleanId.length >= 12) {
      return cleanId
          .substring(0, 12)
          .toUpperCase()
          .replaceAllMapped(
            RegExp(r'(.{2})'),
            (match) => '${match.group(1)}:',
          )
          .substring(0, 17); // Remove trailing colon
    }
    // Fallback for shorter IDs
    return deviceId.length > 17 ? '${deviceId.substring(0, 17)}...' : deviceId;
  }

  String _getSignalStrength(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -70) return 'Good';
    if (rssi >= -80) return 'Fair';
    return 'Weak';
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -50) return Icons.signal_wifi_4_bar;
    if (rssi >= -70) return Icons.network_wifi_3_bar;
    if (rssi >= -80) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -50) return AppColors.brandColorGreen;
    if (rssi >= -70) return AppColors.brandColorGreen;
    return AppColors.brandColorRed;
  }

  void _connectToDevice(FactoryTestDevice device) {
    // Add device to the devices list first
    ref.read(factoryTestDevicesProvider.notifier).addDevice(device.deviceId);

    // Don't automatically close the bottom sheet - let users start multiple tests
    // Navigator.of(context).pop();
  }
}
