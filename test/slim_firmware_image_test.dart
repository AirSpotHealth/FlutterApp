import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:airspothealth/features/device_settings/service/slim_firmware_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'slim_test_helpers.dart';

void main() {
  test('preserves protected TLVs and trims only FF padding', () {
    final original = signedImage(protected: true);
    final image =
        SlimFirmwareImage.parse(signedImage(protected: true, padding: 64));
    expect(image.bytes, original);
    expect(image.version, '0.14.6');
  });
  test('rejects missing, truncated and malformed signature trailers', () {
    final valid = signedImage();
    for (final length in [0, 31, 48, 50, valid.length - 1]) {
      expect(
          () => SlimFirmwareImage.parse(
              Uint8List.fromList(valid.take(length).toList())),
          throwsFormatException);
    }
    final unsigned = signedImage();
    ByteData.sublistView(unsigned).setUint16(88, 0x99, Endian.little);
    expect(() => SlimFirmwareImage.parse(unsigned), throwsFormatException);
    final brokenProtected = signedImage(protected: true)..[50] = 11;
    expect(
        () => SlimFirmwareImage.parse(brokenProtected), throwsFormatException);
  });
  test('rejects corrupted content and unexpected non-padding suffix', () {
    expect(() => SlimFirmwareImage.parse(signedImage()..[32] = 1),
        throwsFormatException);
    final suffix = signedImage(padding: 1)..last = 0;
    expect(() => SlimFirmwareImage.parse(suffix), throwsFormatException);
  });
  Uint8List zip(List<String> names) {
    final archive = Archive();
    for (final name in names) {
      final raw = signedImage();
      archive.addFile(ArchiveFile(name, raw.length, raw));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  test(
      'accepts production filename and rejects ambiguous or unsigned ZIP choices',
      () {
    expect(
        SlimFirmwareImage.fromFileBytes(zip(['app_update.bin']), 'dfu.zip')
            .version,
        '0.14.6');
    for (final names in [
      <String>[],
      ['zephyr.bin'],
      ['bootloader.bin'],
      ['app_update.bin', 'application.signed.bin'],
      ['a/app_update.bin', 'b/app_update.bin']
    ]) {
      expect(() => SlimFirmwareImage.fromFileBytes(zip(names), 'dfu.zip'),
          throwsFormatException);
    }
  });
  final package = Platform.environment['AIRSPOT_SLIM_DFU'];
  test('recorded production package matches qualified image hash', () async {
    final image = SlimFirmwareImage.fromFileBytes(
        await File(package!).readAsBytes(), package);
    expect(image.version, '0.14.6');
    expect(image.hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        '6631263b902886fd7f79a756b1c6ba7e76f25375a7765afd5a6fa4c03254214f');
  },
      skip: package == null
          ? 'Set AIRSPOT_SLIM_DFU to the qualified production ZIP'
          : false);
}
