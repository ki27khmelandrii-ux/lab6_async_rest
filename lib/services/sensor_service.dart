import 'dart:async';
import 'dart:math';

/// Лічильник на генераторі async*: нове значення кожні [period].
Stream<int> counterStream({
  Duration period = const Duration(seconds: 2),
}) async* {
  var counter = 0;
  while (true) {
    await Future.delayed(period);
    counter++;
    yield counter;
  }
}

/// Датчик температури розумного дому на StreamController.
///
/// На відміну від async*-генератора, керуємо потоком вручну:
/// запускаємо, зупиняємо й закриваємо, а broadcast-потік
/// можуть слухати одночасно кілька віджетів.
class TemperatureSensor {
  TemperatureSensor({
    this.period = const Duration(seconds: 2),
    Random? random,
  }) : _random = random ?? Random();

  final Duration period;
  final Random _random;
  final StreamController<double> _controller =
      StreamController<double>.broadcast();
  Timer? _timer;
  double _value = 21.5;

  Stream<double> get stream => _controller.stream;

  void start() {
    _timer ??= Timer.periodic(period, (_) {
      // Плавна зміна температури в межах 18–26 °C.
      _value = (_value + (_random.nextDouble() - 0.5)).clamp(18.0, 26.0);
      _controller.add(double.parse(_value.toStringAsFixed(1)));
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }
}
