// board/provider/post_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../image/repository/image_repository.dart';
import '../model/post.dart';
import '../repository/post_repository.dart';
import 'dart:io';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  final imageRepository = ImageRepository(supabaseClient);
  return PostRepository(supabaseClient, imageRepository);
});

class PostNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final PostRepository _repository;

  PostNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final posts = await _repository.fetchPosts();
      for (var post in posts) {
        final imageUrls = await _repository.fetchPostImages(post.id);
        post.imageUrls.addAll(imageUrls);
      }
      state = AsyncValue.data(posts);
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> createPost(String title, String content, List<File> images) async {
    try {
      await _repository.createPost(title, content, images);
      fetchPosts();
    } catch (e) {
      print('Error creating post: $e');
    }
  }
}

final postNotifierProvider = StateNotifierProvider<PostNotifier, AsyncValue<List<Post>>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostNotifier(repository);
});
