// board/repository/post_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../image/repository/image_repository.dart';
import '../model/post.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class PostRepository {
  final SupabaseClient _client;
  final ImageRepository _imageRepository;
  final Uuid _uuid = Uuid();

  PostRepository(this._client, this._imageRepository);

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<void> createPost(String title, String content, List<File> images) async {
    try {
      final response = await _client.from('posts').insert({
        'title': title,
        'content': content,
      }).select();

      final postId = response[0]['id'];

      for (final image in images) {
        final imageUrl = await _imageRepository.uploadImage(image, postId);
        await _imageRepository.saveImageMetadata(imageUrl, postId);
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<String>> fetchPostImages(int postId) async {
    try {
      final response = await _client
          .from('images')
          .select('original_url')
          .eq('service_id', postId)
          .eq('service_name', 'post');

      final data = response as List<dynamic>;
      return data.map((json) => json['original_url'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch post images: $e');
    }
  }

  Future<Map<String, dynamic>> fetchExifData(String imageUrl) async {
    return await _imageRepository.fetchExifData(imageUrl);
  }
}
