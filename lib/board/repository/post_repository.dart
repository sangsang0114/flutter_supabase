// board/repository/post_repository.dart
import 'dart:io';
import 'package:flutter_supabase/image/model/image.dart';
import 'package:flutter_supabase/image/repository/image_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/post.dart';

class PostRepository {
  final SupabaseClient _client;
  final ImageRepository _imageRepository;

  PostRepository(this._client, this._imageRepository);

  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select('id, title, content, created_at')
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      throw Exception('Failed to fetch posts');
    }

    final data = response as List<dynamic>;
    return data.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> createPost(String title, String content, List<File> imageFiles) async {
    final response = await _client.from('posts').insert({
      'title': title,
      'content': content,
    }).select();

    if (response.isEmpty) {
      throw Exception('Failed to create post');
    }

    final postId = response[0]['id'];

    for (var imageFile in imageFiles) {
      final urls = await _imageRepository.uploadImage(imageFile, postId);
      final originalUrl = urls['original_url'];
      final thumbUrl = urls['thumb_url'];

      await _imageRepository.saveImageMetadata(imageFile, originalUrl!, thumbUrl!, postId);
    }
  }

  Future<List<Image>> fetchPostImages(int postId) async {
    final response = await _client
        .from('images')
        .select()
        .eq('service_id', postId)
        .eq('service_name', 'post');

    if (response.isEmpty) {
      throw Exception('Failed to fetch images');
    }

    final data = response as List<dynamic>;
    return data.map((json) => Image.fromJson(json)).toList();
  }
}
