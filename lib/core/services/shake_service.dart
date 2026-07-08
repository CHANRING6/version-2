import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Listens to the accelerometer and fires [onShake] whenever the device is
/// shaken firmly — used for the "Shake for a Deal" surprise-discount
/// feature (Week 9 device-sensor integration).
class ShakeDetector {
  final void Function() onShake;

  /// How far total acceleration must deviate from gravity (~9.8 m/s²)
  /// before it counts as a shake. Higher = requires a firmer shake.
  final double shakeThreshold;

  /// Minimum time between two triggers, so one shake doesn't fire repeatedly.
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastTrigger = DateTime.fromMillisecondsSinceEpoch(0);

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 17.0,
    this.cooldown = const Duration(seconds: 3),
  });

  void start() {
    _subscription ??= accelerometerEventStream().listen(
      _onEvent,
      onError: (_) {
        // Sensor not available on this device/platform (e.g. some web
        // browsers) — fail silently rather than crash the app.
        _subscription?.cancel();
        _subscription = null;
      },
      cancelOnError: true,
    );
  }

  void _onEvent(AccelerometerEvent event) {
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final delta = (magnitude - 9.8).abs();

    if (delta > shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastTrigger) > cooldown) {
        _lastTrigger = now;
        onShake();
      }
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
