import 'package:airspothealth/core/models/ble_device.dart';
import 'package:flutter/material.dart';

/// Dropdown selector for choosing a BLE device.
class DeviceSelector extends StatelessWidget {
  const DeviceSelector({
    super.key,
    required this.devices,
    required this.selectedDeviceId,
    required this.onChanged,
  });

  final List<BleDevice> devices;
  final String? selectedDeviceId;
  final ValueChanged<BleDevice?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedDeviceId,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Select a device (optional)',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.bluetooth_connected,
                color: Colors.blue.shade400, size: 20),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        items: devices.map((device) {
          return DropdownMenuItem(
            value: device.deviceId,
            child: Text(device.alias ?? device.name),
          );
        }).toList(),
        onChanged: (deviceId) {
          final device =
              devices.where((d) => d.deviceId == deviceId).firstOrNull;
          onChanged(device);
        },
      ),
    );
  }
}
