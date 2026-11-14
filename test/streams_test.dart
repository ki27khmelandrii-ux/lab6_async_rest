import 'package:flutter_test/flutter_test.dart';
import 'package:lab6_async_rest/services/home_service.dart';
import 'package:lab6_async_rest/services/sensor_service.dart';

void main() {
  test('loadHomeStatus повертає значення після затримки', () async {
    final status = await loadHomeStatus(delay: const Duration(milliseconds: 10));
    expect(status, contains('працюють'));
  });

  test('counterStream (async*) видає 1, 2, 3', () async {
    final values = await counterStream(period: const Duration(milliseconds: 10))
        .take(3)
        .toList();
    expect(values, [1, 2, 3]);
  });

  test('TemperatureSensor (StreamController) видає значення 18–26 °C', () async {
    final sensor = TemperatureSensor(period: const Duration(milliseconds: 10));
    sensor.start();
    final values = await sensor.stream.take(3).toList();
    await sensor.dispose();
    expect(values, hasLength(3));
    expect(values.every((t) => t >= 18 && t <= 26), isTrue);
  });
}
