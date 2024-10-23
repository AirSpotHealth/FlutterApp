import 'package:airspothealth/core/widgets/under_development_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AirgraphPage extends ConsumerWidget {
  const AirgraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airgraph'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: UnderDevelopmentWidget(),
      ),
    );
  }
}
