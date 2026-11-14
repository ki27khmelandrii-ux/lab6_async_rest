/// Імітація повільної операції через Future.delayed (Future + async/await).
Future<String> loadHomeStatus({
  Duration delay = const Duration(seconds: 2),
}) async {
  await Future.delayed(delay);
  return 'Усі системи будинку працюють';
}
