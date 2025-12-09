import 'package:flutter/material.dart';

class CloudSyncStatusWrap extends StatelessWidget {
  const CloudSyncStatusWrap({
    super.key,
    required this.isConnected,
    required this.serialNumber,
    required this.userEmail,
    required this.lastSyncedDate,
  });

  final bool isConnected;
  final String serialNumber;
  final String? userEmail;
  final DateTime? lastSyncedDate;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _statusChip(
        label: isConnected ? 'Device connected' : 'Device offline',
        color: isConnected ? Colors.green : Colors.red,
        icon: Icons.bluetooth,
      ),
      _statusChip(
        label: serialNumber,
        color: Colors.blue,
        icon: Icons.qr_code,
      ),
      _statusChip(
        label: userEmail ?? 'Not signed in',
        color: userEmail != null ? Colors.teal : Colors.grey,
        icon: userEmail != null ? Icons.verified_user : Icons.login,
      ),
      _statusChip(
        label: lastSyncedDate != null
            ? 'Last synced ${_relativeTime(lastSyncedDate!)}'
            : 'No cloud data yet',
        color: lastSyncedDate != null ? Colors.purple : Colors.orange,
        icon: Icons.cloud_done,
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _statusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 18),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.08),
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
