import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorConfigurationPage extends ConsumerWidget {
  final String deviceId;

  const SensorConfigurationPage({super.key, required this.deviceId});

  // Map sensor types to appropriate icons and colors
  Map<String, dynamic> _getSensorIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('temperature')) {
      return {
        'icon': FontAwesomeIcons.temperatureHigh,
        'color': const Color(0xFF2E7D32),
        'gradient': [
          const Color(0xFFE8F5E9),
          const Color(0xFFF1F8E9),
        ],
      };
    } else if (lowerKey.contains('altitude')) {
      return {
        'icon': FontAwesomeIcons.mountain,
        'color': const Color(0xFF1565C0),
        'gradient': [
          const Color(0xFFE3F2FD),
          const Color(0xFFE8EAF6),
        ],
      };
    } else if (lowerKey.contains('pressure')) {
      return {
        'icon': FontAwesomeIcons.gaugeHigh,
        'color': const Color(0xFF4527A0),
        'gradient': [
          const Color(0xFFEDE7F6),
          const Color(0xFFF3E5F5),
        ],
      };
    } else if (lowerKey.contains('target')) {
      return {
        'icon': FontAwesomeIcons.bullseye,
        'color': const Color(0xFFF57F17),
        'gradient': [
          const Color(0xFFFFF8E1),
          const Color(0xFFFFF3E0),
        ],
      };
    } else if (lowerKey.contains('serial')) {
      return {
        'icon': Icons.qr_code_scanner,
        'color': const Color(0xFF43A047),
        'gradient': [
          const Color(0xFFE8F5E9),
          const Color(0xFFF1F8E9),
        ],
      };
    } else if (lowerKey.contains('variant')) {
      return {
        'icon': FontAwesomeIcons.microchip,
        'color': const Color(0xFF795548),
        'gradient': [
          const Color(0xFFEFEBE9),
          const Color(0xFFF5F5F5),
        ],
      };
    } else {
      return {
        'icon': FontAwesomeIcons.toggleOff,
        'color': const Color(0xFF546E7A),
        'gradient': [
          const Color(0xFFECEFF1),
          const Color(0xFFF5F5F5),
        ],
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue<DeviceSensorConfigData?> sensorConfigState =
        ref.watch(sensorConfigurationProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Sensor Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new, color: Colors.grey[800], size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: sensorConfigState.when(
        none: () => _buildEmptyState(context, ref),
        inProgress: (progress, message) => _buildLoadingState(message),
        success: (data) {
          final configData = data as DeviceSensorConfigData?;
          if (configData == null) {
            return _buildEmptyState(context, ref);
          }
          return _buildSensorGrid(context, configData.toJson(), ref);
        },
        failure: (error) => _buildErrorState(context, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              size: 64, color: Colors.blueGrey.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            'Sensor configuration not loaded.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Fetch Configuration'),
            onPressed: () => ref
                .read(sensorConfigurationProvider(deviceId).notifier)
                .refresh(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message ?? 'Loading sensor data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Colors.redAccent.withValues(alpha: 0.7)),
          const SizedBox(height: 24),
          Text(
            'Error: ${error.toString()}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => ref
                .read(sensorConfigurationProvider(deviceId).notifier)
                .refresh(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid(
      BuildContext context, Map<String, dynamic> dataMap, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(sensorConfigurationProvider(deviceId).notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dataMap.length,
        itemBuilder: (context, index) {
          final entry = dataMap.entries.elementAt(index);
          final sensorInfo = _getSensorIcon(entry.key);
          return _buildSensorCard(context, entry, sensorInfo);
        },
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    MapEntry<String, dynamic> entry,
    Map<String, dynamic> sensorInfo,
  ) {
    return Hero(
      tag: 'sensor-${entry.key}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showSensorDetails(context, entry, sensorInfo);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: sensorInfo['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: (sensorInfo['color'] as Color).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          (sensorInfo['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      sensorInfo['icon'] as IconData,
                      color: sensorInfo['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: sensorInfo['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color:
                        (sensorInfo['color'] as Color).withValues(alpha: 0.3),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSensorDetails(
    BuildContext context,
    MapEntry<String, dynamic> entry,
    Map<String, dynamic> sensorInfo,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'sensor-${entry.key}',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (sensorInfo['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  sensorInfo['icon'] as IconData,
                  size: 32,
                  color: sensorInfo['color'] as Color,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              entry.key,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: sensorInfo['color'] as Color,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
