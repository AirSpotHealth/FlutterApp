import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:flutter/material.dart';

class DeviceTabItem extends StatelessWidget {
  const DeviceTabItem({
    super.key,
    required this.device,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final FactoryTestDevice device;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Define softer, more professional colors for each status
    Color statusColor;
    Color lightStatusColor;
    IconData statusIcon;

    switch (device.queueStatus) {
      case DeviceQueueStatus.queued:
        statusColor = const Color(0xFF6366F1); // Soft indigo
        lightStatusColor = const Color(0xFFEEF2FF); // Very light indigo
        statusIcon = Icons.schedule;
        break;
      case DeviceQueueStatus.running:
        statusColor = const Color(0xFFF59E0B); // Soft amber
        lightStatusColor = const Color(0xFFFEF3C7); // Very light amber
        statusIcon = Icons.play_circle_filled;
        break;
      case DeviceQueueStatus.readyToSubmit:
        statusColor = const Color(0xFF8B5CF6); // Soft purple
        lightStatusColor = const Color(0xFFF3E8FF); // Very light purple
        statusIcon = Icons.upload;
        break;
      case DeviceQueueStatus.completed:
        statusColor = const Color(0xFF10B981); // Soft green
        lightStatusColor = const Color(0xFFD1FAE5); // Very light green
        statusIcon = Icons.check_circle;
        break;
      case DeviceQueueStatus.error:
        statusColor = const Color(0xFFEF4444); // Soft red
        lightStatusColor = const Color(0xFFFEE2E2); // Very light red
        statusIcon = Icons.error;
        break;
    }

    // Active tab styling - more pronounced but still soft
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isActive) {
      backgroundColor = statusColor;
      textColor = Colors.white;
      borderColor = statusColor;
    } else {
      backgroundColor = lightStatusColor;
      textColor = statusColor;
      borderColor = statusColor.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
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
                      color: textColor.withValues(alpha: 0.8),
                    ),
                    // Status indicator dot
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? statusColor : Colors.white,
                            width: 1.5,
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
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.2)
                          : statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: textColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            // Status text (simplified)
            const SizedBox(height: 2),
            if (device.isQueued)
              Text(
                device.queuePosition == 0
                    ? 'Starting soon'
                    : 'Queue #${device.queuePosition + 1}',
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
                    size: 10,
                    color: textColor.withValues(alpha: 0.9),
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
                                  : device.hasError
                                      ? 'Error'
                                      : 'Unknown',
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
}
