import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/widgets/device_tab_item.dart';
import 'package:flutter/material.dart';

class DeviceTabsBar extends StatelessWidget {
  const DeviceTabsBar({
    super.key,
    required this.devices,
    required this.tabController,
    required this.pageController,
    required this.onAddDevice,
    required this.onRemoveDevice,
    required this.onShowDeviceOptions,
  });

  final List<FactoryTestDevice> devices;
  final TabController tabController;
  final PageController pageController;
  final VoidCallback onAddDevice;
  final Function(String deviceId) onRemoveDevice;
  final Function(FactoryTestDevice device) onShowDeviceOptions;

  @override
  Widget build(BuildContext context) {
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
          height: 64,
          child: Row(
            children: [
              // Tabs with ListenableBuilder to listen to tab changes
              Expanded(
                child: ListenableBuilder(
                  listenable: tabController,
                  builder: (context, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isActive = tabController.length > 0 &&
                            index < tabController.length &&
                            tabController.index == index;

                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 120,
                            minWidth: 80,
                          ),
                          child: DeviceTabItem(
                            device: device,
                            isActive: isActive,
                            onTap: () {
                              if (index < tabController.length) {
                                tabController.animateTo(index);
                                pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            onClose: () {
                              // if it is complete or in queue don't show the dialog just remove it
                              if (device.isCompleted || device.isQueued) {
                                onRemoveDevice(device.deviceId);
                                return;
                              }
                              onShowDeviceOptions(device);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Add button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: onAddDevice,
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
}
