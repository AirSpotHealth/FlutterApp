import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/device_factory_test_page.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/device_queue_status_widget.dart';
import 'package:airspothealth/features/factory_test/widgets/device_selection_sheet.dart';
import 'package:airspothealth/features/factory_test/widgets/device_tabs_bar.dart';
import 'package:airspothealth/features/factory_test/widgets/factory_test_empty_state.dart';
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
    // dispose all the devices
    ref.read(factoryTestDevicesProvider.notifier).dispose();
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _showExitFactoryTestDialog();
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tabController.length > 0 &&
                        _tabController.index < devices.length
                    ? devices[_tabController.index].displayName
                    : 'Factory Test',
              ),
              Text(
                devicesState.queueSummary,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _showAddDeviceSheet,
              icon: const Icon(Icons.add_circle),
              tooltip: 'Add Device',
            ),
          ],
        ),
        body: devices.isEmpty
            ? FactoryTestEmptyState(onAddDevice: _showAddDeviceSheet)
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
                  DeviceTabsBar(
                    devices: devices,
                    tabController: _tabController,
                    pageController: _pageController,
                    onAddDevice: _showAddDeviceSheet,
                    onRemoveDevice: _removeDevice,
                    onShowDeviceOptions: _showDeviceOptionsDialog,
                  ),
                ],
              ),
      ),
    );
  }

  void _showDeviceOptionsDialog(FactoryTestDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use the DeviceQueueStatusWidget instead of manual status building
            DeviceQueueStatusWidget(
              device: device,
              showDetails: true,
              onRestart: (device.isReadyToSubmit ||
                      device.isCompleted ||
                      device.hasError)
                  ? () {
                      Navigator.of(context).pop();
                      ref
                          .read(factoryTestDevicesProvider.notifier)
                          .restartDevice(device.deviceId);
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to do?',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _removeDevice(device.deviceId);
            },
            icon: const Icon(Icons.remove_circle, size: 16),
            label: const Text('Remove'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorRed,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
