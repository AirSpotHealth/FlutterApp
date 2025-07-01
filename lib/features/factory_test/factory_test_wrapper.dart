import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/device_factory_test_page.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/device_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FactoryTestWrapper extends ConsumerStatefulWidget {
  const FactoryTestWrapper({super.key});

  @override
  ConsumerState<FactoryTestWrapper> createState() => _FactoryTestWrapperState();
}

class _FactoryTestWrapperState extends ConsumerState<FactoryTestWrapper>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(factoryTestDevicesProvider.notifier).startScanning();

      // Only show device selection sheet if no devices are currently added
      final currentDevices = ref.read(factoryTestDevicesProvider).devices;
      if (currentDevices.isEmpty) {
        _showAddDeviceSheet();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showAddDeviceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: false, // We have our own drag handle
      backgroundColor: Colors.transparent,
      builder: (context) => const DeviceSelectionSheet(),
    );
  }

  void _removeDevice(String deviceId) {
    ref.read(factoryTestDevicesProvider.notifier).removeDevice(deviceId);
  }

  void _updateTabController(int deviceCount) {
    if (_tabController.length != deviceCount) {
      _tabController.dispose();
      _tabController = TabController(length: deviceCount, vsync: this);

      // If we removed the currently selected tab, adjust the index
      if (_tabController.length > 0 &&
          _tabController.index >= _tabController.length) {
        _tabController.index = _tabController.length - 1;
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showExitFactoryTestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.brandColorRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Exit Factory Test'),
          ],
        ),
        content: const Text('Are you sure you want to exit the factory test?'),
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              ref.read(factoryTestDevicesProvider.notifier).stopScanning();
            },
            child: Text(
              'Exit',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(factoryTestDevicesProvider);
    final devices = devicesState.devices;

    // Update tab controller when device count changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabController(devices.length);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Factory Test'),
        actions: [
          IconButton(
            onPressed: _showAddDeviceSheet,
            icon: const Icon(Icons.add_circle),
            tooltip: 'Add Device',
          ),
        ],
        leading: IconButton(
          onPressed: () {
            _showExitFactoryTestDialog();
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: devices.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Main content with PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: devices.length,
                    onPageChanged: (index) {
                      if (index < _tabController.length) {
                        _tabController.animateTo(index);
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index >= devices.length) return const SizedBox();
                      return DeviceFactoryTestPage(
                        deviceId: devices[index].deviceId,
                        showHeader: false,
                      );
                    },
                  ),
                ),
                // Bottom tabs
                _buildBottomTabs(devices),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Devices Added',
            style: context.textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add devices for testing',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddDeviceSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTabs(List devices) {
    if (devices.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              // Tabs
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isActive = _tabController.length > 0 &&
                        index < _tabController.length &&
                        _tabController.index == index;

                    return _buildDeviceTab(
                      device: device,
                      isActive: isActive,
                      onTap: () {
                        if (index < _tabController.length) {
                          _tabController.animateTo(index);
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      onClose: () =>
                          _showRemoveDeviceDialog(device.deviceId, device.name),
                    );
                  },
                ),
              ),
              // Add button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: _showAddDeviceSheet,
                  icon: Icon(
                    Icons.add,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Add Device',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTab({
    required FactoryTestDevice device,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onClose,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primaryColor : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isActive ? AppColors.primaryColor : AppColors.borderSecondary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Device icon and name
            Icon(
              Icons.watch,
              size: 14,
              color:
                  isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                device.name.replaceFirst('AirSpot-', ''),
                style: context.textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Close button
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(1),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDeviceDialog(String deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppColors.brandColorRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Remove Device',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$deviceName" from factory testing?\n\n'
          'This will:\n'
          '• Stop any ongoing tests\n'
          '• Disconnect the device\n'
          '• Remove all test data for this device',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.4,
          ),
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
              _removeDevice(deviceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorRed,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
