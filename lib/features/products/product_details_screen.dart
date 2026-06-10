import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/loading_widget.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final cartNotifier = ref.read(cartProvider.notifier);

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: LoadingWidget()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            'Product not found.\n${e.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textLight),
          ),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Product not found.',
                  style: TextStyle(color: AppTheme.textLight)),
            ),
          );
        }

        final inCart = cartNotifier.isInCart(product.id);
        final quantity = cartNotifier.getQuantity(product.id);

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: CustomScrollView(
            slivers: [

              // ── App Bar with real image ──────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.primaryLight,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Container(
                            color: AppTheme.primaryLight,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 60,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryLight,
                          child: const Center(
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              size: 80,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                ),
              ),

              // ── Product Info ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXL),
                      topRight: Radius.circular(AppTheme.radiusXL),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppTheme.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Category + Stock badges
                      Row(
                        children: [
                          _Badge(
                            label: product.categoryLabel,
                            color: AppTheme.primary,
                            bgColor: AppTheme.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            label: product.inStock
                                ? '✓ In Stock'
                                : 'Out of Stock',
                            color: product.inStock
                                ? AppTheme.success
                                : AppTheme.error,
                            bgColor: product.inStock
                                ? AppTheme.success.withOpacity(0.1)
                                : AppTheme.error.withOpacity(0.1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Product name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ ${product.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                            ),
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: 10),
                            Text(
                              product.formattedOriginalPrice,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discountPercent.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Star rating
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < product.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: AppTheme.warning,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'No description available.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Stock info
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 16, color: AppTheme.textLight),
                          const SizedBox(width: 6),
                          Text(
                            '${product.stockQuantity} ${product.unit} available',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),

                      // Quantity control if in cart
                      if (inCart) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Quantity in Cart',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const Spacer(),
                            _QuantityControl(
                              quantity: quantity,
                              onDecrement: () =>
                                  cartNotifier.removeItem(product.id),
                              onIncrement: () =>
                                  cartNotifier.addItem(product),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Bar ───────────────────────────────────────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: AppTheme.cardShadow,
            ),
            child: product.inStock
                ? inCart
                    ? OutlinedButton.icon(
                        onPressed: () =>
                            cartNotifier.deleteItem(product.id),
                        icon: const Icon(
                            Icons.remove_shopping_cart_outlined),
                        label: const Text('Remove from Cart'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => cartNotifier.addItem(product),
                        icon: const Icon(
                            Icons.add_shopping_cart_rounded),
                        label: const Text('Add to Cart'),
                      )
                : ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textHint),
                    child: const Text('Out of Stock'),
                  ),
          ),
        );
      },
    );
  }
}

// ── Badge Widget ─────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Quantity Control ─────────────────────────────────────────
class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            color: AppTheme.error),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        _CircleButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            color: AppTheme.primary),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}