// lib/image/repository/image_repository.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exif/exif.dart';

class ImageRepository {
  final SupabaseClient _client;

  ImageRepository(this._client);

  Future<String> uploadImage(File imageFile, int postId) async {
    final fileName = 'post_$postId${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final response = await _client.storage.from('images').upload(fileName, imageFile);
      final imageUrl = _client.storage.from('images').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> saveImageMetadata(String imageUrl, int postId) async {
    try {
      final exifData = await _extractExifData(imageUrl);
      final response = await _client.from('images').insert({
        'service_name': 'post',
        'service_id': postId,
        'original_url': imageUrl,
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

  Future<Map<String, dynamic>> _extractExifData(String imageUrl) async {
    try {
      final file = await _downloadImage(imageUrl);
      final tags = await readExifFromBytes(await file.readAsBytes());

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

  Future<File> _downloadImage(String imageUrl) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(imageUrl));
    final response = await request.close();
    final file = File('${Directory.systemTemp.path}/temp_image.jpg');
    await response.pipe(file.openWrite());
    return file;
  }
}
