// board/model/post.dart
class Post {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.imageUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }
}
