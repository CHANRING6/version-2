import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBiometricLockKey = 'mega_mart_biometric_lock_enabled';

/// Persisted "require biometric unlock on launch" preference — mirrors
/// [ThemeModeNotifier]'s load/save pattern (Week 11 device security).
class BiometricLockNotifier extends StateNotifier<bool> {
  BiometricLockNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_kBiometricLockKey) ?? false;
    } catch (_) {
      // SharedPreferences unavailable — default to disabled.
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBiometricLockKey, enabled);
    } catch (_) {
      // Non-fatal — preference just won't persist across restarts.
    }
  }
}

final biometricLockEnabledProvider =
    StateNotifierProvider<BiometricLockNotifier, bool>(
  (ref) => BiometricLockNotifier(),
);
