import 'package:material_ui/material_ui.dart';

import '../models/post.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../widgets/error_view.dart';

/// Список постів: GET-запит, FutureBuilder, Retry та pull-to-refresh.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key, required this.api});

  final ApiService api;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // Future зберігається в полі стану: build() його лише читає,
  // тому перебудова екрана не запускає новий запит.
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = widget.api.getPosts();
  }

  /// Кнопка «Повторити» після помилки.
  void _retry() {
    setState(() {
      _postsFuture = widget.api.getPosts();
    });
  }

  /// Pull-to-refresh: новий Future присвоюється в setState(),
  /// щоб FutureBuilder підписався на нього й перебудувався.
  Future<void> _refresh() async {
    setState(() {
      _postsFuture = widget.api.getPosts();
    });
    try {
      await _postsFuture;
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пости · GET /posts')),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // 1. Очікування (перше завантаження або повтор після помилки)
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Завантаження постів...'),
                ],
              ),
            );
          }
          // 2. Помилка
          if (snapshot.hasError) {
            return ErrorView(
              message: '${snapshot.error}',
              onRetry: _retry,
            );
          }
          // 3. Дані
          final posts = snapshot.data ?? const <Post>[];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _PostTile(post: posts[index]),
            ),
          );
        },
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('${post.id}')),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}
