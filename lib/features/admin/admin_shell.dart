import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

/// Global key for the AdminShell scaffold — allows child screens
/// to open the navigation drawer from their own AppBar.
final adminScaffoldKeyProvider =
    Provider<GlobalKey<ScaffoldState>>((ref) => GlobalKey<ScaffoldState>());

// ─────────────────────────────────────────────────────────────
// Admin Shell — wraps all admin screens with a persistent
// navigation drawer (sidebar) for seamless navigation.
// ─────────────────────────────────────────────────────────────
class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final scaffoldKey = ref.watch(adminScaffoldKeyProvider);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.background,
      drawer: _AdminDrawer(userAsync: userAsync),
      // The child (individual admin screen) provides its own Scaffold body.
      // We use a transparent wrapper so the drawer overlay works correctly.
      body: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admin Drawer
// ─────────────────────────────────────────────────────────────
class _AdminDrawer extends ConsumerWidget {
  final AsyncValue<dynamic> userAsync;
  const _AdminDrawer({required this.userAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: const Color(0xFF0D1B2A),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            _DrawerHeader(userAsync: userAsync),

            const SizedBox(height: 8),

            // ── Nav Items ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: AppRoutes.adminDashboard,
                    isActive: location == AppRoutes.adminDashboard,
                    onTap: () => _navigate(context, AppRoutes.adminDashboard),
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Products',
                    route: AppRoutes.adminProducts,
                    isActive: location.startsWith(AppRoutes.adminProducts),
                    onTap: () => _navigate(context, AppRoutes.adminProducts),
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    route: AppRoutes.adminOrders,
                    isActive: location == AppRoutes.adminOrders,
                    onTap: () => _navigate(context, AppRoutes.adminOrders),
                  ),
                  _DrawerItem(
                    icon: Icons.people_rounded,
                    label: 'Users',
                    route: AppRoutes.adminUsers,
                    isActive: location == AppRoutes.adminUsers,
                    onTap: () => _navigate(context, AppRoutes.adminUsers),
                  ),
                  _DrawerItem(
                    icon: Icons.category_rounded,
                    label: 'Categories',
                    route: AppRoutes.adminCategories,
                    isActive: location == AppRoutes.adminCategories,
                    onTap: () => _navigate(context, AppRoutes.adminCategories),
                  ),

                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Text(
                      'TECHNICAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.3),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _DrawerItem(
                    icon: Icons.storage_rounded,
                    label: 'Database',
                    route: AppRoutes.adminDatabase,
                    isActive: location == AppRoutes.adminDatabase,
                    onTap: () => _navigate(context, AppRoutes.adminDatabase),
                  ),
                  _DrawerItem(
                    icon: Icons.api_rounded,
                    label: 'API Info',
                    route: AppRoutes.adminApi,
                    isActive: location == AppRoutes.adminApi,
                    onTap: () => _navigate(context, AppRoutes.adminApi),
                  ),
                  _DrawerItem(
                    icon: Icons.wifi_rounded,
                    label: 'Networking',
                    route: AppRoutes.adminNetworking,
                    isActive: location == AppRoutes.adminNetworking,
                    onTap: () => _navigate(context, AppRoutes.adminNetworking),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF1E3A5F)),
                  const SizedBox(height: 8),

                  // ── Back to Store ────────────────────────
                  _DrawerItem(
                    icon: Icons.storefront_rounded,
                    label: 'Back to Store',
                    route: AppRoutes.home,
                    isActive: false,
                    color: AppTheme.accent,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.home);
                    },
                  ),
                ],
              ),
            ),

            // ── Footer version tag ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Mega Mart Admin v1.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    context.go(route);
  }
}

// ── Drawer Header ─────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final AsyncValue<dynamic> userAsync;
  const _DrawerHeader({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    final name = userAsync.maybeWhen(
      data: (u) => u?.name ?? 'Admin',
      orElse: () => 'Admin',
    );
    final email = userAsync.maybeWhen(
      data: (u) => u?.email ?? '',
      orElse: () => '',
    );
    final initials = userAsync.maybeWhen(
      data: (u) => (u?.initials ?? 'A') as String,
      orElse: () => 'A',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3A6B), Color(0xFF0D1B2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crown icon + Admin label
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        size: 12, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avatar + Name
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item ───────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.primary;
    final itemColor =
        isActive ? activeColor : Colors.white.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: isActive
              ? Border.all(color: activeColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 14,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Admin AppBar — shared across all admin screens.
// Uses the adminScaffoldKeyProvider to open the outer drawer.
// ─────────────────────────────────────────────────────────────
class AdminAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = ref.watch(adminScaffoldKeyProvider);
    return AppBar(
      backgroundColor: const Color(0xFF0D1B2A),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            )
          : IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              // Open the outer AdminShell drawer via the global key
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      actions: actions,
    );
  }
}
