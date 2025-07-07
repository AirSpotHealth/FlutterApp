import 'dart:async';

import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({
    super.key,
    this.width = 100,
  });

  final double width;

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _onLogoTap() {
    _tapCount++;
    _resetTimer?.cancel();

    if (_tapCount >= 5) {
      _showFactoryTestPinDialog();
      _tapCount = 0;
    } else {
      // Reset tap count after 3 seconds if not enough taps
      _resetTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _tapCount = 0);
        }
      });
    }
  }

  void _showFactoryTestPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to enter PIN or cancel
      builder: (context) => _FactoryTestPinDialog(),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onLogoTap,
      child: Stack(
        children: [
          Image.asset(
            Assets.logo,
            width: widget.width,
          ),
          // Show tap count indicator when tapping
          if (_tapCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_tapCount/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FactoryTestPinDialog extends StatefulWidget {
  const _FactoryTestPinDialog();

  @override
  State<_FactoryTestPinDialog> createState() => _FactoryTestPinDialogState();
}

class _FactoryTestPinDialogState extends State<_FactoryTestPinDialog>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Factory test PIN - you can change this
  static const String _factoryTestPin = '2677';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeypadPressed(String value) {
    if (value == 'clear') {
      setState(() {
        _enteredPin = '';
      });
    } else if (value == 'backspace') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
    } else if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });

      // Auto-submit when 4 digits entered
      if (_enteredPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          if (_enteredPin == _factoryTestPin) {
            context.pop();
            context.pushNamed(RouteNames.factoryTest);
          } else {
            _onWrongPin();
          }
        });
      }
    }
  }

  void _onWrongPin() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
      setState(() {
        _enteredPin = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 350,
          maxHeight: 600,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.factory,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factory Test Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Enter 4-digit PIN',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PIN Display
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isEntered = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isEntered ? Colors.orange : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isEntered
                                ? Colors.orange.withValues(alpha: .1)
                                : Colors.grey[50],
                          ),
                          child: Center(
                            child: isEntered
                                ? const Icon(
                                    Icons.circle,
                                    color: Colors.orange,
                                    size: 14,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Keypad
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    // Row 1
                    _buildKeypadButton('1'),
                    _buildKeypadButton('2'),
                    _buildKeypadButton('3'),
                    // Row 2
                    _buildKeypadButton('4'),
                    _buildKeypadButton('5'),
                    _buildKeypadButton('6'),
                    // Row 3
                    _buildKeypadButton('7'),
                    _buildKeypadButton('8'),
                    _buildKeypadButton('9'),
                    // Row 4
                    _buildKeypadButton(
                      'clear',
                      icon: Icons.clear_all,
                      color: Colors.red,
                    ),
                    _buildKeypadButton('0'),
                    _buildKeypadButton(
                      'backspace',
                      icon: Icons.backspace_outlined,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _onKeypadPressed(value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: color ?? Colors.black87,
                    size: 20,
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.black87,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
