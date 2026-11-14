import 'package:material_ui/material_ui.dart';

import '../services/home_service.dart';
import '../services/sensor_service.dart';

/// Порівняння FutureBuilder і StreamBuilder на різних джерелах даних.
class FutureVsStreamScreen extends StatefulWidget {
  const FutureVsStreamScreen({super.key});

  @override
  State<FutureVsStreamScreen> createState() => _FutureVsStreamScreenState();
}

class _FutureVsStreamScreenState extends State<FutureVsStreamScreen> {
  // Джерела створюються один раз, а не в build().
  late final Future<String> _statusFuture = loadHomeStatus();
  late final Stream<int> _counter = counterStream();
  final TemperatureSensor _sensor = TemperatureSensor();

  // Лічильники викликів builder — показують, як часто віджет перебудовується.
  int _futureBuilds = 0;
  int _counterBuilds = 0;
  int _sensorBuilds = 0;

  @override
  void initState() {
    super.initState();
    _sensor.start();
  }

  @override
  void dispose() {
    _sensor.dispose(); // зупиняємо таймер і закриваємо StreamController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Future vs Stream')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoCard(
            icon: Icons.hourglass_bottom,
            title: 'FutureBuilder · Future.delayed (2 с)',
            child: FutureBuilder<String>(
              future: _statusFuture,
              builder: (context, snapshot) {
                _futureBuilds++;
                final value = switch (snapshot.connectionState) {
                  ConnectionState.waiting => 'Перевірка систем...',
                  ConnectionState.done when snapshot.hasData => snapshot.data!,
                  _ => 'Помилка: ${snapshot.error}',
                };
                return _Value(
                  value: value,
                  state: snapshot.connectionState,
                  builds: _futureBuilds,
                );
              },
            ),
          ),
          _DemoCard(
            icon: Icons.timer_outlined,
            title: 'StreamBuilder · генератор async* (кожні 2 с)',
            child: StreamBuilder<int>(
              stream: _counter,
              builder: (context, snapshot) {
                _counterBuilds++;
                return _Value(
                  value: snapshot.hasData
                      ? 'Лічильник: ${snapshot.data}'
                      : 'Очікування першої події...',
                  state: snapshot.connectionState,
                  builds: _counterBuilds,
                );
              },
            ),
          ),
          _DemoCard(
            icon: Icons.thermostat,
            title: 'StreamBuilder · StreamController (датчик)',
            child: StreamBuilder<double>(
              stream: _sensor.stream,
              builder: (context, snapshot) {
                _sensorBuilds++;
                return _Value(
                  value: snapshot.hasData
                      ? 'Температура у вітальні: ${snapshot.data} °C'
                      : 'Очікування даних датчика...',
                  state: snapshot.connectionState,
                  builds: _sensorBuilds,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.value, required this.state, required this.builds});

  final String value;
  final ConnectionState state;
  final int builds;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'ConnectionState.${state.name} · builder викликано: $builds',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
