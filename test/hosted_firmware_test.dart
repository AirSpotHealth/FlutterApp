import 'dart:io';
import 'dart:typed_data';

import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/service/hosted_firmware.dart';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'slim_test_helpers.dart';

Map<String, dynamic> metadata({String model = 'slim', String format = 'bin'}) =>
    {
      'id': 'release-id',
      'version_name': '0.14.6',
      'available_for': 'iOS, Android',
      'is_active': false,
      'file_url': 'https://storage.example/signed/download?token=test',
      'created_at': '2026-09-05',
      'require_erase': false,
      'device_model': model,
      'file_format': format,
    };

void main() {
  for (final model in [
    DeviceModel.airspotScreen,
    DeviceModel.airspotSlim,
    DeviceModel.unknown
  ]) {
    test('check URL isolates $model and retains the app beta rule', () {
      for (final version in ['3.8.0', '3.8.4']) {
        final url = Uri.parse(HostedFirmware.checkUrl(
            'https://update.example/api/firmware', model, version));
        expect(url.queryParameters['device_model'],
            model == DeviceModel.airspotSlim ? 'slim' : 'screen');
        expect(url.queryParameters['app_version'], version);
        expect(
            url.queryParameters['beta'], version == '3.8.0' ? 'false' : 'true');
      }
    });
  }
  test(
      'accepts legacy Screen metadata and preserves optional metadata through copying',
      () {
    final legacy = metadata(model: 'screen')
      ..remove('device_model')
      ..remove('file_format');
    final screen =
        HostedFirmware.parseResponse(legacy, DeviceModel.airspotScreen);
    expect(screen.deviceModel, isNull);
    expect(screen.copyWith(), screen);
    final slim =
        HostedFirmware.parseResponse(metadata(), DeviceModel.airspotSlim);
    expect(RemoteVersion.fromJson(slim.copyWith().toJson()), slim);
  });
  test(
      'rejects malformed responses and cross-model metadata before offering an update',
      () {
    final invalid = <Object?>[
      null,
      '<html>Error</html>',
      <String, dynamic>{},
      metadata()..['file_url'] = null,
      metadata()..['file_url'] = '',
      metadata()..['file_url'] = 'http://storage.example/image',
      metadata()..['file_url'] = 'https://user:pass@storage.example/image',
      metadata()..['version_name'] = 'invalid',
      metadata()..['version_name'] = '0.14.999999',
      metadata()..['device_model'] = null,
      metadata()..['device_model'] = 'screen',
      metadata()..['device_model'] = 'hub',
      metadata()..['file_format'] = null,
      metadata()..['file_format'] = 'hex',
      metadata()..['is_active'] = 'true',
      metadata()..['require_erase'] = 1,
      metadata()..['change_log'] = <String>[],
    ];
    for (final data in invalid) {
      expect(() => HostedFirmware.parseResponse(data, DeviceModel.airspotSlim),
          throwsFormatException);
    }
    expect(
        () =>
            HostedFirmware.parseResponse(metadata(), DeviceModel.airspotScreen),
        throwsFormatException);
  });
  test('connected SMP identity must match hosted release in both directions',
      () {
    final slim = RemoteVersion.fromJson(metadata());
    final screen =
        RemoteVersion.fromJson(metadata(model: 'screen', format: 'zip'));
    HostedFirmware.checkConnectedModel(slim, hasSmpService: true);
    HostedFirmware.checkConnectedModel(screen, hasSmpService: false);
    expect(() => HostedFirmware.checkConnectedModel(slim, hasSmpService: false),
        throwsFormatException);
    expect(
        () => HostedFirmware.checkConnectedModel(screen, hasSmpService: true),
        throwsFormatException);
  });
  test(
      'Slim versions compare in order, without offering equal or older firmware',
      () {
    final release = RemoteVersion.fromJson(metadata());
    expect(release.isVersionGreaterThanCurrentVersion('0.14.5'), isTrue);
    for (final version in [
      '0.14.6',
      'v0.14.6',
      '0.15.0',
      '1.0.0',
      'unknown',
      null
    ]) {
      expect(release.isVersionGreaterThanCurrentVersion(version), isFalse);
    }
  });

  late Directory temporary;
  setUp(() async =>
      temporary = await Directory.systemTemp.createTemp('hosted-ota-test-'));
  tearDown(() async => temporary.delete(recursive: true));

  for (final format in ['bin', 'zip']) {
    test(
        'downloads $format, validates bytes before transfer, and cleans up after success',
        () async {
      final image = signedImage();
      final archive = Archive()
        ..addFile(ArchiveFile('app_update.bin', image.length, image));
      final bytes = format == 'bin'
          ? image
          : Uint8List.fromList(ZipEncoder().encode(archive));
      var updated = false;
      await HostedFirmware.updateSlim(
        release: RemoteVersion.fromJson(metadata(format: format)),
        temporaryDirectory: temporary,
        download: (url, path, progress) async {
          expect(path.endsWith('.$format'), isTrue);
          expect(url, metadata()['file_url']);
          await File(path).writeAsBytes(bytes);
          progress(bytes.length, bytes.length);
          return Response(
              requestOptions: RequestOptions(path: url), statusCode: 200);
        },
        onProgress: (_, __) {},
        update: (path, firmware) async {
          expect(await File(path).exists(), isTrue);
          expect(firmware.version, '0.14.6');
          expect(firmware.bytes, image);
          updated = true;
        },
      );
      expect(updated, isTrue);
      expect(await temporary.list().toList(), isEmpty);
    });
  }
  for (final failure in [
    'network',
    'http',
    'missing',
    'invalid',
    'oversized',
    'wrong version',
    'model mismatch',
    'transfer'
  ]) {
    test('$failure fails safely and removes partial downloads', () async {
      var transferStarted = false;
      await expectLater(
          HostedFirmware.updateSlim(
            release: RemoteVersion.fromJson(metadata()
              ..['version_name'] =
                  failure == 'wrong version' ? '0.14.7' : '0.14.6'),
            temporaryDirectory: temporary,
            download: (url, path, progress) async {
              if (failure != 'missing') {
                await File(path).writeAsBytes(failure == 'invalid'
                    ? [1, 2, 3]
                    : failure == 'oversized'
                        ? Uint8List(2 * 1024 * 1024 + 1)
                        : signedImage());
              }
              if (failure == 'network') {
                throw const SocketException('test failure');
              }
              return Response(
                  requestOptions: RequestOptions(path: url),
                  statusCode: failure == 'http' ? 403 : 200);
            },
            onProgress: (_, __) {},
            update: (_, __) async {
              if (failure == 'model mismatch') {
                HostedFirmware.checkConnectedModel(
                    RemoteVersion.fromJson(metadata()),
                    hasSmpService: false);
              }
              transferStarted = true;
              throw StateError('transfer failed');
            },
          ),
          throwsA(anything));
      expect(transferStarted, failure == 'transfer');
      expect(await temporary.list().toList(), isEmpty);
    });
  }
}
