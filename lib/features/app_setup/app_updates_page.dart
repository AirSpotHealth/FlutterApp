import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/app_setup/providers/patch_update_provider.dart';
import 'package:airspothealth/features/app_setup/widgets/patch_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUpdatesPage extends ConsumerWidget {
  const AppUpdatesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(patchReleaseProvider);
    final store = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AirSpot App Updates')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Center(child: AppLogo(width: 160)),
        const SizedBox(height: 24),
        TappableWidget(
            tapCount: 7,
            onTap: () {
              ref.read(devModeProvider.notifier).toggleDevMode();
              context.showSnackBar('Dev Mode setting changed.');
            },
            child: Center(
                child: Text(
                    version.when(
                      data: (value) => 'Installed version $value',
                      loading: () => 'Reading installed version…',
                      error: (_, __) => 'Installed version unavailable',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium))),
        const SizedBox(height: 16),
        const PatchUpdateCard(),
        const SizedBox(height: 12),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Image.asset(Assets.shop, width: 32, height: 32),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Store updates',
                                style: Theme.of(context).textTheme.titleMedium))
                      ]),
                      const SizedBox(height: 12),
                      const Text(
                          'Full app releases are installed through your app store.'),
                      const SizedBox(height: 12),
                      store.when(
                        loading: () => const LinearProgressIndicator(
                            semanticsLabel: 'Checking the app store'),
                        error: (_, __) =>
                            const Text('Couldn’t check the store. Try again.'),
                        data: (value) => value == null
                            ? const Text('Store version could not be verified.')
                            : value.canUpdate
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                            'Version ${value.storeVersion} is available'),
                                        const SizedBox(height: 12),
                                        Button(
                                            type: ButtonType.outlined,
                                            onPressed: () =>
                                                context.tryLaunchUrl(
                                                    value.appStoreLink),
                                            child:
                                                const Text('Open app store')),
                                      ])
                                : const Text(
                                    'No newer store release is available.'),
                      ),
                      TextButton(
                          onPressed: store.isLoading
                              ? null
                              : () => ref.invalidate(appVersionProvider),
                          child: const Text('Check store again')),
                    ]))),
      ]),
    );
  }
}
