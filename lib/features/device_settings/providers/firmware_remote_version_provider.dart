import 'dart:async';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firmwareRemoteVersionProvider = AsyncNotifierProvider.autoDispose<
    _FirmwareRemoteVersionNotifier,
    RemoteVersion?>(_FirmwareRemoteVersionNotifier.new);

class _FirmwareRemoteVersionNotifier
    extends AutoDisposeAsyncNotifier<RemoteVersion?> {
  final NetworkService _networkService = NetworkService.instance;

  @override
  FutureOr<RemoteVersion?> build() {
    return null;
  }

  Future<void> fetchRemoteVersion() async {
    state = const AsyncLoading();

    try {
      final Response<dynamic> result =
          await _networkService.get(ApiEndpoints.versionCheck, {});

      if (result.statusCode == 200) {
        final RemoteVersion remoteVersion =
            RemoteVersion.fromJson(result.data as Map<String, dynamic>);

        state = AsyncData(remoteVersion);
      } else {
        state = AsyncError(
            'Failed to fetch remote version ${result.statusMessage}',
            StackTrace.current);
      }
    } on DioException catch (e) {
      if (e.response?.data?['error'] != null) {
        state = AsyncError(
            'Error: ${e.response?.data?['error']}', StackTrace.current);
      } else {
        state = AsyncError(
            'Failed to fetch remote version\n${e.response?.data?['error'] ?? e.response?.statusCode}',
            StackTrace.current);
      }
    }
  }
}
