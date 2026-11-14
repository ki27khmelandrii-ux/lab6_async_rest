/// У вебі бібліотеки dart:io немає, тому оголошуємо однойменний тип,
/// щоб код `on SocketException` компілювався на всіх платформах.
/// Мережеві помилки у браузері приходять як http.ClientException.
class SocketException implements Exception {
  const SocketException(this.message);

  final String message;

  @override
  String toString() => 'SocketException: $message';
}
