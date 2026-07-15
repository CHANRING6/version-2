import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// System-level local notifications (order confirmations, deal alerts) —
/// distinct from the in-app `AppNotify` snackbar, which only shows while
/// the app is open. Not supported on web, so every call here is a safe
/// no-op in that case (Week 11 notifications integration).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      _initialized = true;
    } catch (_) {
      // Non-fatal — app works fine without system notifications.
    }
  }

  /// Requests the runtime notification permission (Android 13+ / iOS).
  /// Safe to call more than once.
  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {
      // Ignore — worst case, notifications silently don't show.
    }
  }

  static const _orderChannel = AndroidNotificationDetails(
    'orders',
    'Order Updates',
    channelDescription: 'Confirmations for orders you place on Mega Mart',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> showOrderConfirmation({
    required String orderId,
    required int itemCount,
    required double total,
  }) async {
    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.show(
        orderId.hashCode,
        'Order confirmed 🎉',
        '$orderId · $itemCount item${itemCount == 1 ? '' : 's'} · '
            'KSh ${total.toStringAsFixed(0)}',
        const NotificationDetails(
          android: _orderChannel,
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {
      // Non-fatal.
    }
  }
}
