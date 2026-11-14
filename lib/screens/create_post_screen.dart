import 'package:material_ui/material_ui.dart';

import '../models/post.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';

/// Створення поста: POST-запит із JSON-тілом.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.api});

  final ApiService api;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;
  Post? _created;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    try {
      final post = await widget.api.createPost(
        _titleCtrl.text.trim(),
        _bodyCtrl.text.trim(),
      );
      setState(() => _created = post);
      messenger.showSnackBar(
        SnackBar(content: Text('Пост створено на сервері: id = ${post.id}')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return Scaffold(
      appBar: AppBar(title: const Text('Новий пост · POST /posts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введіть заголовок' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Текст',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_sending ? 'Надсилання...' : 'Надіслати'),
          ),
          if (created != null) ...[
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${created.id}')),
                title: Text(created.title),
                subtitle: Text(
                  'Відповідь сервера 201 Created\n'
                  'id: ${created.id}, userId: ${created.userId}\n${created.body}',
                ),
                isThreeLine: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
