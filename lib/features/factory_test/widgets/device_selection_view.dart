import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceSelectionView extends ConsumerWidget {
  const DeviceSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Column(
        children: [
          // Orange header
          Container(
            color: const Color(0xFFFF9500), // Orange color from the image
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                // Header with back button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Factory Test - Select Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search devices by name or ID...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      // Scanning status on the right
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${factoryTestState.availableDevices.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (factoryTestState.isScanning) ...[
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF9C4CFF),
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter and scanning status
                Row(
                  children: [
                    // All Devices dropdown
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16),
                            Text(
                              'All Devices',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Scanning status
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${factoryTestState.availableDevices.length} of ${factoryTestState.availableDevices.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (factoryTestState.isScanning) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(
                                    0xFF9C4CFF), // Purple color from image
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Scanning...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Device list
          Expanded(
            child: factoryTestState.availableDevices.isEmpty
                ? _buildEmptyState(factoryTestState.isScanning)
                : _buildDeviceList(
                    context, ref, factoryTestState.availableDevices),
          ),
        ],
      ),

      // Floating action button to start/stop scanning
      floatingActionButton: FloatingActionButton(
        onPressed: factoryTestState.isScanning
            ? () => ref.read(factoryTestProvider.notifier).stopScanning()
            : () => ref.read(factoryTestProvider.notifier).startScanning(),
        backgroundColor: const Color(0xFFFF9500),
        child: Icon(
          factoryTestState.isScanning ? Icons.stop : Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isScanning) {
    if (isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFFFF9500),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Searching for devices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Make sure devices are powered on and nearby',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled_outlined,
            size: 48,
            color: AppColors.neutralGrey,
          ),
          SizedBox(height: 16),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap the scan button to search for devices',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(
      BuildContext context, WidgetRef ref, List<FactoryTestDevice> devices) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(context, ref, device);
      },
    );
  }

  Widget _buildDeviceCard(
      BuildContext context, WidgetRef ref, FactoryTestDevice device) {
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
            onPressed: () => _connectToDevice(context, ref, device),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorGreen,
              foregroundColor: Colors.white,
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

  Widget _buildSignalBars(int rssi) {
    final strength = _getSignalStrengthBars(rssi);
    final color = _getSignalColor(rssi);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: 3,
          height: 4 + (index * 2).toDouble(),
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < strength ? color : AppColors.neutralGreyLight,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  int _getSignalStrengthBars(int rssi) {
    if (rssi >= -50) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
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
    return const Color(0xFFFF9500); // Orange for fair/weak signals
  }

  void _connectToDevice(
      BuildContext context, WidgetRef ref, FactoryTestDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Start Factory Test',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Run factory test on "${device.name}"?',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Process:',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTestStep('Connect to device'),
                  _buildTestStep('Enter factory test mode'),
                  _buildTestStep('Run 5 automatic tests'),
                  _buildTestStep('Complete 8 manual tests'),
                  _buildTestStep('Generate test results'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(factoryTestProvider.notifier)
                  .connectToDeviceAndStartFactoryTest(device.deviceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Test',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
