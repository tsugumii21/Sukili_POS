import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageCompressHelper {
  /// Compress an image file for menu item photos.
  /// Target: 600×600px max, 85% quality → typically 80–200 KB
  static Future<File> compressMenuItemImage(File file) async {
    return _compress(
      file: file,
      targetWidth: 600,
      targetHeight: 600,
      quality: 85,
      suffix: '_menu',
    );
  }

  /// Compress an image file for store logos.
  /// Target: 400×400px max, 90% quality → typically 50–150 KB
  static Future<File> compressStoreLogo(File file) async {
    return _compress(
      file: file,
      targetWidth: 400,
      targetHeight: 400,
      quality: 90,
      suffix: '_logo',
    );
  }

  /// Compress an image file for cashier avatars.
  /// Target: 300×300px max, 85% quality → typically 30–100 KB
  static Future<File> compressAvatar(File file) async {
    return _compress(
      file: file,
      targetWidth: 300,
      targetHeight: 300,
      quality: 85,
      suffix: '_avatar',
    );
  }

  static Future<File> _compress({
    required File file,
    required int targetWidth,
    required int targetHeight,
    required int quality,
    required String suffix,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final ext = path.extension(file.path).toLowerCase();
    final format = ext == '.png' ? CompressFormat.png : CompressFormat.jpeg;

    final targetPath = path.join(
      tempDir.path,
      '${path.basenameWithoutExtension(file.path)}$suffix${ext.isEmpty ? '.jpg' : ext}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: quality,
      format: format,
      keepExif: false, // strip metadata — reduces size + privacy
    );

    if (result == null) {
      // Compression failed — return original file as fallback
      return file;
    }

    final compressed = File(result.path);

    // Log size reduction in debug mode
    assert(() {
      final originalKb = file.lengthSync() / 1024;
      final compressedKb = compressed.lengthSync() / 1024;
      final saving = ((1 - compressedKb / originalKb) * 100).toStringAsFixed(1);
      debugPrint('ImageCompress: ${originalKb.toStringAsFixed(1)} KB '
          '→ ${compressedKb.toStringAsFixed(1)} KB ($saving% saved)');
      return true;
    }());

    return compressed;
  }

  /// Clean up compressed temp files after upload completes
  static Future<void> deleteTempFile(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore cleanup errors — temp files are auto-cleared eventually
    }
  }
}
