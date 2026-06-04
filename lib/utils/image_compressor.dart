import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// 图片压缩工具类
class ImageCompressor {
  /// 目标图片宽度（像素）
  static const int targetWidth = 300;

  /// 目标图片高度（像素）
  static const int targetHeight = 300;

  /// JPEG 压缩质量 (0-100)
  static const int jpegQuality = 85;

  /// 最大文件大小（字节）- 100KB
  static const int maxFileSize = 100 * 1024;

  /// 压缩图片
  /// [imageData] - 原始图片数据（Base64 字符串或字节数组）
  /// [isBase64] - 是否为 Base64 编码
  /// 返回压缩后的 Base64 字符串
  static Future<String?> compressImage(dynamic imageData, {bool isBase64 = true}) async {
    try {
      Uint8List? bytes;

      if (isBase64 && imageData is String) {
        // 处理 Data URL 格式 (data:image/xxx;base64,...)
        String base64String = imageData;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        bytes = base64Decode(base64String);
      } else if (imageData is Uint8List) {
        bytes = imageData;
      } else if (imageData is List<int>) {
        bytes = Uint8List.fromList(imageData);
      }

      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      // 解码图片
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        return null;
      }

      // 计算缩放比例，保持宽高比
      double scale = 1.0;
      if (originalImage.width > targetWidth || originalImage.height > targetHeight) {
        final widthScale = targetWidth / originalImage.width;
        final heightScale = targetHeight / originalImage.height;
        scale = widthScale < heightScale ? widthScale : heightScale;
      }

      // 缩放图片
      final newWidth = (originalImage.width * scale).round();
      final newHeight = (originalImage.height * scale).round();

      img.Image resizedImage;
      if (scale < 1.0) {
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.cubic,
        );
      } else {
        resizedImage = originalImage;
      }

      // 编码为 JPEG
      var compressedBytes = img.encodeJpg(resizedImage, quality: jpegQuality);

      // 如果仍然太大，降低质量再次压缩
      int currentQuality = jpegQuality;
      while (compressedBytes.length > maxFileSize && currentQuality > 30) {
        currentQuality -= 10;
        compressedBytes = img.encodeJpg(resizedImage, quality: currentQuality);
      }

      // 转换为 Base64
      final base64String = base64Encode(compressedBytes);

      // 返回 Data URL 格式
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('图片压缩失败: $e');
      return null;
    }
  }

  /// 检查图片是否需要压缩
  /// [imageData] - 图片数据（Base64 字符串）
  static bool needsCompression(String imageData) {
    try {
      String base64String = imageData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      final bytes = base64Decode(base64String);

      // 如果图片大于 100KB，需要压缩
      return bytes.length > maxFileSize;
    } catch (e) {
      return false;
    }
  }

  /// 获取图片信息
  /// [imageData] - 图片数据（Base64 字符串）
  static Map<String, dynamic>? getImageInfo(String imageData) {
    try {
      String base64String = imageData;
      String mimeType = 'image/jpeg';

      // 解析 Data URL
      if (imageData.contains(',')) {
        final parts = imageData.split(',');
        final header = parts.first;
        base64String = parts.last;

        // 提取 MIME 类型
        if (header.contains(':')) {
          final mimeMatch = RegExp(r'data:(.*?);').firstMatch(header);
          if (mimeMatch != null) {
            mimeType = mimeMatch.group(1) ?? 'image/jpeg';
          }
        }
      }

      final bytes = base64Decode(base64String);
      final image = img.decodeImage(bytes);

      if (image == null) {
        return null;
      }

      return {
        'width': image.width,
        'height': image.height,
        'size': bytes.length,
        'sizeKB': (bytes.length / 1024).toStringAsFixed(2),
        'mimeType': mimeType,
      };
    } catch (e) {
      print('获取图片信息失败: $e');
      return null;
    }
  }

  /// 批量压缩图片（用于版本更新迁移）
  /// [images] - 图片列表，每项包含 id 和 imageData
  /// 返回压缩后的图片列表
  static Future<List<Map<String, dynamic>>> batchCompress(
    List<Map<String, dynamic>> images,
  ) async {
    final results = <Map<String, dynamic>>[];

    for (final item in images) {
      final id = item['id'] as String?;
      final imageData = item['imageData'] as String?;

      if (id == null || imageData == null) {
        continue;
      }

      // 检查是否需要压缩
      if (!needsCompression(imageData)) {
        results.add({'id': id, 'imageData': imageData, 'compressed': false});
        continue;
      }

      // 压缩图片
      final compressed = await compressImage(imageData);
      if (compressed != null) {
        results.add({'id': id, 'imageData': compressed, 'compressed': true});
      } else {
        results.add({'id': id, 'imageData': imageData, 'compressed': false});
      }
    }

    return results;
  }
}
