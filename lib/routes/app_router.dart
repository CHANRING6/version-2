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
import '../features/admin/admin_shell.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_products_screen.dart';
import '../features/admin/admin_product_form_screen.dart';
import '../features/admin/admin_orders_screen.dart';
import '../features/admin/admin_users_screen.dart';
import '../features/admin/admin_categories_screen.dart';

// ─────────────────────────────────────────────────────────────
// Route name constants
// ─────────────────────────────────────────────────────────────
class AppRoutes {
  static const splash         = '/';
  static const onboarding     = '/onboarding';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';
  static const home           = '/home';
  static const productDetails = '/product/:id';

  // Admin routes
  static const adminDashboard   = '/admin';
  static const adminProducts    = '/admin/products';
  static const adminProductForm = '/admin/products/new';
  static const adminProductEdit = '/admin/products/edit/:id';
  static const adminOrders      = '/admin/orders';
  static const adminUsers       = '/admin/users';
  static const adminCategories  = '/admin/categories';

  // Helpers
  static String productDetailsPath(String id) => '/product/$id';
  static String adminProductFormEdit(String id) => '/admin/products/edit/$id';
}

// ─────────────────────────────────────────────────────────────
// Router Notifier
// ─────────────────────────────────────────────────────────────
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// ─────────────────────────────────────────────────────────────
// Router Provider
// ─────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userAsync = ref.watch(currentUserProvider);

  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: routerNotifier,

    redirect: (context, routerState) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      final isAuthLoading = authState.isLoading;
      if (isAuthLoading) return null;

      final location = routerState.matchedLocation;

      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      final isPublicRoute = publicRoutes.contains(location);

      // Not logged in → go to login
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // Logged in on a public auth page → go home
      if (isLoggedIn &&
          (location == AppRoutes.login ||
              location == AppRoutes.register ||
              location == AppRoutes.forgotPassword)) {
        return AppRoutes.home;
      }

      // Admin route guard — non-admins can't access /admin/*
      if (location.startsWith('/admin')) {
        final isAdmin = userAsync.maybeWhen(
          data: (user) => user?.isAdmin ?? false,
          orElse: () => false,
        );
        if (!isAdmin) return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(productId: productId);
        },
      ),

      // ── Admin Routes — wrapped in AdminShell (drawer) ─────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminProducts,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminProductsScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminProductForm,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminProductFormScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminProductEdit,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(child: AdminProductFormScreen(productId: id));
            },
          ),
          GoRoute(
            path: AppRoutes.adminOrders,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminOrdersScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminUsersScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminCategories,
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminCategoriesScreen()),
          ),
        ],
      ),
    ],

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

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return ref.watch(appRouterProvider);
  }
}
