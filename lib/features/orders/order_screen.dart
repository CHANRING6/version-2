import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';

// ─────────────────────────────────────────────────────────────
// Local Orders Provider — no Firestore, no permissions needed
// Orders are stored in memory for the session
// ─────────────────────────────────────────────────────────────
class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super(_sampleOrders());

  // Add a new order
  void addOrder(OrderModel order) {
    state = [order, ...state];
  }

  // Update order status
  void updateStatus(String orderId, OrderStatus status) {
    state = state.map((o) {
      if (o.id == orderId) return o.copyWith(status: status);
      return o;
    }).toList();
  }

  void clearOrders() => state = [];

  // ── Sample orders so screen is never empty ─────────────────
  static List<OrderModel> _sampleOrders() {
    return [
      OrderModel(
        id: 'ORD001KE',
        userId: 'sample',
        userName: 'Sample User',
        userPhone: '+254 700 000 000',
        items: [
          OrderItemSnapshot(
            productId: 'p001',
            productName: 'Fresh Strawberries',
            productImageUrl:
                'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200',
            productUnit: 'punnet',
            priceAtOrder: 250,
            quantity: 2,
          ),
          OrderItemSnapshot(
            productId: 'p010',
            productName: 'Fresh Whole Milk',
            productImageUrl:
                'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200',
            productUnit: '500ml',
            priceAtOrder: 65,
            quantity: 3,
          ),
          OrderItemSnapshot(
            productId: 'p011',
            productName: 'Free Range Eggs',
            productImageUrl:
                'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200',
            productUnit: 'tray (30)',
            priceAtOrder: 180,
            quantity: 1,
          ),
        ],
        subtotal: 875,
        deliveryFee: 0,
        total: 875,
        status: OrderStatus.delivered,
        deliveryAddress: 'Westlands, Nairobi',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderModel(
        id: 'ORD002KE',
        userId: 'sample',
        userName: 'Sample User',
        userPhone: '+254 700 000 000',
        items: [
          OrderItemSnapshot(
            productId: 'p014',
            productName: 'Beef Mince',
            productImageUrl:
                'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=200',
            productUnit: 'kg',
            priceAtOrder: 550,
            quantity: 1,
          ),
          OrderItemSnapshot(
            productId: 'p017',
            productName: 'Sliced White Bread',
            productImageUrl:
                'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
            productUnit: 'loaf',
            priceAtOrder: 65,
            quantity: 2,
          ),
        ],
        subtotal: 680,
        deliveryFee: 200,
        total: 880,
        status: OrderStatus.shipped,
        deliveryAddress: 'Kilimani, Nairobi',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      OrderModel(
        id: 'ORD003KE',
        userId: 'sample',
        userName: 'Sample User',
        userPhone: '+254 700 000 000',
        items: [
          OrderItemSnapshot(
            productId: 'p049',
            productName: 'Baby Diapers',
            productImageUrl:
                'https://images.unsplash.com/photo-1612035165219-7e3b89dbb5bf?w=200',
            productUnit: 'pack (40)',
            priceAtOrder: 950,
            quantity: 1,
          ),
          OrderItemSnapshot(
            productId: 'p050',
            productName: 'Baby Wipes',
            productImageUrl:
                'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200',
            productUnit: 'pack (80)',
            priceAtOrder: 280,
            quantity: 2,
          ),
        ],
        subtotal: 1510,
        deliveryFee: 200,
        total: 1710,
        status: OrderStatus.confirmed,
        deliveryAddress: 'Karen, Nairobi',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, List<OrderModel>>(
        (ref) => OrderNotifier());

// ─────────────────────────────────────────────────────────────
// Orders Screen
// ─────────────────────────────────────────────────────────────
class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          // Order count badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '${orders.length} order${orders.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? _buildEmptyOrders(context)
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.paddingMD),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _OrderCard(order: orders[index]),
            ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order history will appear here\nonce you make a purchase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Card ───────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [

          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMD),
            child: Row(
              children: [
                // Status icon box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _statusBgColor(order.status),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  child: Center(
                    child: Text(
                      order.statusEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Order ID + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBgColor(order.status),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Items Preview ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMD),
            child: Column(
              children: [
                ...order.items.take(2).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            // Item image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSM),
                              child: item.productImageUrl.isNotEmpty
                                  ? Image.network(
                                      item.productImageUrl,
                                      width: 38,
                                      height: 38,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                        width: 38,
                                        height: 38,
                                        color: AppTheme.primaryLight,
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 18,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppTheme.radiusSM),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 18,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 10),

                            // Item name
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Qty
                            Text(
                              'x${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Item total
                            Text(
                              item.formattedTotal,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                // More items label
                if (order.items.length > 2)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+${order.items.length - 2} more item${order.items.length - 2 > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Footer ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMD),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.deliveryAddress.isNotEmpty
                        ? order.deliveryAddress
                        : 'No address provided',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),

                // Delivery fee label
                if (order.deliveryFee == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Text(
                      'Free Delivery',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                // Grand total
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:    return AppTheme.warning;
      case OrderStatus.confirmed:  return AppTheme.primary;
      case OrderStatus.processing: return AppTheme.primary;
      case OrderStatus.shipped:    return const Color(0xFF8B5CF6);
      case OrderStatus.delivered:  return AppTheme.success;
      case OrderStatus.cancelled:  return AppTheme.error;
    }
  }

  Color _statusBgColor(OrderStatus status) =>
      _statusColor(status).withOpacity(0.1);

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}  $hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }
}