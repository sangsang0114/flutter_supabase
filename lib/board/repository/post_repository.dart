import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/post.dart';

class PostRepository {
  final SupabaseClient _client;

  PostRepository(this._client);

  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      throw Exception('Failed to fetch posts');
    }

    final data = response as List<dynamic>;
    return data.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> createPost(String title, String content) async {
    final response = await _client.from('posts').insert({
      'title': title,
      'content': content,
    });
  }
}
