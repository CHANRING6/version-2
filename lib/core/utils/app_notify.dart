import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NotifyType { success, error, info, warning }

/// One consistent way to tell the user "your action worked / failed" —
/// used after saving data, placing orders, admin CRUD actions, etc.
/// (Week 10: "notification after saving data".)
class AppNotify {
  static void show(
    BuildContext context, {
    required String message,
    NotifyType type = NotifyType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    IconData icon;
    Color color;
    switch (type) {
      case NotifyType.success:
        icon = Icons.check_circle_rounded;
        color = AppTheme.success;
        break;
      case NotifyType.error:
        icon = Icons.error_rounded;
        color = AppTheme.error;
        break;
      case NotifyType.warning:
        icon = Icons.warning_rounded;
        color = AppTheme.warning;
        break;
      case NotifyType.info:
        icon = Icons.info_rounded;
        color = AppTheme.primary;
        break;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0A192F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.all(12),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: NotifyType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: NotifyType.error, duration: const Duration(seconds: 4));

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: NotifyType.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: NotifyType.warning);
}
