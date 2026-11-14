import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab6_async_rest/screens/create_post_screen.dart';
import 'package:lab6_async_rest/screens/posts_screen.dart';
import 'package:lab6_async_rest/services/api_service.dart';
import 'package:material_ui/material_ui.dart';

const _postsJson =
    '[{"userId": 1, "id": 1, "title": "Перший пост", "body": "Текст 1"},'
    ' {"userId": 1, "id": 2, "title": "Другий пост", "body": "Текст 2"}]';

const _utf8 = {'content-type': 'application/json; charset=utf-8'};

Widget _app(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('Список: індикатор завантаження, потім дані', (tester) async {
    final api = ApiService(
      client: MockClient((_) async => http.Response(_postsJson, 200, headers: _utf8)),
    );
    await tester.pumpWidget(_app(PostsScreen(api: api)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Перший пост'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Помилка сервера → кнопка «Повторити» → дані', (tester) async {
    var fail = true;
    final api = ApiService(
      client: MockClient((_) async =>
          fail ? http.Response('down', 503) : http.Response(_postsJson, 200, headers: _utf8)),
    );
    await tester.pumpWidget(_app(PostsScreen(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('Помилка сервера: 503'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Повторити'));
    await tester.pumpAndSettle();
    expect(find.text('Другий пост'), findsOneWidget);
  });

  testWidgets('POST: SnackBar з id нового поста', (tester) async {
    final api = ApiService(
      client: MockClient((request) async => http.Response(
            jsonEncode({...jsonDecode(request.body) as Map, 'id': 101}),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );
    await tester.pumpWidget(_app(CreatePostScreen(api: api)));
    await tester.enterText(find.byType(TextFormField).first, 'Тестовий пост');
    await tester.tap(find.text('Надіслати'));
    await tester.pumpAndSettle();

    expect(find.text('Пост створено на сервері: id = 101'), findsOneWidget);
  });
}
