import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/device_factory_test_page.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/device_queue_status_widget.dart';
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
              const Text('Factory Test'),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Queue system illustration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 48,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Queue System',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add multiple devices and let our intelligent queue manage testing automatically',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features list
            _buildFeaturesList(),

            const SizedBox(height: 32),

            // Add device button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddDeviceSheet,
                icon: const Icon(Icons.add_circle),
                label: const Text('Add Your First Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.speed,
        'title': '4 Concurrent Tests',
        'description': 'Test up to 4 devices simultaneously',
        'color': AppColors.brandColorAmber,
      },
      {
        'icon': Icons.queue,
        'title': 'Smart Queuing',
        'description': 'Auto-start devices when slots open',
        'color': AppColors.primaryColor,
      },
      {
        'icon': Icons.track_changes,
        'title': 'Real-time Status',
        'description': 'Monitor progress with live indicators',
        'color': AppColors.brandColorGreen,
      },
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (feature['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: 24,
                        color: feature['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            feature['description'] as String,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomTabs(List<FactoryTestDevice> devices) {
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
          height: 64, // Increased height to accommodate two-line content
          child: Row(
            children: [
              // Tabs
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isActive = _tabController.length > 0 &&
                        index < _tabController.length &&
                        _tabController.index == index;

                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 120, // Constrain maximum width
                        minWidth: 80, // Minimum width
                      ),
                      child: _buildDeviceTab(
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
                        onClose: () {
                          // if it is complete or in queue don't show the dialog just remove it
                          if (device.isCompleted || device.isQueued) {
                            _removeDevice(device.deviceId);

                            return;
                          }
                          _showDeviceOptionsDialog(device);
                        },
                      ),
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
    // Inline status color and icon (simplified version for tabs)
    Color statusColor;
    IconData statusIcon;

    switch (device.queueStatus) {
      case DeviceQueueStatus.queued:
        statusColor = AppColors.primaryColor;
        statusIcon = Icons.schedule;
        break;
      case DeviceQueueStatus.running:
        statusColor = AppColors.brandColorAmber;
        statusIcon = Icons.play_circle_filled;
        break;
      case DeviceQueueStatus.readyToSubmit:
        statusColor = AppColors.primaryColorLight;
        statusIcon = Icons.upload;
        break;
      case DeviceQueueStatus.completed:
        statusColor = AppColors.brandColorGreen;
        statusIcon = Icons.check_circle;
        break;
      case DeviceQueueStatus.error:
        statusColor = AppColors.brandColorRed;
        statusIcon = Icons.error;
        break;
    }

    Color backgroundColor =
        isActive ? statusColor : AppColors.backgroundSecondary;
    Color textColor =
        isActive ? AppColors.textOnPrimary : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: statusColor,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main row with icon, name, and close
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status indicator and device icon
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.watch,
                      size: 16,
                      color: isActive
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                    // Status indicator dot
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? AppColors.textOnPrimary
                                : AppColors.backgroundPrimary,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                // Device name (expanded to fill available space)
                Expanded(
                  child: Text(
                    device.displayName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Close button
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.textOnPrimary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
            // Status text (simplified)
            const SizedBox(height: 2),
            if (device.isQueued && device.queuePosition > 0)
              Text(
                'Queue #${device.queuePosition + 1}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    statusIcon,
                    size: 8,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      device.isRunning
                          ? 'Running'
                          : device.isReadyToSubmit
                              ? 'Ready'
                              : device.isCompleted
                                  ? 'Done'
                                  : 'Error',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
