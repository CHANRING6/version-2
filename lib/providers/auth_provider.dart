import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────
// 1. AuthService Provider
// Single instance of AuthService shared across the app
// ─────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ─────────────────────────────────────────────────────────────
// 2. Firebase Auth State Stream Provider
// Emits User? whenever login/logout happens
// Use this to redirect to login or home automatically
// ─────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ─────────────────────────────────────────────────────────────
// 3. Current UserModel Provider
// Fetches the full Firestore profile for the logged-in user
// Returns null if not logged in
// ─────────────────────────────────────────────────────────────
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (firebaseUser) async {
      if (firebaseUser == null) return null;
      final authService = ref.read(authServiceProvider);
      return await authService.getUserProfile(firebaseUser.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ─────────────────────────────────────────────────────────────
// 4. Auth Notifier — handles login / register / logout actions
// ─────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  // ── Register ───────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ── Google Sign In ─────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ── Forgot Password ────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ── Update Profile ─────────────────────────────────────────
  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.updateProfile(
        uid: uid,
        name: name,
        phone: phone,
        address: address,
        photoUrl: photoUrl,
      );
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }

  // ── Clear Error ────────────────────────────────────────────
  void clearError() {
    state = const AsyncValue.data(null);
  }
}

// ─────────────────────────────────────────────────────────────
// 5. AuthNotifier Provider
// Use this in screens to call login/register/logout
// ─────────────────────────────────────────────────────────────
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthNotifier(authService);
  },
);

// ─────────────────────────────────────────────────────────────
// 6. Convenience Providers
// ─────────────────────────────────────────────────────────────

// Quick boolean — is anyone logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

// Is the logged-in user an admin?
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.isAdmin ?? false,
    orElse: () => false,
  );
});

// Get error message string from auth state if any
final authErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state.maybeWhen(
    error: (e, _) => e.toString(),
    orElse: () => null,
  );
});