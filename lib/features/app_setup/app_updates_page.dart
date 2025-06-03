import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_version_plus/new_version_plus.dart';

class AppUpdatesPage extends ConsumerWidget {
  const AppUpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<VersionStatus?> versionStatus =
        ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appSetup.airspotAppUpdate),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AppLogo(width: 200),
            const SizedBox(height: 32),
            TappableWidget(
              onTap: () {
                ref.read(devModeProvider.notifier).toggleDevMode();

                context.showSnackBar(t.devModeEnabled);
              },
              tapCount: 7,
              child: _buildVersionInfoRow(
                label: t.deviceSettings.installedVersion,
                child: versionStatus.when(
                  data: (data) => Text(data?.localVersion ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  loading: () => const CupertinoActivityIndicator(),
                  error: (error, stackTrace) => Text(t.common.unknown),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildVersionInfoRow(
              label: t.latestVersionLabel,
              child: versionStatus.when(
                data: (data) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data?.canUpdate ?? false)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data?.storeVersion ?? 'Unknown',
                            style: TextStyle(
                              color: (data?.canUpdate ?? false)
                                  ? AppColors.primaryColor
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: ElevatedButton(
                              child: Text(t.common.updateNow),
                              onPressed: () {
                                context.tryLaunchUrl(data!.appStoreLink);
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        t.common.upToDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
                loading: () => const CupertinoActivityIndicator(),
                error: (error, stackTrace) => Text(t.common.unknown),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfoRow({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralGreyLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}
