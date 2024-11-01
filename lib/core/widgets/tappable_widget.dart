import 'dart:async';

import 'package:flutter/material.dart';

class TappableWidget extends StatefulWidget {
  const TappableWidget({
    required this.onTap,
    required this.child,
    this.tapCount = 1,
    this.debounceTime = 300,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final int tapCount;
  final int debounceTime; // in milliseconds

  @override
  State<TappableWidget> createState() => _TappableWidgetState();
}

class _TappableWidgetState extends State<TappableWidget> {
  int _tapCounter = 0;
  bool _isDebounced = false;
  Timer? _debounceTimer;

  void _onTap() {
    if (!_isDebounced) {
      _tapCounter++;
      if (_tapCounter >= widget.tapCount) {
        widget.onTap();
        _isDebounced = true;
        _tapCounter = 0;

        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () {
          _isDebounced = false;
        });
      }
    }
    // Ignore taps while debounced
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: widget.child,
    );
  }
}
