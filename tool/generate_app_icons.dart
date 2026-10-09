import 'dart:io';
import 'dart:typed_data';

// Simple uncompressed PNG encoder or direct mipmap image writer
void main() {
  final sizes = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
    'assets/images/app_launcher_icon.png': 512,
  };

  for (final entry in sizes.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    final pngBytes = generateHakoriPng(entry.value);
    file.writeAsBytesSync(pngBytes);
    // ignore: avoid_print
    print('Generated ${entry.key} (${entry.value}x${entry.value})');
  }
}

List<int> generateHakoriPng(int size) {
  final width = size;
  final height = size;
  final rawData = BytesBuilder();

  final cx = width / 2.0;
  final cy = height / 2.0;
  final rOuter = size * 0.45;
  final rInner = size * 0.39;
  final rCenter = size * 0.12;

  // Raw scanlines with RGBA
  for (int y = 0; y < height; y++) {
    rawData.addByte(0); // filter: none
    for (int x = 0; x < width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = (dx * dx + dy * dy);
      final rOuterSq = rOuter * rOuter;
      final rInnerSq = rInner * rInner;

      int r = 15, g = 23, b = 42, a = 255; // DarkBase background #0F172A

      if (dist <= rOuterSq && dist >= rInnerSq) {
        // Gold rim #D4A44C
        r = 212;
        g = 164;
        b = 76;
      } else if (dist < rInnerSq) {
        // Emerald background #0D7377
        r = 13;
        g = 115;
        b = 119;
        // Diamond / Star shape in Gold
        if ((dx.abs() + dy.abs()) < rCenter * 1.6) {
          r = 212;
          g = 164;
          b = 76;
        }
      }
      rawData.addByte(r);
      rawData.addByte(g);
      rawData.addByte(b);
      rawData.addByte(a);
    }
  }

  return encodePng(width, height, rawData.takeBytes());
}

List<int> encodePng(int width, int height, Uint8List rawRgbaScanlines) {
  final out = BytesBuilder();
  // PNG signature
  out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR
  final ihdr = BytesBuilder();
  ihdr.add(_uint32(width));
  ihdr.add(_uint32(height));
  ihdr.addByte(8); // bit depth
  ihdr.addByte(6); // color type RGBA
  ihdr.addByte(0); // compression
  ihdr.addByte(0); // filter
  ihdr.addByte(0); // interlace
  out.add(_chunk('IHDR', ihdr.takeBytes()));

  // IDAT (using zlib compression)
  final compressed = zlib.encode(rawRgbaScanlines);
  out.add(_chunk('IDAT', Uint8List.fromList(compressed)));

  // IEND
  out.add(_chunk('IEND', Uint8List(0)));

  return out.takeBytes();
}

List<int> _chunk(String type, Uint8List data) {
  final chunkBytes = BytesBuilder();
  chunkBytes.add(_uint32(data.length));
  final typeBytes = type.codeUnits;
  chunkBytes.add(typeBytes);
  chunkBytes.add(data);

  // CRC32 calculation over type and data
  final crcData = BytesBuilder();
  crcData.add(typeBytes);
  crcData.add(data);
  final crcVal = _calculateCrc32(crcData.takeBytes());
  chunkBytes.add(_uint32(crcVal));

  return chunkBytes.takeBytes();
}

List<int> _uint32(int value) {
  return [
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ];
}

int _calculateCrc32(Uint8List data) {
  final table = List<int>.generate(256, (i) {
    int c = i;
    for (int k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    }
    return c;
  });

  int crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc = table[(crc ^ byte) & 0xFF] ^ (crc >>> 8);
  }
  return (crc ^ 0xFFFFFFFF);
}
