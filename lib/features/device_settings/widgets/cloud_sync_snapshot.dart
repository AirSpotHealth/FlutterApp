import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CloudSyncSnapshot extends StatelessWidget {
  const CloudSyncSnapshot({
    super.key,
    required this.isConnected,
    required this.serialNumber,
    required this.lastSyncedDate,
  });

  final bool isConnected;
  final String serialNumber;
  final DateTime? lastSyncedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.dashboard_outlined, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Snapshot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow(
              label: 'Device status',
              value: isConnected ? 'Connected' : 'Disconnected',
              valueColor: isConnected ? Colors.green : Colors.red,
            ),
            _detailRow(
              label: 'Serial number',
              value: serialNumber,
            ),
            _detailRow(
              label: 'Latest cloud data',
              value: lastSyncedDate != null
                  ? DateFormat('MMM d, yyyy • h:mm a').format(lastSyncedDate!)
                  : 'Not synced yet',
              valueColor:
                  lastSyncedDate != null ? Colors.purple : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
