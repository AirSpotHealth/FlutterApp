import 'dart:async';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firmwareRemoteVersionProvider =
    AsyncNotifierProvider.autoDispose<_FirmwareRemoteVersionNotifier, String>(
        _FirmwareRemoteVersionNotifier.new);

class _FirmwareRemoteVersionNotifier extends AutoDisposeAsyncNotifier<String> {
  final NetworkService _networkService = NetworkService.instance;

  @override
  FutureOr<String> build() {
    return '--';
  }

  Future<void> fetchRemoteVersion() async {
    state = const AsyncLoading();

    try {
      final Response<dynamic> result = await _networkService
          .get(ApiEndpoints.versionCheck, {'system': "2", 'software': "2"});

      if (result.statusCode == 200) {
        final RemoteVersion remoteVersion =
            RemoteVersion.fromJson(result.data['data'] as Map<String, dynamic>);

        state = AsyncData(remoteVersion.versionId);
      } else {
        debugPrint('Version Update Check Error: ${result.data}');
        state =
            AsyncError('Failed to fetch remote version', StackTrace.current);
      }
    } catch (e) {
      debugPrint('Version Update Check Error: $e');
      state = AsyncError('Failed to fetch remote version', StackTrace.current);
    }
  }
}
