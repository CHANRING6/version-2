import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/main_shell.dart';
import '../features/products/product_details_screen.dart';

// ─────────────────────────────────────────────────────────────
// Route name constants — use these instead of raw strings
// so a typo is a compile error, not a silent broken nav
// ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const splash         = '/';
  static const onboarding     = '/onboarding';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';
  static const home           = '/home';
  static const productDetails = '/product/:id';

  // Helper to build the product details path with a real ID
  static String productDetailsPath(String id) => '/product/$id';
}

// ─────────────────────────────────────────────────────────────
// Router Provider
// Declared as a Provider so it can watch authStateProvider
// and redirect automatically on login/logout
// ─────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // We use a listenable so GoRouter re-evaluates redirect
  // whenever auth state changes
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Global Redirect Logic ─────────────────────────────────
    redirect: (context, routerState) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      final isAuthLoading = authState.isLoading;

      // While auth state is loading don't redirect — stay put
      if (isAuthLoading) return null;

      final location = routerState.matchedLocation;

      // Pages that don't require login
      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      final isPublicRoute = publicRoutes.contains(location);

      // Not logged in and trying to access a protected page
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // Logged in but on a public auth page — send to home
      if (isLoggedIn &&
          (location == AppRoutes.login ||
              location == AppRoutes.register ||
              location == AppRoutes.forgotPassword)) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },

    // ── Routes ────────────────────────────────────────────────
    routes: [

      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Login
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Register
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Forgot Password
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Shell (Home + bottom nav)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),

      // Product Details
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(productId: productId);
        },
      ),
    ],

    // ── Error Page ────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Route not found:\n${state.matchedLocation}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────
// AppRouter class — kept for backward compatibility
// main.dart uses appRouterProvider directly via ConsumerWidget
// ─────────────────────────────────────────────────────────────
class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return ref.watch(appRouterProvider);
  }
}