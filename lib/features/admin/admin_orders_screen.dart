import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';
import 'admin_shell.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(adminOrderProvider);
    final notifier = ref.read(adminOrderProvider.notifier);

    final filtered = _filterStatus == null
        ? orders
        : orders.where((o) => o.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AdminAppBar(title: 'Orders'),
      body: Column(
        children: [
          // ── Revenue Summary ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Revenue',
                    amount: '\$${orders.fold<double>(0, (p, o) => p + (o.status != OrderStatus.cancelled ? o.total : 0)).toStringAsFixed(2)}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    title: 'Pending Value',
                    amount: '\$${orders.where((o) => o.status == OrderStatus.pending).fold<double>(0, (p, o) => p + o.total).toStringAsFixed(2)}',
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    title: 'Delivered Value',
                    amount: '\$${orders.where((o) => o.status == OrderStatus.delivered).fold<double>(0, (p, o) => p + o.total).toStringAsFixed(2)}',
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),

          // ── Status filter chips ──────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatusChip(
                    label: 'All (${orders.length})',
                    isSelected: _filterStatus == null,
                    color: AppTheme.primary,
                    onTap: () => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: 6),
                  ...OrderStatus.values.map((s) {
                    final count = orders.where((o) => o.status == s).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _StatusChip(
                        label: '${_statusLabel(s)} ($count)',
                        isSelected: _filterStatus == s,
                        color: _statusColor(s),
                        onTap: () => setState(() => _filterStatus = s),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Orders list ──────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 52, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('No orders found',
                            style: TextStyle(color: AppTheme.textLight)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final order = filtered[i];
                      return _OrderCard(
                        order: order,
                        onChangeStatus: (newStatus) {
                          notifier.updateStatus(order.id, newStatus);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Order ${order.id} → ${_statusLabel(newStatus)}'),
                              backgroundColor: _statusColor(newStatus),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return AppTheme.warning;
      case OrderStatus.confirmed:  return AppTheme.primary;
      case OrderStatus.processing: return const Color(0xFF8B5CF6);
      case OrderStatus.shipped:    return const Color(0xFF06B6D4);
      case OrderStatus.delivered:  return AppTheme.success;
      case OrderStatus.cancelled:  return AppTheme.error;
    }
  }
}

// ── Order Card ────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final void Function(OrderStatus) onChangeStatus;

  const _OrderCard({required this.order, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.userName} • ${order.userPhone}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                      ),
                      Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),

          // ── Timeline ─────────────────────────────────────
          const Divider(height: 1, color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: _OrderTimeline(currentStatus: order.status),
          ),

          // ── Items ─────────────────────────────────────
          const Divider(height: 1, color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}×',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textMedium),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.formattedTotal,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Footer ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusMD),
                bottomRight: Radius.circular(AppTheme.radiusMD),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textHint),
                    ),
                  ],
                ),

                // Change status button
                PopupMenuButton<OrderStatus>(
                  onSelected: onChangeStatus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Update Status',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (_) => OrderStatus.values.map((s) {
                    return PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Text(_statusEmoji(s)),
                          const SizedBox(width: 8),
                          Text(_statusLabel(s)),
                          if (s == order.status) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_rounded,
                                size: 14, color: AppTheme.success),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  String _statusEmoji(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return '⏳';
      case OrderStatus.confirmed:  return '✅';
      case OrderStatus.processing: return '🔄';
      case OrderStatus.shipped:    return '🚚';
      case OrderStatus.delivered:  return '📦';
      case OrderStatus.cancelled:  return '❌';
    }
  }
}

// ── Status Badge ──────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:    return AppTheme.warning;
      case OrderStatus.confirmed:  return AppTheme.primary;
      case OrderStatus.processing: return const Color(0xFF8B5CF6);
      case OrderStatus.shipped:    return const Color(0xFF06B6D4);
      case OrderStatus.delivered:  return AppTheme.success;
      case OrderStatus.cancelled:  return AppTheme.error;
    }
  }

  String get _label {
    switch (status) {
      case OrderStatus.pending:    return '⏳ Pending';
      case OrderStatus.confirmed:  return '✅ Confirmed';
      case OrderStatus.processing: return '🔄 Processing';
      case OrderStatus.shipped:    return '🚚 Shipped';
      case OrderStatus.delivered:  return '📦 Delivered';
      case OrderStatus.cancelled:  return '❌ Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: isSelected ? color : AppTheme.divider),
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

// ── New Enhancements ───────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const _OrderTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled) {
      return Row(
        children: [
          const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Text(
            'Order Cancelled',
            style: TextStyle(
              color: AppTheme.error.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    const stages = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered
    ];
    
    final currentIndex = stages.indexOf(currentStatus);
    
    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          final isPast = index ~/ 2 < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isPast ? AppTheme.primary : AppTheme.divider,
            ),
          );
        }
        final stageIndex = index ~/ 2;
        final isCompleted = stageIndex <= currentIndex;
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppTheme.primary : AppTheme.divider,
              width: 3,
            ),
          ),
          child: isCompleted
              ? const Center(child: Icon(Icons.check, size: 10, color: Colors.white))
              : null,
        );
      }),
    );
  }
}
