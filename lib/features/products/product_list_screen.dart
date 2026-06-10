import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../routes/app_router.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Category emoji helper ──────────────────────────────────
  String _emoji(ProductCategory cat) {
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

  String _label(ProductCategory cat) {
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

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredAsync = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
              if (cartCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
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
        ],
      ),
      body: Column(
        children: [

          // ── Search Field ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {}); // refresh clear button
                ref.read(searchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textHint,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textHint,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    ref
                        .read(searchQueryProvider.notifier)
                        .state = '';
                  },
                )
                    : null,
              ),
            ),
          ),

          // ── Category Filter Chips ──────────────────────────
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              children: [
                // All chip
                _FilterChip(
                  label: '🛒 All',
                  isSelected: selectedCategory == null,
                  onTap: () => ref
                      .read(selectedCategoryProvider.notifier)
                      .state = null,
                ),
                const SizedBox(width: 6),
                // One chip per category with emoji
                ...ProductCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: '${_emoji(cat)} ${_label(cat)}',
                      isSelected: selectedCategory == cat,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = cat,
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Results Count ──────────────────────────────────
          filteredAsync.maybeWhen(
            data: (products) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${products.length} product${products.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  if (selectedCategory != null ||
                      _searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                        ref
                            .read(searchQueryProvider.notifier)
                            .state = '';
                        ref
                            .read(
                            selectedCategoryProvider.notifier)
                            .state = null;
                      },
                      child: const Text(
                        'Clear filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          // ── Products Grid ──────────────────────────────────
          Expanded(
            child: filteredAsync.when(
              loading: () =>
              const Center(child: LoadingWidget()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.textHint,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load products',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.refresh(productsStreamProvider),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try a different search or category',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            ref
                                .read(
                                searchQueryProvider.notifier)
                                .state = '';
                            ref
                                .read(selectedCategoryProvider
                                .notifier)
                                .state = null;
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      12, 8, 12, 32),
                  // ✅ 3 columns
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onTap: () => context.push(
                      AppRoutes.productDetailsPath(
                          products[index].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
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