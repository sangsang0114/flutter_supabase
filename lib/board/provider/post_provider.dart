// board/provider/post_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/post.dart';
import '../repository/post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final supabaseClient = Supabase.instance.client;
  return PostRepository(supabaseClient);
});

final postProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPosts();
});
