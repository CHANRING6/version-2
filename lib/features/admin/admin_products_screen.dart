import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_router.dart';
import 'admin_shell.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ProductCategory? _filterCat;
  bool _isGrid = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(adminProductProvider);
    final notifier = ref.read(adminProductProvider.notifier);

    final filtered = products.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query) ||
          p.categoryLabel.toLowerCase().contains(_query);
      final matchesCat = _filterCat == null || p.category == _filterCat;
      return matchesQuery && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(
        title: 'Products',
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.adminProductForm),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + Filter ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textHint, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMD),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                // Category filter chips
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _filterCat == null,
                        onTap: () => setState(() => _filterCat = null),
                      ),
                      const SizedBox(width: 6),
                      ...ProductCategory.values.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _FilterChip(
                              label: cat.name,
                              isSelected: _filterCat == cat,
                              onTap: () =>
                                  setState(() => _filterCat = cat),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Count row ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} product${filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.list_rounded,
                        color: !_isGrid ? AppTheme.primary : AppTheme.textHint,
                      ),
                      onPressed: () => setState(() => _isGrid = false),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        color: _isGrid ? AppTheme.primary : AppTheme.textHint,
                      ),
                      onPressed: () => setState(() => _isGrid = true),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 52, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('No products found',
                            style: TextStyle(color: AppTheme.textLight)),
                      ],
                    ),
                  )
                : _isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return _ProductGridTile(
                            product: p,
                            onEdit: () => context.push(
                              AppRoutes.adminProductFormEdit(p.id),
                            ),
                            onDelete: () =>
                                _confirmDelete(context, notifier, p),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return _ProductTile(
                            product: p,
                            onEdit: () => context.push(
                              AppRoutes.adminProductFormEdit(p.id),
                            ),
                            onToggleFeatured: () =>
                                notifier.toggleFeatured(p.id),
                            onToggleAvailable: () =>
                                notifier.toggleAvailability(p.id),
                            onDelete: () =>
                                _confirmDelete(context, notifier, p),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminProductNotifier notifier,
      ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
        title: const Text('Delete Product?'),
        content: Text(
            'Are you sure you want to delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} deleted'),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Product Tile ─────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onToggleFeatured;
  final VoidCallback onToggleAvailable;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onToggleFeatured,
    required this.onToggleAvailable,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 52,
                          height: 52,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            title: Text(
              product.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                Row(
                  children: [
                    _Badge(
                      label: product.categoryLabel,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    _Badge(
                      label: 'Stock: ${product.stockQuantity}',
                      color: product.stockQuantity <= 10
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.textLight),
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'featured':
                    onToggleFeatured();
                    break;
                  case 'available':
                    onToggleAvailable();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ])),
                PopupMenuItem(
                    value: 'featured',
                    child: Row(children: [
                      Icon(
                          product.isFeatured
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 16,
                          color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Text(product.isFeatured
                          ? 'Unfeature'
                          : 'Mark Featured'),
                    ])),
                PopupMenuItem(
                    value: 'available',
                    child: Row(children: [
                      Icon(
                          product.isAvailable
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 16,
                          color: AppTheme.textLight),
                      const SizedBox(width: 8),
                      Text(product.isAvailable ? 'Disable' : 'Enable'),
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded,
                          size: 16, color: AppTheme.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppTheme.error)),
                    ])),
              ],
            ),
          ),

          // ── Status indicators ─────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusMD),
                bottomRight: Radius.circular(AppTheme.radiusMD),
              ),
            ),
            child: Row(
              children: [
                _StatusBadge(
                    active: product.isFeatured,
                    activeLabel: '⭐ Featured',
                    inactiveLabel: 'Not Featured'),
                const SizedBox(width: 8),
                _StatusBadge(
                    active: product.isAvailable,
                    activeLabel: '✅ Available',
                    inactiveLabel: '🔴 Disabled'),
                const SizedBox(width: 8),
                if (product.isOnSale)
                  _StatusBadge(
                      active: true,
                      activeLabel:
                          '🔥 ${product.discountPercent.toInt()}% OFF',
                      inactiveLabel: ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 52,
        height: 52,
        color: AppTheme.primaryLight,
        child: const Icon(Icons.shopping_bag_outlined,
            color: AppTheme.primary, size: 24),
      );
}

class _ProductGridTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductGridTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMD),
                    topRight: Radius.circular(AppTheme.radiusMD),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Badge(
                            label: 'Stock: ${product.stockQuantity}',
                            color: product.stockQuantity <= 10
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: onEdit,
                                child: const Icon(Icons.edit_rounded,
                                    size: 16, color: AppTheme.textMedium),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: onDelete,
                                child: const Icon(Icons.delete_rounded,
                                    size: 16, color: AppTheme.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (product.isFeatured)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.primaryLight,
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined,
              color: AppTheme.primary, size: 32),
        ),
      );
}

// ── Small helpers ────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  final String activeLabel;
  final String inactiveLabel;
  const _StatusBadge(
      {required this.active,
      required this.activeLabel,
      required this.inactiveLabel});

  @override
  Widget build(BuildContext context) {
    if (!active && inactiveLabel.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            active ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        active ? activeLabel : inactiveLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: active ? AppTheme.success : AppTheme.error,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }
}
