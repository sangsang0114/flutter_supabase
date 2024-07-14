// lib/image/repository/image_repository.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exif/exif.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageRepository {
  final SupabaseClient _client;
  final Uuid _uuid = Uuid();

  ImageRepository(this._client);

  Future<Map<String, String>> uploadImage(File imageFile, int postId) async {
    final originalFileName = '${_uuid.v4()}.jpg';
    final resizedFileName = '${_uuid.v4()}.jpg';

    try {
      // Upload original image
      await _client.storage.from('images').upload(originalFileName, imageFile);
      final originalImageUrl = _client.storage.from('images').getPublicUrl(originalFileName);

      // Resize image
      final resizedImageFile = await _resizeImage(imageFile);

      // Upload resized image
      await _client.storage.from('images').upload(resizedFileName, resizedImageFile);
      final resizedImageUrl = _client.storage.from('images').getPublicUrl(resizedFileName);

      return {
        'original_url': originalImageUrl,
        'thumb_url': resizedImageUrl,
      };
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> saveImageMetadata(File imageFile, String originalUrl, String thumbUrl, int postId) async {
    try {
      final exifData = await _extractExifData(imageFile);
      final response = await _client.from('images').insert({
        'service_name': 'post',
        'service_id': postId,
        'original_url': originalUrl,
        'thumb_url': thumbUrl,
        'exif_data': exifData,
      }).select();

      if (response == null || response.isEmpty) {
        print('Error saving image metadata');
        throw Exception('Failed to save image metadata');
      }
    } catch (e) {
      print('Error saving image metadata: $e');
      throw Exception('Failed to save image metadata');
    }
  }

  Future<Map<String, dynamic>> fetchExifData(String imageUrl) async {
    try {
      final response = await _client
          .from('images')
          .select('exif_data')
          .eq('original_url', imageUrl)
          .single();

      if (response == null || response.isEmpty) {
        print('Error fetching EXIF data: No data found');
        throw Exception('Failed to fetch EXIF data');
      }

      return response['exif_data'] as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching EXIF data: $e');
      throw Exception('Failed to fetch EXIF data');
    }
  }

  Future<Map<String, dynamic>> _extractExifData(File imageFile) async {
    try {
      final tags = await readExifFromBytes(await imageFile.readAsBytes());

      final exifData = <String, dynamic>{};
      tags?.forEach((key, value) {
        exifData[key ?? 'unknown'] = value.toString();
      });

      return exifData;
    } catch (e) {
      print('Error extracting EXIF data: $e');
      return {};
    }
  }

  Future<File> _resizeImage(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, '${_uuid.v4()}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      minWidth: 1080,
      minHeight: 1440,
      quality: 85,
    );

    if (result == null) {
      throw Exception('Failed to resize image');
    }

    return result;
  }
}
