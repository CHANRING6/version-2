import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../repositories/order_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/product_repository.dart';
import 'product_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ─────────────────────────────────────────────────────────────
// ADMIN PRODUCT NOTIFIER
// Reactively syncs with Firestore stream; admins can also
// perform add/edit/delete operations.
// ─────────────────────────────────────────────────────────────
class AdminProductNotifier extends StateNotifier<List<ProductModel>> {
  final ProductRepository _productRepo;
  final Ref _ref;

  AdminProductNotifier(this._productRepo, this._ref, List<ProductModel> initial)
      : super(initial) {
    // Listen to the products stream and keep state in sync
    _ref.listen<AsyncValue<List<ProductModel>>>(
      productsStreamProvider,
      (_, next) {
        next.whenData((list) {
          state = list;
        });
      },
    );
  }

  Future<void> addProduct(ProductModel product) async {
    await _productRepo.addProduct(product);
    // State will be updated via the stream listener above
  }

  Future<void> updateProduct(ProductModel updated) async {
    // Optimistic local update for instant UI response
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    await _productRepo.updateProduct(updated);
  }

  Future<void> deleteProduct(String productId) async {
    // Optimistic local removal
    state = state.where((p) => p.id != productId).toList();
    await _productRepo.deleteProduct(productId);
  }

  Future<void> toggleFeatured(String productId) async {
    final p = state.firstWhere((p) => p.id == productId);
    final updated = p.copyWith(isFeatured: !p.isFeatured);
    await updateProduct(updated);
  }

  Future<void> toggleAvailability(String productId) async {
    final p = state.firstWhere((p) => p.id == productId);
    final updated = p.copyWith(isAvailable: !p.isAvailable);
    await updateProduct(updated);
  }

  String generateId() {
    final maxNum = state.fold<int>(0, (max, p) {
      final num = int.tryParse(p.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return num > max ? num : max;
    });
    return 'p${(maxNum + 1).toString().padLeft(3, '0')}';
  }
}

final adminProductProvider =
    StateNotifierProvider<AdminProductNotifier, List<ProductModel>>((ref) {
  final initial = ref.read(productsStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <ProductModel>[],
      );
  return AdminProductNotifier(ref.watch(productRepositoryProvider), ref, initial);
});

// ─────────────────────────────────────────────────────────────
// ADMIN ORDER NOTIFIER
// Reactively syncs with Firestore orders stream.
// ─────────────────────────────────────────────────────────────
class AdminOrderNotifier extends StateNotifier<List<OrderModel>> {
  final OrderRepository _orderRepo;
  final Ref _ref;

  AdminOrderNotifier(this._orderRepo, this._ref, List<OrderModel> initial)
      : super(initial) {
    // Listen to the orders stream and keep state in sync
    _ref.listen<AsyncValue<List<OrderModel>>>(
      adminOrdersStreamProvider,
      (_, next) {
        next.whenData((list) {
          state = list;
        });
      },
    );
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    // Optimistic local update
    state = state.map((o) {
      if (o.id != orderId) return o;
      return o.copyWith(status: newStatus, updatedAt: DateTime.now());
    }).toList();
    await _orderRepo.updateOrderStatus(orderId, newStatus);
  }
}

final adminOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getAllOrdersStream();
});

final adminOrderProvider =
    StateNotifierProvider<AdminOrderNotifier, List<OrderModel>>((ref) {
  final initial = ref.read(adminOrdersStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <OrderModel>[],
      );
  return AdminOrderNotifier(
      ref.watch(orderRepositoryProvider), ref, initial);
});

// ─────────────────────────────────────────────────────────────
// ADMIN USER NOTIFIER
// Reactively syncs with Firestore users stream.
// ─────────────────────────────────────────────────────────────
class AdminUserNotifier extends StateNotifier<List<UserModel>> {
  final AuthRepository _authRepo;
  final Ref _ref;

  AdminUserNotifier(this._authRepo, this._ref, List<UserModel> initial)
      : super(initial) {
    // Listen to the users stream and keep state in sync
    _ref.listen<AsyncValue<List<UserModel>>>(
      adminUsersStreamProvider,
      (_, next) {
        next.whenData((list) {
          state = list;
        });
      },
    );
  }

  Future<void> toggleRole(String uid) async {
    final u = state.firstWhere((u) => u.uid == uid);
    final newRole =
        u.role == UserRole.admin ? UserRole.customer : UserRole.admin;
    // Optimistic local update using copyWith
    state = state
        .map((user) => user.uid == uid
            ? user.copyWith(role: newRole, updatedAt: DateTime.now())
            : user)
        .toList();
    await _authRepo.updateUser(uid, {'role': newRole.name});
  }

  // Requires Firebase Admin SDK or Cloud Function — no-op on client.
  void deleteUser(String uid) {
    // Not supported without Firebase Admin SDK / Cloud Function.
    // Optimistically remove from local state only.
    state = state.where((u) => u.uid != uid).toList();
  }
}

final adminUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getUsersStream();
});

