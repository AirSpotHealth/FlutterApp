import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';

/// Presentation and request feedback; the page owns the Bluetooth command.
class SlimLocatePanel extends StatefulWidget {
  const SlimLocatePanel({required this.onLocate, super.key});
  final Future<bool> Function() onLocate;

  @override
  State<SlimLocatePanel> createState() => _SlimLocatePanelState();
}

class _SlimLocatePanelState extends State<SlimLocatePanel> {
  bool _sending = false;
  String? _feedback;

  Future<void> _locate() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _feedback = null;
    });
    bool sent = false;
    try {
      sent = await widget.onLocate();
    } catch (_) {
      // A failed transport must leave the action available for another attempt.
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _feedback = sent
          ? 'LED flash requested. Look for a flashing white light.'
          : 'Connect to Slim, then try again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.lightbulb_outline,
                size: 64, color: AppColors.primaryColorDark),
            const SizedBox(height: 24),
            Text('Find your Slim',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text(
              'Flash Slim’s white LED for 5 seconds to help find it. Keep your Slim connected to this phone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Button(
              onPressed: _locate,
              loading: _sending,
              prefixIcon: const Icon(Icons.search, size: 20),
              label: 'Flash Slim LED',
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 16),
              Semantics(
                  liveRegion: true,
                  child: Text(_feedback!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary))),
            ],
          ],
        ),
      ),
    );
  }
}
