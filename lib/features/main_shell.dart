import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../core/theme/app_theme.dart';
import '../core/services/shake_service.dart';
import '../core/utils/app_notify.dart';
import 'home/home_screen.dart';
import 'products/product_list_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/order_screen.dart';
import 'profile/profile_screen.dart';

final mainShellTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final List<Widget> _pages = const [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  late final ShakeDetector _shakeDetector;
  bool _dealSheetOpen = false;

  @override
  void initState() {
    super.initState();
    // Week 9 device sensor feature — shake the phone for a surprise deal.
    _shakeDetector = ShakeDetector(onShake: _onShake)..start();
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    super.dispose();
  }

  void _onShake() {
    if (_dealSheetOpen || !mounted) return;

    final products = ref.read(productsStreamProvider).value;
    if (products == null || products.isEmpty) return;

    final onSale = products
        .where((p) => p.originalPrice != null && p.originalPrice! > p.price)
        .toList();
    final pool = onSale.isNotEmpty ? onSale : products;
    final deal = pool[Random().nextInt(pool.length)];

    HapticFeedback.mediumImpact();
    _showDealSheet(deal);
  }

  void _showDealSheet(ProductModel product) {
    _dealSheetOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Shake Deal!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You shook up a surprise pick',
              style: TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 72, height: 72, color: AppTheme.primaryLight),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AppTheme.primaryLight,
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'KSh ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          if (product.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              'KSh ${product.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('No thanks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(product);
                      Navigator.pop(ctx);
                      AppNotify.success(
                          context, '${product.name} added to cart!');
                    },
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() => _dealSheetOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final currentIndex = ref.watch(mainShellTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => _setIndex(0),
                ),
                _NavItem(
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store_rounded,
                  label: 'Products',
                  isActive: currentIndex == 1,
                  onTap: () => _setIndex(1),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart_rounded,
                  label: 'Cart',
                  isActive: currentIndex == 2,
                  badge: cartCount > 0 ? cartCount : null,
                  onTap: () => _setIndex(2),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  isActive: currentIndex == 3,
                  onTap: () => _setIndex(3),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => _setIndex(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int index) {
    ref.read(mainShellTabProvider.notifier).state = index;
  }
}

// ── Custom Nav Item ──────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryLight
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 22,
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.textLight,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge! > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.textLight,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}