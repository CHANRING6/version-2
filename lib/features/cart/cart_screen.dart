import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../routes/app_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final subtotal = ref.watch(cartSubtotalStringProvider);
    final deliveryFee = ref.watch(deliveryFeeStringProvider);
    final total = ref.watch(cartTotalStringProvider);
    final subtotalValue = ref.watch(cartSubtotalProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('My Cart (${cartItems.length})'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cartNotifier),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [

                // ── Cart Items List ────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppTheme.paddingMD),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CartItemCard(
                        item: cartItems[index],
                        onIncrement: () => cartNotifier
                            .addItem(cartItems[index].product),
                        onDecrement: () =>
                            cartNotifier.removeItem(cartItems[index].id),
                        onDelete: () =>
                            cartNotifier.deleteItem(cartItems[index].id),
                      );
                    },
                  ),
                ),

                // ── Order Summary ──────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppTheme.cardShadow,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXL),
                      topRight: Radius.circular(AppTheme.radiusXL),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: [

                      // Free delivery progress
                      if (subtotalValue < 2000) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Add KSh ${(2000 - subtotalValue).toStringAsFixed(0)} more for FREE delivery',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull),
                          child: LinearProgressIndicator(
                            value: (subtotalValue / 2000)
                                .clamp(0.0, 1.0),
                            backgroundColor: AppTheme.primaryLight,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primary),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: AppTheme.success,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'You qualify for FREE delivery! 🎉',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Price breakdown
                      _SummaryRow(
                          label: 'Subtotal', value: subtotal),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Delivery Fee',
                        value: deliveryFee,
                        valueColor: subtotalValue >= 2000
                            ? AppTheme.success
                            : AppTheme.textDark,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: total,
                        isTotal: true,
                      ),

                      const SizedBox(height: 16),

                      // Checkout button
                      ElevatedButton(
                        onPressed: () =>
                            _proceedToCheckout(context, ref),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmClear(
      BuildContext context, CartNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.read(isLoggedInProvider);
    if (!isLoggedIn) {
      context.push(AppRoutes.login);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checkout coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add items from the products screen\nto get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.store_outlined),
              label: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Item Card ───────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [

          // ✅ Real product image using CachedNetworkImage
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryLight,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Container(
                        color: AppTheme.primaryLight,
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.primaryLight,
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppTheme.primary,
                        size: 32,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  '${item.product.formattedPrice} / ${item.product.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: onDecrement,
                      color: AppTheme.error,
                    ),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onTap: onIncrement,
                      color: AppTheme.primary,
                    ),
                    const Spacer(),
                    Text(
                      item.formattedTotal,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Qty Button ───────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

// ── Summary Row ──────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight:
                isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal
                ? AppTheme.textDark
                : AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w700,
            color: valueColor ??
                (isTotal
                    ? AppTheme.primary
                    : AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}