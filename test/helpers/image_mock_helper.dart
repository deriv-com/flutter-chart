import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal 1x1 transparent PNG image as bytes.
///
/// This is used to mock image assets during tests to avoid
/// asset loading errors.
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
  0x49, 0x48, 0x44, 0x52, // IHDR
  0x00, 0x00, 0x00, 0x01, // width: 1
  0x00, 0x00, 0x00, 0x01, // height: 1
  0x08, 0x06, // bit depth: 8, color type: RGBA
  0x00, 0x00, 0x00, // compression, filter, interlace
  0x1F, 0x15, 0xC4, 0x89, // CRC
  0x00, 0x00, 0x00, 0x0A, // IDAT chunk length
  0x49, 0x44, 0x41, 0x54, // IDAT
  0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, // compressed data
  0x0D, 0x0A, 0x2D, 0xB4, // CRC
  0x00, 0x00, 0x00, 0x00, // IEND chunk length
  0x49, 0x45, 0x4E, 0x44, // IEND
  0xAE, 0x42, 0x60, 0x82, // CRC
]);

/// Sets up mock asset loading for image assets during tests.
///
/// This should be called in [setUpAll] or [setUp] before running widget tests
/// that load image assets.
void setUpImageAssetMocking() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create an empty asset manifest encoded using StandardMessageCodec.
  // The format expected is Map<String, List<Object>> where each list contains
  // variant information.
  final Map<String, List<Object>> emptyManifest = <String, List<Object>>{};
  final ByteData manifestBytes =
      const StandardMessageCodec().encodeMessage(emptyManifest)!;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (message == null) {
      return null;
    }

    // Decode the asset key from the message.
    final String assetKey = String.fromCharCodes(
      message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
    );

    // Return mock asset manifest for manifest requests.
    if (assetKey == 'AssetManifest.bin') {
      return manifestBytes;
    }

    // Return empty JSON for AssetManifest.json (fallback format).
    if (assetKey == 'AssetManifest.json') {
      final Uint8List jsonBytes = Uint8List.fromList('{}'.codeUnits);
      return ByteData.view(jsonBytes.buffer);
    }

    // Return mock image data for any image asset requests.
    if (assetKey.endsWith('.png') ||
        assetKey.endsWith('.jpg') ||
        assetKey.endsWith('.jpeg') ||
        assetKey.endsWith('.gif') ||
        assetKey.endsWith('.webp')) {
      return ByteData.view(kTransparentImage.buffer);
    }

    // Return null for other assets to use default behavior.
    return null;
  });
}

/// Tears down the mock asset loading.
///
/// This should be called in [tearDownAll] or [tearDown] after tests complete.
void tearDownImageAssetMocking() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', null);
}
