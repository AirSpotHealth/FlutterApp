import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/app_action_sheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/app_setup/providers/patch_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPatchUpdateDialog(BuildContext context) =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (_) => const PatchUpdateDialog());

class PatchUpdateDialog extends ConsumerWidget {
  const PatchUpdateDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patchUpdateProvider);
    return AppActionSheet(
      asset: Assets.deviceUpdate,
      title: patchTitle(state),
      description: patchDescription(state),
      details: Column(mainAxisSize: MainAxisSize.min, children: [
        if (state.busy) ...[
          const LinearProgressIndicator(
              color: AppColors.primaryColor,
              backgroundColor: AppColors.neutralGreyLight,
              semanticsLabel: 'App update in progress'),
          const SizedBox(height: 16),
        ],
        if (state.release.isNotEmpty)
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                  'Version ${state.release} · ${state.currentPatch == null ? 'Original release' : 'Patch ${state.currentPatch} installed'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary))),
      ]),
      actions: [
        if (state.phase == PatchPhase.available)
          Button(
              label: 'Download update',
              onPressed: () =>
                  ref.read(patchUpdateProvider.notifier).download()),
        if (state.phase == PatchPhase.failed)
          Button(
              label: 'Try again',
              onPressed: () => ref.read(patchUpdateProvider.notifier).check()),
        Button(
            label: state.phase == PatchPhase.available ? 'Later' : 'Got it',
            type: state.phase == PatchPhase.ready ||
                    state.phase == PatchPhase.current
                ? ButtonType.primary
                : ButtonType.outlined,
            onPressed: () {
              ref.read(patchUpdateProvider.notifier).acknowledgeApplied();
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}

String patchTitle(PatchUpdateState state) => switch (state.phase) {
      PatchPhase.available => 'A small update is ready',
      PatchPhase.downloading => 'Downloading your update',
      PatchPhase.ready => 'Ready when you reopen',
      PatchPhase.checking => 'Checking for updates',
      PatchPhase.failed => 'Couldn’t complete the update',
      PatchPhase.unavailable => 'App patches unavailable',
      _ => state.applied ? 'Your app update is active' : 'You’re up to date',
    };

String patchDescription(PatchUpdateState state) => switch (state.phase) {
      PatchPhase.available =>
        'Get the latest improvements for this app version without visiting the store. Your devices and saved readings stay in place.',
      PatchPhase.downloading =>
        'Keep an internet connection while the patch downloads. You can dismiss this dialog and check its progress in App Setup → App Updates.',
      PatchPhase.ready =>
        '${state.nextPatch == null ? 'An update' : 'Patch ${state.nextPatch}'} is downloaded but isn’t active yet. When convenient, fully close AirSpot from the app switcher and reopen it. Wait for any device firmware update to finish first. If it still says restart required, restart your phone.',
      PatchPhase.checking =>
        'Checking for a patch compatible with your installed app version.',
      PatchPhase.failed =>
        'Check your connection and try again. We haven’t confirmed a completed update; your running app is unchanged.',
      PatchPhase.unavailable =>
        'This build does not support in-app patches. Store updates are still available below.',
      _ => state.applied
          ? 'AirSpot has restarted and is now running ${state.currentPatch == null ? 'the original release' : 'patch ${state.currentPatch}'}. Your saved data is still here.'
          : 'No newer patch is available for this installed app version.',
    };

class PatchUpdateCard extends ConsumerWidget {
  const PatchUpdateCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patchUpdateProvider);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset(Assets.deviceUpdate, width: 32, height: 32),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Quick app updates',
                        style: Theme.of(context).textTheme.titleMedium))
              ]),
              const SizedBox(height: 12),
              Text(state.phase == PatchPhase.idle
                  ? 'Check for a patch for your installed app version.'
                  : patchTitle(state)),
              if (state.release.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        '${state.release} · ${state.currentPatch == null ? 'Original release' : 'Patch ${state.currentPatch}'}')),
              if (state.busy)
                const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator()),
              const SizedBox(height: 12),
              Button(
                  disabled: state.busy,
                  type: ButtonType.outlined,
                  onPressed: () async {
                    if (!state.actionable) {
                      await ref.read(patchUpdateProvider.notifier).check();
                    }
                    if (context.mounted) {
                      await showPatchUpdateDialog(context);
                    }
                  },
                  label:
                      state.actionable ? 'View update' : 'Check for patches'),
            ])));
  }
}
