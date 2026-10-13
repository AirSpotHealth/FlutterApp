import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

enum PatchPhase {
  idle,
  checking,
  available,
  downloading,
  ready,
  current,
  unavailable,
  failed
}

class PatchUpdateState {
  const PatchUpdateState(
      {this.phase = PatchPhase.idle,
      this.currentPatch,
      this.nextPatch,
      this.release = '',
      this.applied = false});
  final PatchPhase phase;
  final int? currentPatch, nextPatch;
  final String release;
  final bool applied;
  bool get busy =>
      phase == PatchPhase.checking || phase == PatchPhase.downloading;
  bool get actionable =>
      phase == PatchPhase.available || phase == PatchPhase.ready;
}

final shorebirdUpdaterProvider =
    Provider<ShorebirdUpdater>((ref) => ShorebirdUpdater());
final patchPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());
final patchReleaseProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
});
final patchUpdateProvider =
    NotifierProvider<PatchUpdateNotifier, PatchUpdateState>(
        PatchUpdateNotifier.new);

class PatchUpdateNotifier extends Notifier<PatchUpdateState> {
  bool _startupChecked = false;
  bool _disposed = false;
  @override
  PatchUpdateState build() {
    ref.onDispose(() => _disposed = true);
    return const PatchUpdateState();
  }

  void _set(PatchPhase phase,
      {int? current, int? next, String? release, bool? applied}) {
    if (_disposed) return;
    state = PatchUpdateState(
        phase: phase,
        currentPatch: current ?? state.currentPatch,
        nextPatch: next,
        release: release ?? state.release,
        applied: applied ?? state.applied);
  }

  Future<bool> checkOnLaunch() async {
    if (_startupChecked) return false;
    _startupChecked = true;
    await check();
    return !_disposed && (state.actionable || state.applied);
  }

  Future<void> check() async {
    if (state.busy) return;
    _set(PatchPhase.checking);
    final updater = ref.read(shorebirdUpdaterProvider);
    try {
      final release = await ref.read(patchReleaseProvider.future);
      if (_disposed) return;
      if (!updater.isAvailable) {
        _set(PatchPhase.unavailable, release: release);
        return;
      }
      final current = await updater.readCurrentPatch();
      final prefs = await ref.read(patchPreferencesProvider.future);
      final key = 'shorebird_seen_$release';
      final previous = prefs.getInt(key);
      final number = current?.number ?? 0;
      final applied = (previous ?? 0) != number;
      await prefs.setInt(key, number);
      if (_disposed) return;
      state = PatchUpdateState(
          phase: PatchPhase.checking,
          release: release,
          currentPatch: current?.number,
          applied: state.applied || applied);
      final status = await updater.checkForUpdate(track: UpdateTrack.stable);
      final next = await updater.readNextPatch();
      _set(_phase(status), next: next?.number);
    } catch (_) {
      _set(PatchPhase.failed);
    }
  }

  Future<void> download() async {
    if (state.phase != PatchPhase.available) return;
    _set(PatchPhase.downloading);
    final updater = ref.read(shorebirdUpdaterProvider);
    try {
      await updater.update(track: UpdateTrack.stable);
      // update() can return while another native updater is still working.
      // Only confirmed staging permits the restart message, including rollback.
      final next = await updater.readNextPatch();
      if ((next?.number ?? 0) != (state.currentPatch ?? 0)) {
        _set(PatchPhase.ready, next: next?.number);
      } else {
        final status = await updater.checkForUpdate(track: UpdateTrack.stable);
        final staged = await updater.readNextPatch();
        _set(_phase(status), next: staged?.number);
      }
    } catch (_) {
      _set(PatchPhase.failed);
    }
  }

  void acknowledgeApplied() {
    _set(state.phase, next: state.nextPatch, applied: false);
  }

  PatchPhase _phase(UpdateStatus status) => switch (status) {
        UpdateStatus.outdated => PatchPhase.available,
        UpdateStatus.restartRequired => PatchPhase.ready,
        UpdateStatus.upToDate => PatchPhase.current,
        UpdateStatus.unavailable => PatchPhase.unavailable,
      };
}
