import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
            _buildVersion('Current Version: '),
            const SizedBox(height: 16),
            _buildVersion('Latest Version: ', isLatest: true),
          ],
        ),
      ),
    );
  }

  Container _buildVersion(String labelText, {bool isLatest = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralGreyLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(labelText),
          const Spacer(),
          FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, data) {
                switch (data.connectionState) {
                  case ConnectionState.waiting:
                    return const CupertinoActivityIndicator();
                  case ConnectionState.done:
                    final PackageInfo? packageInfo = data.data;
                    return Text(packageInfo?.version ?? 'Unknown',
                        style: TextStyle(
                            color:
                                isLatest ? AppColors.brandColorAmber : null));
                  default:
                    return const Text('Unknown');
                }
              }),
        ],
      ),
    );
  }
}
