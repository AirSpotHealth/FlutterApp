import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:flutter/material.dart';

class DeviceQueueStatusWidget extends StatefulWidget {
  final FactoryTestDevice device;
  final bool showDetails;
  final VoidCallback? onTap;
  final VoidCallback? onRestart;

  const DeviceQueueStatusWidget({
    super.key,
    required this.device,
    this.showDetails = true,
    this.onTap,
    this.onRestart,
  });

  @override
  State<DeviceQueueStatusWidget> createState() =>
      _DeviceQueueStatusWidgetState();
}

class _DeviceQueueStatusWidgetState extends State<DeviceQueueStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulsing animation for running devices
    if (widget.device.isRunning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DeviceQueueStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start/stop animation based on status
    if (widget.device.isRunning && !oldWidget.device.isRunning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.device.isRunning && oldWidget.device.isRunning) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor().withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with device name and status
            Row(
              children: [
                // Animated status indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          widget.device.isRunning ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          shape: BoxShape.circle,
                          boxShadow: widget.device.isRunning
                              ? [
                                  BoxShadow(
                                    color: _getStatusColor()
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Device name
                Expanded(
                  child: Text(
                    widget.device.displayName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Status badge
                _buildStatusBadge(),
              ],
            ),

            if (widget.showDetails) ...[
              const SizedBox(height: 12),
              // Status details
              _buildStatusDetails(),

              // Action button for ready to submit, completed, or error devices
              if (widget.device.isReadyToSubmit ||
                  widget.device.isCompleted ||
                  widget.device.hasError) ...[
                const SizedBox(height: 12),
                _buildActionButton(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 14,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: context.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetails() {
    switch (widget.device.queueStatus) {
      case DeviceQueueStatus.queued:
        return _buildQueuedDetails();
      case DeviceQueueStatus.running:
        return _buildRunningDetails();
      case DeviceQueueStatus.readyToSubmit:
        return _buildReadyToSubmitDetails();
      case DeviceQueueStatus.completed:
        return _buildCompletedDetails();
      case DeviceQueueStatus.error:
        return _buildErrorDetails();
    }
  }

  Widget _buildQueuedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Position #${widget.device.queuePosition + 1} in queue',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (widget.device.estimatedWaitTime.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Estimated wait: ${widget.device.estimatedWaitTime}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRunningDetails() {
    final runningTime = widget.device.runningTime;
    return Row(
      children: [
        Icon(
          Icons.timer,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          runningTime != null
              ? 'Running for ${_formatDuration(runningTime)}'
              : 'Starting tests...',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReadyToSubmitDetails() {
    final runningTime = widget.device.runningTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.upload,
              size: 16,
              color: AppColors.primaryColorLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Tests completed - ready to submit',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (runningTime != null) ...[
          const SizedBox(height: 4),
          Text(
            'Completed in ${_formatDuration(runningTime)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedDetails() {
    final runningTime = widget.device.runningTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.brandColorGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tests completed and results submitted',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (runningTime != null) ...[
          const SizedBox(height: 4),
          Text(
            'Completed in ${_formatDuration(runningTime)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorDetails() {
    return Row(
      children: [
        Icon(
          Icons.error,
          size: 16,
          color: AppColors.brandColorRed,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Tests failed or device error occurred',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (widget.onRestart == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onRestart,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Restart Test'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.device.queueStatus) {
      case DeviceQueueStatus.queued:
        return AppColors.primaryColor;
      case DeviceQueueStatus.running:
        return AppColors.brandColorAmber;
      case DeviceQueueStatus.readyToSubmit:
        return AppColors.primaryColorLight;
      case DeviceQueueStatus.completed:
        return AppColors.brandColorGreen;
      case DeviceQueueStatus.error:
        return AppColors.brandColorRed;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.device.queueStatus) {
      case DeviceQueueStatus.queued:
        return Icons.schedule;
      case DeviceQueueStatus.running:
        return Icons.play_circle_filled;
      case DeviceQueueStatus.readyToSubmit:
        return Icons.upload;
      case DeviceQueueStatus.completed:
        return Icons.check_circle;
      case DeviceQueueStatus.error:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (widget.device.queueStatus) {
      case DeviceQueueStatus.queued:
        return 'Queued';
      case DeviceQueueStatus.running:
        return 'Running';
      case DeviceQueueStatus.readyToSubmit:
        return 'Ready';
      case DeviceQueueStatus.completed:
        return 'Completed';
      case DeviceQueueStatus.error:
        return 'Error';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
