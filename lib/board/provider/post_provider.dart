// board/provider/post_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase/image/model/image.dart';
import 'package:flutter_supabase/image/repository/image_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/post.dart';
import '../repository/post_repository.dart';


final postRepositoryProvider = Provider<PostRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  final imageRepository = ImageRepository(supabaseClient);
  return PostRepository(supabaseClient, imageRepository);
});

final postProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPosts();
});

class PostNotifier extends StateNotifier<List<Post>> {
  final PostRepository _repository;

  PostNotifier(this._repository) : super([]);

  Future<void> createPost(String title, String content, List<File> imageFiles) async {
    await _repository.createPost(title, content, imageFiles);
    state = await _repository.fetchPosts();
  }

  Future<List<Image>> fetchPostImages(int postId) async {
    return await _repository.fetchPostImages(postId);
  }
}

final postNotifierProvider = StateNotifierProvider<PostNotifier, List<Post>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostNotifier(repository);
});
