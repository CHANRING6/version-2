import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps `local_auth` for fingerprint / Face ID authentication — used to
/// optionally lock the app behind a biometric check (Week 11 device
/// security integration). Biometrics aren't available on web, so this
/// service degrades gracefully there.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// True if this platform *could* support biometrics at all.
  static bool get isPlatformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// True if the device has biometrics enrolled and ready to use right now.
  static Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user for fingerprint/Face ID. Returns true only on a
  /// genuine successful match — false for cancellation, failure, or any
  /// platform error (never throws).
  static Future<bool> authenticate({
    String reason = 'Unlock Mega Mart',
  }) async {
    if (!isPlatformSupported) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN/pattern as a fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
