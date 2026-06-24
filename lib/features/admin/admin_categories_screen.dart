import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import 'admin_shell.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductProvider);

    // Build per-category stats
    final stats = <ProductCategory, _CatStat>{};
    for (final cat in ProductCategory.values) {
      final catProducts = products.where((p) => p.category == cat).toList();
      stats[cat] = _CatStat(
        count: catProducts.length,
        available: catProducts.where((p) => p.isAvailable).length,
        lowStock: catProducts.where((p) => p.stockQuantity <= 10).length,
        avgPrice: catProducts.isEmpty
            ? 0
            : catProducts.fold(0.0, (s, p) => s + p.price) /
                catProducts.length,
      );
    }

    final categoriesWithProducts =
        ProductCategory.values.where((c) => stats[c]!.count > 0).toList();
    final empty =
        ProductCategory.values.where((c) => stats[c]!.count == 0).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AdminAppBar(title: 'Categories'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    value: '${ProductCategory.values.length}',
                    label: 'Categories',
                    color: AppTheme.primary,
                  ),
                  _SummaryItem(
                    value: '${categoriesWithProducts.length}',
                    label: 'Active',
                    color: AppTheme.success,
                  ),
                  _SummaryItem(
                    value: '${products.length}',
                    label: 'Total Products',
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'ACTIVE CATEGORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textLight,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            // ── Active categories ────────────────────────
            ...categoriesWithProducts.map((cat) {
              final stat = stats[cat]!;
              return _CategoryCard(
                category: cat,
                stat: stat,
              );
            }),

            if (empty.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'EMPTY CATEGORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textLight,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: empty.map((cat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      '${_emoji(cat)} ${_label(cat)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
}

// ── Category Card ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final _CatStat stat;

  const _CategoryCard({required this.category, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Center(
              child: Text(_emoji(), style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MiniStat(
                      label: '${stat.count} products',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    _MiniStat(
                      label: '${stat.available} available',
                      color: AppTheme.success,
                    ),
                    if (stat.lowStock > 0) ...[
                      const SizedBox(width: 6),
                      _MiniStat(
                        label: '${stat.lowStock} low stock',
                        color: AppTheme.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Avg price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KSh ${stat.avgPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              const Text(
                'avg price',
                style: TextStyle(fontSize: 10, color: AppTheme.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label() {
    switch (category) {
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

  String _emoji() {
    switch (category) {
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
}

class _MiniStat extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniStat({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryItem(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
      ],
    );
  }
}

class _CatStat {
  final int count;
  final int available;
  final int lowStock;
  final double avgPrice;
  const _CatStat({
    required this.count,
    required this.available,
    required this.lowStock,
    required this.avgPrice,
  });
}
