import 'package:flutter/material.dart';

class TappableWidget extends StatefulWidget {
  const TappableWidget(
      {this.tapCount = 1, required this.onTap, required this.child, super.key});

  final int tapCount;

  final VoidCallback onTap;

  final Widget child;
  @override
  State<TappableWidget> createState() => _TappableWidgetState();
}

class _TappableWidgetState extends State<TappableWidget> {
  int _tapCount = 0;

  void _onTap() {
    _tapCount++;
    if (_tapCount == widget.tapCount) {
      widget.onTap();
      _tapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: widget.child,
    );
  }
}
