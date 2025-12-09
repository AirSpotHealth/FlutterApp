import 'dart:math' as math;

import 'package:flutter/material.dart';

class CloudSyncAnimation extends StatefulWidget {
  final bool isSyncing;
  final bool isSuccess;
  final bool isError;
  final double size;

  const CloudSyncAnimation({
    super.key,
    required this.isSyncing,
    this.isSuccess = false,
    this.isError = false,
    this.size = 100.0,
  });

  @override
  State<CloudSyncAnimation> createState() => _CloudSyncAnimationState();
}

class _CloudSyncAnimationState extends State<CloudSyncAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isSyncing) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(CloudSyncAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !oldWidget.isSyncing) {
      _startAnimations();
    } else if (!widget.isSyncing && oldWidget.isSyncing) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _pulseController.animateTo(1.0,
        duration: const Duration(milliseconds: 200));
    _rotateController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pulse (only when syncing)
          if (widget.isSyncing)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withValues(alpha: .1),
                    ),
                  ),
                );
              },
            ),

          // Cloud Icon
          Icon(
            Icons.cloud,
            size: widget.size * 0.8,
            color: widget.isError
                ? Colors.red
                : widget.isSuccess
                    ? Colors.green
                    : Colors.blue,
          ),

          // Overlay Icon (Syncing, Success, or Error)
          if (widget.isSyncing)
            AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Icon(
                    Icons.sync,
                    size: widget.size * 0.4,
                    color: Colors.white,
                  ),
                );
              },
            )
          else if (widget.isSuccess)
            Icon(
              Icons.check,
              size: widget.size * 0.4,
              color: Colors.white,
            )
          else if (widget.isError)
            Icon(
              Icons.error_outline,
              size: widget.size * 0.4,
              color: Colors.white,
            )
          else
            Icon(
              Icons.cloud_upload,
              size: widget.size * 0.4,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
