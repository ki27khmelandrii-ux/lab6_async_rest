import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab6_async_rest/models/post.dart';
import 'package:lab6_async_rest/services/api_exception.dart';
import 'package:lab6_async_rest/services/api_service.dart';

const _postsJson = '''
[{"userId": 1, "id": 1, "title": "sunt aut facere", "body": "quia et suscipit"},
 {"userId": 1, "id": 2, "title": "qui est esse", "body": "est rerum tempore"}]
''';

void main() {
  test('Post.fromJson розбирає JSON-об\'єкт', () {
    final post = Post.fromJson(
      {'userId': 3, 'id': 7, 'title': 'Заголовок', 'body': 'Текст'},
    );
    expect(post.id, 7);
    expect(post.userId, 3);
    expect(post.title, 'Заголовок');
  });

  group('getPosts', () {
    test('200 → список постів', () async {
      final api = ApiService(
        client: MockClient((request) async {
          expect(request.url.path, '/posts');
          return http.Response(_postsJson, 200);
        }),
      );
      final posts = await api.getPosts();
      expect(posts.map((p) => p.id), [1, 2]);
    });

    test('500 → ApiException з кодом статусу', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('error', 500)),
      );
      expect(
        api.getPosts(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('SocketException → «Немає з\'єднання з інтернетом»', () async {
      final api = ApiService(
        client: MockClient((_) => throw const SocketException('Failed host lookup')),
      );
      expect(
        api.getPosts(),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('Немає з\'єднання'))),
      );
    });

    test('TimeoutException → повідомлення про тайм-аут', () async {
      final api = ApiService(
        timeout: const Duration(milliseconds: 50),
        client: MockClient((_) async {
          await Future.delayed(const Duration(milliseconds: 300));
          return http.Response(_postsJson, 200);
        }),
      );
      expect(
        api.getPosts(),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('час очікування'))),
      );
    });
  });

  group('createPost', () {
    test('201 → пост із сервера, JSON-тіло та Content-Type', () async {
      final api = ApiService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'], startsWith('application/json'));
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {'title': 'Привіт', 'body': 'Текст', 'userId': 1});
          return http.Response(
            jsonEncode({...body, 'id': 101}),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final post = await api.createPost('Привіт', 'Текст');
      expect(post.id, 101);
      expect(post.title, 'Привіт');
    });

    test('400 → ApiException', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('bad', 400)),
      );
      expect(api.createPost('a', 'b'), throwsA(isA<ApiException>()));
    });
  });
}
