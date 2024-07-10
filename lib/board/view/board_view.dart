import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

class BoardView extends StatelessWidget {
  final faker = Faker();

  @override
  Widget build(BuildContext context) {
    // 임의의 게시글 데이터 생성
    final List<Map<String, String>> posts = List.generate(10, (index) {
      return {
        'title': faker.lorem.sentence(),
        'content': faker.lorem.sentences(3).join(' '), // 여러 문장을 하나의 문자열로 결합
        'imageUrl': 'https://picsum.photos/200/300?random=$index', // Lorem Picsum 이미지 URL 사용
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Board View'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width, // 기기의 너비만큼 높이 설정
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                    child: Image.network(
                      post['imageUrl']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(post['content']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
