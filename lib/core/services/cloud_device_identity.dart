/// Reject identities emitted by older Slim firmware that are shared by every
/// device. They cannot safely own cloud readings or be migrated automatically.
void requireUniqueCloudIdentity(String identity) {
  final value = identity.trim().toUpperCase();
  if (value.isEmpty ||
      value == '534C494D3031' ||
      value == 'SLIM01' ||
      value == '000000000000' ||
      value == 'FFFFFFFFFFFF') {
    throw StateError(
      'This device has no unique cloud identity. Update its firmware and reconnect before syncing.',
    );
  }
}
