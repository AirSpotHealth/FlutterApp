import 'dart:async';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final firmwareRemoteVersionProvider = AsyncNotifierProvider.autoDispose<
    _FirmwareRemoteVersionNotifier,
    RemoteVersion?>(_FirmwareRemoteVersionNotifier.new);

class _FirmwareRemoteVersionNotifier
    extends AutoDisposeAsyncNotifier<RemoteVersion?> {
  final NetworkService _networkService = NetworkService.instance;

  @override
  FutureOr<RemoteVersion?> build() {
    fetchRemoteVersion();
    return future;
  }

  Future<void> fetchRemoteVersion() async {
    state = const AsyncLoading();

    try {
      String? currentVersion = (await PackageInfo.fromPlatform()).version;

      // if the last character is a 0, it's a production build
      // else it's a beta build
      bool beta = false;

      final List<String> parts = currentVersion.split('.');

      if (parts.isNotEmpty) {
        final String lastPart = parts.last;

        if (lastPart.isNotEmpty) {
          beta = lastPart != '0';
        }
      }

      debugPrint('Beta mode: $beta');

      final Response<dynamic> result = await _networkService.get(
          beta ? ApiEndpoints.versionCheckBeta : ApiEndpoints.versionCheck, {});

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
