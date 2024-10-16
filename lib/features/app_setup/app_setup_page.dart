import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSetupPage extends ConsumerWidget {
  const AppSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Airspot Health'),
            Text('Please wait while we set up your app'),
          ],
        ),
      ),
    );
  }
}