final adminUserProvider =
    StateNotifierProvider<AdminUserNotifier, List<UserModel>>((ref) {
  final initial = ref.read(adminUsersStreamProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <UserModel>[],
      );
  return AdminUserNotifier(ref.watch(authRepositoryProvider), ref, initial);
});

// ─────────────────────────────────────────────────────────────
// ADMIN STATS — derived from live provider state
// ─────────────────────────────────────────────────────────────
class AdminStats {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final int pendingOrders;
  final int lowStockProducts;
  final double totalRevenue;
  final double todayRevenue;
  final int deliveredOrders;
  final int cancelledOrders;

  const AdminStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.pendingOrders,
    required this.lowStockProducts,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.deliveredOrders,
    required this.cancelledOrders,
  });
}

final adminStatsProvider = Provider<AdminStats>((ref) {
  final products = ref.watch(adminProductProvider);
  final orders = ref.watch(adminOrderProvider);
  final users = ref.watch(adminUserProvider);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  final deliveredOrders = orders.where((o) => o.status == OrderStatus.delivered).toList();
  final todayRevenue = deliveredOrders
      .where((o) => o.updatedAt.isAfter(todayStart))
      .fold(0.0, (sum, o) => sum + o.total);

  return AdminStats(
    totalProducts: products.length,
    totalOrders: orders.length,
    totalUsers: users.where((u) => u.isCustomer).length,
    pendingOrders: orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed)
        .length,
    lowStockProducts: products.where((p) => p.stockQuantity <= 10).length,
    totalRevenue: deliveredOrders.fold(0.0, (sum, o) => sum + o.total),
    todayRevenue: todayRevenue,
    deliveredOrders: deliveredOrders.length,
    cancelledOrders: orders.where((o) => o.status == OrderStatus.cancelled).length,
  );
});

// ─────────────────────────────────────────────────────────────
// SALES DATA — for chart visualization
// Groups delivered orders by day (last 7 days) and by month
// ─────────────────────────────────────────────────────────────

/// Daily revenue for the last 7 days — used for line chart
final weeklySalesProvider = Provider<List<DailySales>>((ref) {
  final orders = ref.watch(adminOrderProvider);
  final delivered = orders.where((o) => o.status == OrderStatus.delivered);

  final now = DateTime.now();
  return List.generate(7, (i) {
    final day = now.subtract(Duration(days: 6 - i));
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final revenue = delivered
        .where((o) =>
            o.updatedAt.isAfter(dayStart) && o.updatedAt.isBefore(dayEnd))
        .fold(0.0, (sum, o) => sum + o.total);

    return DailySales(
      date: dayStart,
      revenue: revenue,
      orderCount: delivered
          .where((o) =>
              o.updatedAt.isAfter(dayStart) && o.updatedAt.isBefore(dayEnd))
          .length,
    );
  });
});

/// Monthly revenue for the last 6 months — used for bar chart
final monthlySalesProvider = Provider<List<MonthlySales>>((ref) {
  final orders = ref.watch(adminOrderProvider);
  final delivered = orders.where((o) => o.status == OrderStatus.delivered);

  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - (5 - i));
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);

    final revenue = delivered
        .where((o) =>
            o.updatedAt.isAfter(monthStart) && o.updatedAt.isBefore(monthEnd))
        .fold(0.0, (sum, o) => sum + o.total);

    return MonthlySales(
      month: monthStart,
      revenue: revenue,
      orderCount: delivered
          .where((o) =>
              o.updatedAt.isAfter(monthStart) && o.updatedAt.isBefore(monthEnd))
          .length,
    );
  });
});

/// Order status breakdown — used for pie chart
final orderStatusBreakdownProvider = Provider<Map<OrderStatus, int>>((ref) {
  final orders = ref.watch(adminOrderProvider);
  final breakdown = <OrderStatus, int>{};
  for (final status in OrderStatus.values) {
    breakdown[status] = orders.where((o) => o.status == status).length;
  }
  return breakdown;
});

/// Category revenue breakdown — used for bar chart in categories
final categoryRevenueProvider = Provider<Map<ProductCategory, double>>((ref) {
  final products = ref.watch(adminProductProvider);
  final orders = ref.watch(adminOrderProvider);
  final delivered = orders.where((o) => o.status == OrderStatus.delivered);

  final revenue = <ProductCategory, double>{};
  for (final cat in ProductCategory.values) {
    revenue[cat] = 0;
  }

  for (final order in delivered) {
    for (final item in order.items) {
      // Find product category
      final product = products.where((p) => p.id == item.productId).firstOrNull;
      if (product != null) {
        revenue[product.category] =
            (revenue[product.category] ?? 0) + item.totalPrice;
      }
    }
  }

  return revenue;
});

// ── Data classes for chart data ──────────────────────────────

class DailySales {
  final DateTime date;
  final double revenue;
  final int orderCount;

  const DailySales({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });
}

class MonthlySales {
  final DateTime month;
  final double revenue;
  final int orderCount;

  const MonthlySales({
    required this.month,
    required this.revenue,
    required this.orderCount,
  });
}
