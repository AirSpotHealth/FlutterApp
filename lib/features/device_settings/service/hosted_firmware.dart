import 'dart:io';

import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'slim_firmware_image.dart';

class HostedFirmware {
  static String checkUrl(
      String endpoint, DeviceModel model, String appVersion) {
    final parts = appVersion.split('.');
    final beta = parts.isNotEmpty && parts.last != '0';
    return Uri.parse(endpoint).replace(queryParameters: {
      'beta': '$beta',
      'app_version': appVersion,
      'device_model': model == DeviceModel.airspotSlim ? 'slim' : 'screen',
    }).toString();
  }

  static RemoteVersion parseResponse(Object? data, DeviceModel model) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid firmware response');
    }
    final release = RemoteVersion.fromJson(data);
    release.validateForDevice(model);
    return release;
  }

  static void checkConnectedModel(RemoteVersion release,
      {required bool hasSmpService}) {
    release.validateForDevice(
        hasSmpService ? DeviceModel.airspotSlim : DeviceModel.airspotScreen);
  }

  /// Validate the exact downloaded bytes before handing control to Bluetooth.
  /// The device remains responsible for verifying the product signature.
  static Future<void> updateSlim({
    required RemoteVersion release,
    required Directory temporaryDirectory,
    required Future<Response> Function(
            String url, String path, ProgressCallback onProgress)
        download,
    required ProgressCallback onProgress,
    required Future<void> Function(String path, SlimFirmwareImage image) update,
  }) async {
    release.validateForDevice(DeviceModel.airspotSlim);
    final directory = await temporaryDirectory.createTemp('slim-ota-');
    try {
      final file = File('${directory.path}/firmware.${release.fileFormat}');
      final response =
          await download(release.downloadUrl, file.path, onProgress);
      if (response.statusCode != 200) {
        throw const FormatException('Firmware download failed');
      }
      if (!await file.exists() ||
          await file.length() > SlimFirmwareImage.maxFileSize) {
        throw const FormatException('Missing or oversized firmware download');
      }
      final image =
          SlimFirmwareImage.fromFileBytes(await file.readAsBytes(), file.path);
      final expected =
          RemoteVersion.slimVersionParts(release.versionName).join('.');
      if (image.version != expected) {
        throw const FormatException(
            'Downloaded image version does not match the release');
      }
      await update(file.path, image);
    } finally {
      try {
        await directory.delete(recursive: true);
      } on FileSystemException {
        // Cleanup must not turn a verified device update into a reported failure.
        debugPrint('Could not remove temporary Slim firmware download');
      }
    }
  }

  static Future<Response> downloadSlim(
      String url, String path, ProgressCallback onProgress) async {
    final cancel = CancelToken();
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      // Signed storage URLs download directly; do not follow a downgrade redirect.
      followRedirects: false,
    ));
    try {
      return await dio.download(url, path, cancelToken: cancel,
          onReceiveProgress: (received, total) {
        if (received > SlimFirmwareImage.maxFileSize ||
            total > SlimFirmwareImage.maxFileSize) {
          cancel.cancel('Firmware file is too large');
          return;
        }
        onProgress(received, total);
      });
    } finally {
      dio.close();
    }
  }
}
