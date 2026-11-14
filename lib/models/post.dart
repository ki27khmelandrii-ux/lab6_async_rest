/// Модель поста з REST API jsonplaceholder.typicode.com.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// Фабричний конструктор: перетворює JSON-об'єкт відповіді на модель.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int? ?? 0,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Тіло POST-запиту (id призначає сервер).
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'body': body,
      };

  @override
  String toString() => 'Post(id: $id, title: $title)';
}
