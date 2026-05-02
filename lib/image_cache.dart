import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

class CrossPlatformImageCache {
  static final _dio = Dio();
  static final _cacheManager = DefaultCacheManager();

  static Future<Uint8List?> getCachedOrUpdatedImage(String imageUrl) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);

      if (fileInfo != null) {
        final response = await _dio.head(
          imageUrl,
          options: Options(validateStatus: (_) => true),
        );

        final remoteModified = response.headers.value('last-modified');
        final localModified = fileInfo.validTill;

        if (remoteModified != null) {
          final remoteTime = DateTime.tryParse(remoteModified);
          if (remoteTime != null && remoteTime.isAfter(localModified)) {
            final newFile = await _cacheManager.downloadFile(imageUrl);
            return newFile.file.readAsBytes();
          }
        }
        return await fileInfo.file.readAsBytes();
      } else {
        final newFile = await _cacheManager.downloadFile(imageUrl);
        return await newFile.file.readAsBytes();
      }
    } catch (e) {
      debugPrint('⚠️ Image Cache Error: $e');
      return null;
    }
  }
}
