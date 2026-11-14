/// Помилка роботи з API з повідомленням, зрозумілим користувачу.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// HTTP-код, якщо сервер відповів, але не успішно.
  final int? statusCode;

  @override
  String toString() => message;
}
