import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/actions_section.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/developer_section.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/device_controls_section.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/focus_section.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/sensor_display_section.dart';
import 'package:airspothealth/features/device_settings/widgets/sections/system_support_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeviceSettingsPage extends ConsumerStatefulWidget {
  const DeviceSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends ConsumerState<DeviceSettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    _controller.forward();

    // Invalidate settings on first frame if opened from expired link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      if (from == 'expired') {
        LiveActivityService()
            .removeDeviceLiveActivity(widget.deviceId)
            .ignore();
        ref
            .read(deviceSettingsProvider(widget.deviceId).notifier)
            .updateSettings(ref
                .read(deviceSettingsProvider(widget.deviceId))
                .copyWith(showLiveActivity: false));
        ref.invalidate(deviceSettingsProvider(widget.deviceId));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BleDevice? device = ref.watch(bleDeviceProvider(widget.deviceId));
    final bool devMode = ref.watch(devModeProvider);
    final deviceSettings = ref.watch(deviceSettingsProvider(widget.deviceId));

    if (device == null) {
      return const SizedBox();
    }

    final isConnected = ref
        .watch(bleDeviceConnectionProvider(widget.deviceId).notifier)
        .isConnected;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.backgroundPrimary,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black54, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              device.alias ?? device.name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isConnected ? 'CONNECTED' : 'DISCONNECTED',
              style: TextStyle(
                color: isConnected
                    ? AppColors.primaryColor
                    : AppColors.brandColorRed,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              (device.deviceModel ?? DeviceModel.fromDeviceName(device.name))
                  .displayName,
              style: const TextStyle(
                color: Colors.black38,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (devMode)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.backgroundPrimary,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black54),
                  onPressed: () {
                    context.pushNamed(RouteNames.dataLog,
                        pathParameters: {'deviceId': widget.deviceId});
                  },
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Device Controls
              DeviceControlsSection(
                deviceId: widget.deviceId,
                settings: deviceSettings,
                isConnected: isConnected,
                hasAlarm: device.capabilities.hasAlarm(),
                hasVibration: device.capabilities.hasVibration(),
              ),
              const SizedBox(height: 24),

              // Sensor & Display
              SensorDisplaySection(
                deviceId: widget.deviceId,
                settings: deviceSettings,
                isConnected: isConnected,
                supportsTimeSettings:
                    device.capabilities.supportsTimeSettings(),
                supportsScreenSettings:
                    device.capabilities.supportsScreenSettings(),
              ),
              const SizedBox(height: 24),

              // Focus
              if (device.capabilities.supportsDnd()) ...[
                FocusSection(
                  deviceId: widget.deviceId,
                  settings: deviceSettings,
                  isConnected: isConnected,
                  supportsDnd: device.capabilities.supportsDnd(),
                ),
                const SizedBox(height: 24),
              ],

              // System & Support
              SystemSupportSection(
                deviceId: widget.deviceId,
                device: device,
                isConnected: isConnected,
              ),
              const SizedBox(height: 24),

              // Actions
              ActionsSection(
                deviceId: widget.deviceId,
                settings: deviceSettings,
                device: device,
                isConnected: isConnected,
              ),

              if (devMode) ...[
                const SizedBox(height: 32),
                DeveloperSection(deviceId: widget.deviceId),
              ],

              const SizedBox(height: 40),
              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'AirSpot Device Manager v3.1.2',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2026 AirSpot Inc.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
