import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  // Convert Uint8List to File
  static Future<File> uint8ListToFile(Uint8List bytes, {String? fileName}) async {
    // Get temporary directory
    final directory = await getTemporaryDirectory();

    // Create file name
    final String filePath = fileName != null
        ? '${directory.path}/$fileName'
        : '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Write bytes to file
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    return file;
  }

  // Convert Uint8List to File with specific extension
  static Future<File> uint8ListToFileWithExtension(
      Uint8List bytes, {
        String extension = 'jpg',
        String? prefix = 'image',
      }) async {
    final directory = await getTemporaryDirectory();
    final String filePath =
        '${directory.path}/${prefix ?? 'image'}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    return File(filePath)..writeAsBytesSync(bytes);
  }

  // Check if file exists and return it, otherwise create from bytes
  static Future<File> getFileFromBytesOrPath({
    Uint8List? bytes,
    String? filePath,
    String? fileName,
  }) async {
    if (filePath != null && await File(filePath).exists()) {
      return File(filePath);
    }

    if (bytes != null && bytes.isNotEmpty) {
      return await uint8ListToFile(bytes, fileName: fileName);
    }

    // Return default image if both are null/empty
    return await getDefaultImageFile();
  }

  // Get default image as File
  static Future<File> getDefaultImageFile() async {
    final defaultBytes = await getDefaultImage();
    return await uint8ListToFile(defaultBytes, fileName: 'default_pastry.jpg');
  }

  // Get default image bytes (from your existing code)
  static Future<Uint8List> getDefaultImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/Images/default_pastry_img.jpg');
      return data.buffer.asUint8List();
    } catch (e) {
      // Fallback: create a simple placeholder
      return Uint8List.fromList(List.generate(100, (index) => index % 256));
    }
  }
}