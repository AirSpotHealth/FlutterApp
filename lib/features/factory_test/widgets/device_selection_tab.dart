import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceSelectionTab extends ConsumerStatefulWidget {
  const DeviceSelectionTab({super.key});

  @override
  ConsumerState<DeviceSelectionTab> createState() => _DeviceSelectionTabState();
}

class _DeviceSelectionTabState extends ConsumerState<DeviceSelectionTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final notifier = ref.read(factoryTestProvider.notifier);

    // Stop current scan if running
    if (ref.read(factoryTestProvider).isScanning) {
      notifier.stopScanning();
    }

    // Wait a moment and start fresh scan
    await Future.delayed(const Duration(milliseconds: 500));
    notifier.startScanning();

    // Auto-stop scanning after 30 seconds to prevent forever scanning
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && ref.read(factoryTestProvider).isScanning) {
        notifier.stopScanning();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final factoryTestState = ref.watch(factoryTestProvider);
    final filteredDevices = _filterDevices(factoryTestState.availableDevices);

    return Container(
      color: AppColors.backgroundSecondary,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryColor,
        backgroundColor: AppColors.backgroundPrimary,
        child: Column(
          children: [
            _buildSearchSection(factoryTestState),
            Expanded(
              child: filteredDevices.isEmpty
                  ? _buildEmptyState(factoryTestState.isScanning)
                  : _buildDeviceList(filteredDevices),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(FactoryTestState state) {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.all(16.0),
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
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
                // Device count and scanning status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.availableDevices.length}',
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
                // Manual scan toggle button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (state.isScanning) {
                          ref.read(factoryTestProvider.notifier).stopScanning();
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
          if (!state.isScanning && state.availableDevices.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or tap the refresh button',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
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
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
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
                SizedBox(height: 16),
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: const Center(
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
                'Pull down to refresh or tap the refresh button',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<FactoryTestDevice> devices) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = devices[index];
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

  List<FactoryTestDevice> _filterDevices(List<FactoryTestDevice> devices) {
    if (_searchQuery.isEmpty) {
      return devices;
    }

    return devices.where((device) {
      return device.name.toLowerCase().contains(_searchQuery) ||
          device.deviceId.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _connectToDevice(FactoryTestDevice device) {
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
              backgroundColor: AppColors.brandColorGreen,
              foregroundColor: AppColors.textOnPrimary,
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
