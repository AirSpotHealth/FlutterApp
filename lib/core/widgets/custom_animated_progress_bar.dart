import 'package:flutter/material.dart';

class CustomAnimatedProgressBar extends StatefulWidget {
  final double progress;

  const CustomAnimatedProgressBar({super.key, required this.progress})
      : assert(
            progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');

  @override
  State<CustomAnimatedProgressBar> createState() =>
      _CustomAnimatedProgressBarState();
}

class _CustomAnimatedProgressBarState extends State<CustomAnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(CustomAnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      // Update animation when progress changes
      _animation =
          Tween<double>(begin: _animation.value, end: widget.progress).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress Bar
        Stack(
          children: [
            // Background Bar
            Container(
              width: 300,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Foreground Animated Bar
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 300 * _animation.value,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress Percentage Text
        Text(
          '${(_animation.value * 100).toInt()}%',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
