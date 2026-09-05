import 'dart:typed_data';
import 'package:crypto/crypto.dart';

List<int> frame(int command, List<int> payload, {int? length}) {
  final bytes = [0xff, 0xaa, command, length ?? payload.length, ...payload];
  return [...bytes, bytes.fold<int>(0, (a, b) => a + b) & 0xff];
}

/// Synthetic container for boundary tests, never a production fallback image.
Uint8List signedImage({bool protected = false, int padding = 0}) {
  final protectedSize = protected ? 12 : 0;
  final hashEnd = 32 + 16 + protectedSize;
  final size = hashEnd + 4 + 36 + 74;
  final raw = Uint8List(size + padding);
  final b = ByteData.sublistView(raw);
  b.setUint32(0, 0x96f3b83d, Endian.little);
  b.setUint16(8, 32, Endian.little);
  b.setUint16(10, protectedSize, Endian.little);
  b.setUint32(12, 16, Endian.little);
  raw[21] = 14;
  b.setUint16(22, 6, Endian.little);
  if (protected) {
    b.setUint16(48, 0x6908, Endian.little);
    b.setUint16(50, 12, Endian.little);
    b.setUint16(52, 0x50, Endian.little);
    b.setUint16(54, 4, Endian.little);
  }
  b.setUint16(hashEnd, 0x6907, Endian.little);
  b.setUint16(hashEnd + 2, 114, Endian.little);
  b.setUint16(hashEnd + 4, 0x10, Endian.little);
  b.setUint16(hashEnd + 6, 32, Endian.little);
  raw.setRange(
      hashEnd + 8, hashEnd + 40, sha256.convert(raw.sublist(0, hashEnd)).bytes);
  b.setUint16(hashEnd + 40, 0x22, Endian.little);
  b.setUint16(hashEnd + 42, 70, Endian.little);
  raw.fillRange(size, raw.length, 0xff);
  return raw;
}
