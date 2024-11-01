import 'dart:async';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
      final Response<dynamic> result = await _networkService
          .get(ApiEndpoints.versionCheck, {'system': "2", 'software': "2"});

      if (result.statusCode == 200) {
        final RemoteVersion remoteVersion =
            RemoteVersion.fromJson(result.data['data'] as Map<String, dynamic>);

        debugPrint('Remote Version: ${remoteVersion.toString()}');

        state = AsyncData(remoteVersion);
      } else {
        debugPrint('Error (${result.statusCode}): ${result.statusMessage}');
        state = AsyncError(
            'Failed to fetch remote version ${result.statusMessage}',
            StackTrace.current);
      }
    } on DioException catch (e) {
      debugPrint('Version Update Check Error: $e');
      state = AsyncError(
          'Failed to fetch remote version\nError Code: ${e.response?.statusCode}',
          StackTrace.current);
    }
  }
}
