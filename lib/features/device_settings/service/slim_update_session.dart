/// Owns the app/SMP handoff. Success is withheld until app communication returns.
class SlimUpdateSession {
  static Future<T> run<T>({
    required Future<void> Function() suspend,
    required Future<T> Function() updateAndVerify,
    required Future<void> Function() restore,
  }) async {
    Object? updateError;
    try {
      await suspend();
      return await updateAndVerify();
    } catch (error) {
      updateError = error;
      rethrow;
    } finally {
      try {
        await restore();
      } catch (_) {
        // Keep the original failure when upload/verification and recovery fail.
        if (updateError == null) rethrow;
      }
    }
  }
}
