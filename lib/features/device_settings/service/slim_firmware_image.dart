import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

/// Validates the MCUboot container. The device verifies the product signature.
class SlimFirmwareImage {
  SlimFirmwareImage._(this.bytes, this.hash, this.version);

  final Uint8List bytes;
  final Uint8List hash;
  final String version;
  static const maxImageSize = 664 * 1024;
  static const maxFileSize = 2 * 1024 * 1024;

  factory SlimFirmwareImage.fromFileBytes(Uint8List bytes, String name) {
    if (bytes.length > maxFileSize) {
      throw const FormatException('Firmware file is too large');
    }
    if (name.toLowerCase().endsWith('.zip')) {
      final archive = ZipDecoder().decodeBytes(bytes);
      final bins = archive.files
          .where((f) =>
              f.isFile &&
              !f.name.split('/').contains('__MACOSX') &&
              f.name.toLowerCase().endsWith('.bin'))
          .toList();
      const names = {
        'app_update.bin',
        'application.signed.bin',
        'zephyr.signed.bin',
        'airspot_slim.signed.bin',
      };
      if (bins.length != 1 ||
          !names.contains(bins.single.name.split('/').last)) {
        throw const FormatException(
            'Select a DFU ZIP containing exactly one signed application image');
      }
      if (bins.single.size > maxImageSize) {
        throw const FormatException('Firmware image is too large');
      }
      final raw = bins.single.readBytes();
      if (raw == null) throw const FormatException('Empty firmware image');
      return SlimFirmwareImage.parse(raw);
    }
    if (!name.toLowerCase().endsWith('.bin')) {
      throw const FormatException('Select a signed .bin or DFU .zip');
    }
    return SlimFirmwareImage.parse(bytes);
  }

  factory SlimFirmwareImage.parse(Uint8List raw) {
    Never invalid(String reason) =>
        throw FormatException('Invalid firmware: $reason');
    if (raw.length < 32 || raw.length > maxImageSize) invalid('image size');
    final data = ByteData.sublistView(raw);
    int u16(int offset) => data.getUint16(offset, Endian.little);
    int u32(int offset) => data.getUint32(offset, Endian.little);
    if (u32(0) != 0x96f3b83d) invalid('MCUboot header');
    final headerSize = u16(8);
    final protectedSize = u16(10);
    final bodySize = u32(12);
    if (headerSize < 32 || bodySize == 0 || u32(16) != 0) {
      invalid('unsupported application header');
    }
    final bodyEnd = headerSize + bodySize;
    final hashEnd = bodyEnd + protectedSize;
    if (hashEnd + 4 > raw.length) invalid('truncated body or TLV area');

    // Validate every TLV boundary before retaining it in the upload.
    void checkEntries(int start, int end) {
      var offset = start;
      while (offset < end) {
        if (offset + 4 > end) invalid('truncated TLV header');
        final length = u16(offset + 2);
        offset += 4 + length;
        if (offset > end) invalid('truncated TLV value');
      }
    }

    if (protectedSize != 0) {
      if (protectedSize < 4 ||
          u16(bodyEnd) != 0x6908 ||
          u16(bodyEnd + 2) != protectedSize) {
        invalid('protected TLV area');
      }
      checkEntries(bodyEnd + 4, hashEnd);
    }
    if (u16(hashEnd) != 0x6907) invalid('missing signature trailer');
    final trailerSize = u16(hashEnd + 2);
    final imageEnd = hashEnd + trailerSize;
    if (trailerSize < 4 || imageEnd > raw.length) {
      invalid('truncated signature trailer');
    }
    checkEntries(hashEnd + 4, imageEnd);
    Uint8List? imageHash;
    var signatureFound = false;
    for (var offset = hashEnd + 4; offset < imageEnd;) {
      final type = u16(offset);
      final length = u16(offset + 2);
      if (type == 0x10) {
        if (length != 32 || imageHash != null) invalid('SHA-256 TLV');
        imageHash = Uint8List.sublistView(raw, offset + 4, offset + 4 + length);
      }
      if (type == 0x22) {
        if (signatureFound || length < 8 || length > 72) {
          invalid('ECDSA signature TLV');
        }
        signatureFound = true;
      }
      offset += 4 + length;
    }
    if (!signatureFound || imageHash == null) invalid('unsigned application');
    final digest = sha256.convert(Uint8List.sublistView(raw, 0, hashEnd));
    if (digest.toString() !=
        imageHash.map((b) => b.toRadixString(16).padLeft(2, '0')).join()) {
      invalid('image hash mismatch');
    }
    if (raw.skip(imageEnd).any((b) => b != 0xff)) {
      invalid('unexpected trailing data');
    }
    return SlimFirmwareImage._(
      Uint8List.fromList(raw.sublist(0, imageEnd)),
      Uint8List.fromList(imageHash),
      '${raw[20]}.${raw[21]}.${u16(22)}',
    );
  }
}
