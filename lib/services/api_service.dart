import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import 'api_exception.dart';
import 'platform/socket_exception_web.dart'
    if (dart.library.io) 'platform/socket_exception_io.dart';

/// Сервіс для роботи з REST API jsonplaceholder.typicode.com.
class ApiService {
  ApiService({
    http.Client? client,
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  /// GET /posts — список постів.
  Future<List<Post>> getPosts() => _guard(() async {
        final response = await _client
            .get(Uri.parse('$baseUrl/posts'))
            .timeout(timeout);

        if (response.statusCode != 200) {
          throw ApiException(
            'Помилка сервера: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
      });

  /// POST /posts — створення нового поста.
  Future<Post> createPost(String title, String body) => _guard(() async {
        final response = await _client
            .post(
              Uri.parse('$baseUrl/posts'),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
            )
            .timeout(timeout);

        if (response.statusCode != 201) {
          throw ApiException(
            'Не вдалося створити запис (код ${response.statusCode})',
            statusCode: response.statusCode,
          );
        }
        return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      });

  /// Перетворює низькорівневі винятки мережі на ApiException
  /// з повідомленням для користувача.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw const ApiException('Немає з\'єднання з інтернетом');
    } on TimeoutException {
      throw const ApiException('Сервер не відповідає: минув час очікування');
    } on http.ClientException {
      throw const ApiException('Не вдалося з\'єднатися з сервером');
    } on FormatException {
      throw const ApiException('Сервер повернув некоректні дані');
    }
  }

  void dispose() => _client.close();
}
