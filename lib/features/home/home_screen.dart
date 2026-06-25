import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../routes/app_router.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../main_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── App Bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${userAsync.maybeWhen(
                              data: (u) => u?.name
                                  .split(' ')
                                  .first ??
                                  'there',
                              orElse: () => 'there',
                            )} 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'What are you shopping for?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cart icon with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD),
                            border: Border.all(
                                color: AppTheme.divider),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: AppTheme.textDark,
                              size: 20,
                            ),
                            onPressed: () {
                              ref.read(mainShellTabProvider.notifier).state = 2;
                            },
                          ),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  cartCount > 9
                                      ? '9+'
                                      : '$cartCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(AppTheme.radiusLG),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 14),
                      Icon(Icons.search_rounded,
                          color: AppTheme.textHint, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Search products...',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Featured Banner ───────────────────────────────
            SliverToBoxAdapter(
              child: featuredAsync.when(
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: LoadingWidget()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (featured) {
                  if (featured.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _FeaturedBanner(products: featured);
                },
              ),
            ),

            // ── Categories Header ─────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Shop by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),

            // ── Category Chips ────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  children: [
                    _CategoryChip(
                      label: '🛒 All',
                      isSelected: selectedCategory == null,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = null,
                    ),
                    const SizedBox(width: 6),
                    ...ProductCategory.values.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _CategoryChip(
                          label:
                          '${_categoryEmoji(cat)} ${_categoryLabel(cat)}',
                          isSelected: selectedCategory == cat,
                          onTap: () => ref
                              .read(
                              selectedCategoryProvider.notifier)
                              .state = cat,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Products Header ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == null
                          ? 'Popular Products'
                          : _categoryLabel(selectedCategory),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    productsAsync.maybeWhen(
                      data: (products) {
                        final count = selectedCategory == null
                            ? products.length
                            : products
                            .where((p) =>
                        p.category == selectedCategory)
                            .length;
                        return Text(
                          '$count items',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Products Grid — 3 columns ─────────────────────
            productsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: Center(child: LoadingWidget()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load products.\n${e.toString()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (products) {
                final filtered = selectedCategory == null
                    ? products
                    : products
                    .where(
                        (p) => p.category == selectedCategory)
                    .toList();

                if (filtered.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: _EmptyProducts(),
                  );
                }

                return SliverPadding(
                  padding:
                  const EdgeInsets.fromLTRB(12, 8, 12, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, rowIndex) {
                        final start = rowIndex * 3;
                        final items = filtered.sublist(
                          start,
                          (start + 3).clamp(0, filtered.length),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < 3; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: i == 0 ? 0 : 4,
                                        right: i == 2 ? 0 : 4,
                                      ),
                                      child: i < items.length
                                          ? ProductCard(
                                              product: items[i],
                                              onTap: () => context.push(
                                                AppRoutes.productDetailsPath(items[i].id),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: (filtered.length / 3).ceil(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.fruits:      return '🍎';
      case ProductCategory.vegetables:  return '🥦';
      case ProductCategory.dairy:       return '🥛';
      case ProductCategory.meat:        return '🥩';
      case ProductCategory.bakery:      return '🍞';
      case ProductCategory.beverages:   return '🥤';
      case ProductCategory.snacks:      return '🍿';
      case ProductCategory.household:   return '🧹';
      case ProductCategory.personal:    return '🧴';
      case ProductCategory.electronics: return '🔌';
      case ProductCategory.stationery:  return '📝';
      case ProductCategory.babycare:    return '🍼';
      case ProductCategory.frozen:      return '🧊';
      case ProductCategory.condiments:  return '🧂';
      case ProductCategory.other:       return '📦';
    }
  }

  String _categoryLabel(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.fruits:      return 'Fruits';
      case ProductCategory.vegetables:  return 'Vegetables';
      case ProductCategory.dairy:       return 'Dairy & Eggs';
      case ProductCategory.meat:        return 'Meat & Fish';
      case ProductCategory.bakery:      return 'Bakery';
      case ProductCategory.beverages:   return 'Beverages';
      case ProductCategory.snacks:      return 'Snacks';
      case ProductCategory.household:   return 'Household';
      case ProductCategory.personal:    return 'Personal Care';
      case ProductCategory.electronics: return 'Electronics';
      case ProductCategory.stationery:  return 'Stationery';
      case ProductCategory.babycare:    return 'Baby Care';
      case ProductCategory.frozen:      return 'Frozen Foods';
      case ProductCategory.condiments:  return 'Condiments';
      case ProductCategory.other:       return 'Other';
    }
  }
}

// ── Featured Banner ──────────────────────────────────────────
class _FeaturedBanner extends StatefulWidget {
  final List<ProductModel> products;
  const _FeaturedBanner({required this.products});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Featured Deals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),

        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) =>
                setState(() => _current = i),
            itemCount: widget.products.length,
            itemBuilder: (context, i) {
              final product = widget.products[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primaryDark
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        AppTheme.radiusLG),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: -30,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.2),
                                      borderRadius:
                                      BorderRadius.circular(
                                          AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      product.isOnSale
                                          ? '🔥 ${product.discountPercent.toInt()}% OFF'
                                          : '⭐ Featured',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        product.formattedPrice,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w700,
                                        ),
                                      ),
                                      if (product.isOnSale) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          product
                                              .formattedOriginalPrice,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                            fontSize: 11,
                                            decoration:
                                            TextDecoration
                                                .lineThrough,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(
                                          AppTheme.radiusFull),
                                    ),
                                    child: const Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                    AppTheme.radiusMD),
                                child: product
                                    .imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fit: BoxFit.cover,
                                  height: 130,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 130,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget:
                                      (_, __, ___) =>
                                      Container(
                                        height: 130,
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        child: const Icon(
                                          Icons
                                              .shopping_bag_rounded,
                                          color: Colors.white,
                                          size: 44,
                                        ),
                                      ),
                                )
                                    : Container(
                                  height: 130,
                                  color: Colors.white
                                      .withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons
                                        .shopping_bag_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Page dots
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i
                    ? AppTheme.primary
                    : AppTheme.divider,
                borderRadius:
                BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Category Chip ────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:
          isSelected ? AppTheme.primary : Colors.white,
          borderRadius:
          BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.divider,
          ),
          boxShadow: isSelected ? AppTheme.softShadow : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.textMedium,
            fontSize: 11,
            fontWeight: isSelected
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────
class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: AppTheme.textHint,
          ),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try selecting a different category',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}