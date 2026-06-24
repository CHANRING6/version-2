import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_theme.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final inCart = ref.watch(cartProvider.select(
            (items) => items.any((i) => i.id == widget.product.id)));
    final quantity = ref.watch(cartProvider.select((items) {
      final index =
      items.indexWhere((i) => i.id == widget.product.id);
      return index >= 0 ? items[index].quantity : 0;
    }));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color:
              _hovered ? AppTheme.primary : AppTheme.divider,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ]
                : AppTheme.softShadow,
          ),
          // ✅ intrinsicHeight removed — Column wraps content tightly
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Square Image ─────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft:
                      Radius.circular(AppTheme.radiusMD),
                      topRight:
                      Radius.circular(AppTheme.radiusMD),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: widget.product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget:
                            (context, url, error) =>
                            Container(
                              color: AppTheme.primaryLight,
                              child: const Center(
                                child: Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  color: AppTheme.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                      )
                          : Container(
                        color: AppTheme.primaryLight,
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 36,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Discount badge
                  if (widget.product.isOnSale)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${widget.product.discountPercent.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Out of stock overlay
                  if (!widget.product.inStock)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                              AppTheme.radiusMD),
                          topRight: Radius.circular(
                              AppTheme.radiusMD),
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: const Center(
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Info + Button ─────────────────────────────
              // ✅ No Spacer, no Expanded — pure tight wrapping
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Category
                    Text(
                      widget.product.categoryLabel,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Name
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // Price
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            widget.product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '/${widget.product.unit}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),

                    // Strike price
                    if (widget.product.isOnSale)
                      Text(
                        widget.product.formattedOriginalPrice,
                        style: const TextStyle(
                          fontSize: 8,
                          color: AppTheme.textHint,
                          decoration:
                          TextDecoration.lineThrough,
                        ),
                      ),

                    // ✅ Fixed gap — 5px only, button immediately after price
                    SizedBox(height: widget.product.isOnSale ? 2 : 5),

                    // Add to Cart
                    widget.product.inStock
                        ? inCart
                        ? _QuantityRow(
                      quantity: quantity,
                      onDecrement: () => cartNotifier
                          .removeItem(
                          widget.product.id),
                      onIncrement: () =>
                          cartNotifier.addItem(
                              widget.product),
                    )
                        : SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () =>
                            cartNotifier.addItem(
                                widget.product),
                        style:
                        ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                AppTheme
                                    .radiusSM),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            Icon(
                                Icons.add_rounded,
                                size: 12),
                            SizedBox(width: 2),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Container(
                      width: double.infinity,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius:
                        BorderRadius.circular(
                            AppTheme.radiusSM),
                      ),
                      child: const Center(
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

// ── Quantity Row ─────────────────────────────────────────────
class _QuantityRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          _SmallButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            color: AppTheme.error,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),
          _SmallButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _SmallButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
    );
  }
}