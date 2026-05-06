import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/app_notification_preferences_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/external_urls.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/add_device/providers/ble_search_results_provider.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    // Initialize app notification preferences to sync topic subscriptions
    // This ensures users receive FCM notifications even if they don't visit the App Setup page
    ref.read(appNotificationPreferencesProvider);

    _checkFirmwareVersion();
    _checkAppVersion();
    _scanForDevices();
  }

  void _checkFirmwareVersion() {
    ref.read(firmwareRemoteVersionProvider);
  }

  void _checkAppVersion() {
    // Check for app updates
    ref.read(appVersionProvider);
  }

  void _scanForDevices() {
    // if bluetooth is on, start scanning for devices
    if (ref.read(bluetoothStateProvider) == BluetoothAdapterState.on) {
      ref.read(bluetoothSearchResultsProvider.notifier).startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedDevices = ref.watch(bleSavedDevicesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: CustomScrollView(
        slivers: [
          // Clean top app bar
          SliverAppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: false,
            floating: true,
            toolbarHeight: 60,
            title: const AppLogo(testEnabled: true),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline,
                    color: AppColors.textPrimary),
                onPressed: () => context.pushNamed(RouteNames.appSetup),
              ),
            ],
          ),

          // Greeting banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColorDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${_getUserName()}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Here is your home update.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.air, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ),

          // My Devices Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildMyDevicesCard(context, savedDevices),
            ),
          ),

          // Feature Cards Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildFeatureGrid(context),
            ),
          ),

          // Latest News
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLatestNewsCard(context),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  String _getUserName() {
    // TODO: Get from user profile/preferences when available
    // For now, return a default
    return 'Alex';
  }

  Widget _buildMyDevicesCard(BuildContext context, List<BleDevice> devices) {
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.devices),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      Assets.device,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${devices.length} active sensor${devices.length != 1 ? 's' : ''} nearby',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (devices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDevicePreview(context, devices[0], 0),
                  ),
                  if (devices.length > 1) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDevicePreview(context, devices[1], 1),
                    ),
                  ],
                  if (devices.length > 2) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAddDevicePreview(context),
                    ),
                  ] else if (devices.length == 2) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAddDevicePreview(context),
                    ),
                  ],
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              _buildAddDevicePreview(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevicePreview(
      BuildContext context, BleDevice device, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '98', // Placeholder - will use actual CO2 value
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.brandColorGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            device.alias ?? 'Device ${index + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddDevicePreview(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.addDevice),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderPrimary,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: AppColors.primaryColor),
            SizedBox(height: 4),
            Text(
              'ADD NEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Row(
      children: [
        // AirMap - Large card
        Expanded(
          flex: 2,
          child: _buildFeatureCard(
            context,
            title: 'AirMap.',
            description: 'Geolocate indoor air quality spots.',
            iconAsset: Assets.airMap,
            onTap: () => context.tryLaunchUrl(ExternalUrls.airmap),
            isLarge: true,
          ),
        ),
        const SizedBox(width: 12),
        // Solutions and Shop - Stacked
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildFeatureCard(
                context,
                title: 'Solutions.',
                description: 'Healthy living advice.',
                iconAsset: Assets.solutions,
                onTap: () => context.pushNamed(RouteNames.solutions),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                title: 'Shop.',
                description: 'Products & Partners.',
                iconAsset: Assets.shop,
                onTap: () => context.tryLaunchUrl(ExternalUrls.shop),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required String iconAsset,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          color: isLarge ? AppColors.primaryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isLarge ? null : Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconAsset,
              width: isLarge ? 32 : 24,
              height: isLarge ? 32 : 24,
              color: isLarge ? Colors.white : null,
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: isLarge ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: isLarge ? 14 : 12,
                color: isLarge ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            if (isLarge) ...[
              const SizedBox(height: 12),
              Image.asset(
                Assets.airMap,
                width: 80,
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLatestNewsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.tryLaunchUrl(ExternalUrls.news),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowPrimary,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  Assets.news,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest News',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Updates on fresh air living trends',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
