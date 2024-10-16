import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUpdatesPage extends ConsumerStatefulWidget {
  const AppUpdatesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends ConsumerState<AppUpdatesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AirSpot App Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppLogo(width: 200),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutralGreyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('Current Version: '),
                  SizedBox(width: 8),
                  Text('1.2.9'),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Up to Date',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
