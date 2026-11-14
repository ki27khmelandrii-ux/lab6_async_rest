import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/create_post_screen.dart';
import 'screens/future_vs_stream_screen.dart';
import 'screens/posts_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Дерево доступності завжди ввімкнене: у вебі елементи мають
  // ролі й підписи для екранних читачів і автоматизованих тестів.
  SemanticsBinding.instance.ensureSemantics();
  runApp(AsyncRestApp(api: ApiService()));
}

class AsyncRestApp extends StatelessWidget {
  const AsyncRestApp({super.key, required this.api});

  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ЛР6 · Async та REST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
      ),
      // pull-to-refresh мишею у веб-версії
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      home: HomeShell(api: api),
    );
  }
}

/// Нижня навігація між трьома екранами.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api});

  final ApiService api;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          PostsScreen(api: widget.api),
          CreatePostScreen(api: widget.api),
          // Екран порівняння створюється лише коли відкритий,
          // щоб потоки не працювали у фоні.
          if (_index == 2) const FutureVsStreamScreen() else const SizedBox(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Пости'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Новий пост'),
          NavigationDestination(icon: Icon(Icons.stream), label: 'Future/Stream'),
        ],
      ),
    );
  }
}
