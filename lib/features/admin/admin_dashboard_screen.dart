import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import 'admin_shell.dart';
import '../../seed_data.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final weeklySales = ref.watch(weeklySalesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(
        title: '👑 Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_rounded, color: Colors.white),
            tooltip: 'Back to Store',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Banner ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userAsync.maybeWhen(
                            data: (u) => u?.name ?? 'Admin',
                            orElse: () => 'Admin',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: const Text(
                            'Mega Mart Administrator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 52,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Seed Banner ──────────────────────────────────
            _SeedBanner(stats: stats),


            // ── Stats Header ─────────────────────────────────
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // ── Stats Grid ───────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Products',
                  value: '${stats.totalProducts}',
                  color: AppTheme.primary,
                ),
                _StatCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Total Orders',
                  value: '${stats.totalOrders}',
                  color: AppTheme.accent,
                ),
                _StatCard(
                  icon: Icons.people_rounded,
                  label: 'Customers',
                  value: '${stats.totalUsers}',
                  color: AppTheme.success,
                ),
                _StatCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Revenue',
                  value: 'KSh ${stats.totalRevenue.toStringAsFixed(0)}',
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Sales Chart ──────────────────────────────────
            const Text(
              'Revenue (Last 7 Days)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.only(
                  right: 18, left: 12, top: 24, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                boxShadow: AppTheme.softShadow,
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxRevenue(weeklySales) > 0
                        ? _getMaxRevenue(weeklySales) / 4
                        : 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.divider,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < weeklySales.length) {
                            final date = weeklySales[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(date),
                                style: const TextStyle(
                                  color: AppTheme.textHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getMaxRevenue(weeklySales) > 0
                            ? _getMaxRevenue(weeklySales) / 4
                            : 100,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          if (value == _getMaxRevenue(weeklySales) || value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            NumberFormat.compact().format(value),
                            style: const TextStyle(
                              color: AppTheme.textHint,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: _getMaxRevenue(weeklySales) * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklySales
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Alert Cards ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _AlertCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending Orders',
                    value: '${stats.pendingOrders}',
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AlertCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Low Stock',
                    value: '${stats.lowStockProducts}',
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Navigation ───────────────────────────────────
            const Text(
              'Manage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            _NavTile(
              icon: Icons.inventory_2_rounded,
              title: 'Products',
              subtitle: 'Add, edit or remove products',
              color: AppTheme.primary,
              onTap: () => context.push(AppRoutes.adminProducts),
            ),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.receipt_long_rounded,
              title: 'Orders',
              subtitle: 'View and update order statuses',
              color: AppTheme.accent,
              onTap: () => context.push(AppRoutes.adminOrders),
            ),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.people_rounded,
              title: 'Users',
              subtitle: 'Manage customer accounts',
              color: AppTheme.success,
              onTap: () => context.push(AppRoutes.adminUsers),
            ),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.category_rounded,
              title: 'Categories',
              subtitle: 'View and manage product categories',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push(AppRoutes.adminCategories),
            ),
            const SizedBox(height: 8),

            // ── Technical Section ───────────────────────────
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                'Technical',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            _NavTile(
              icon: Icons.storage_rounded,
              title: 'Database',
              subtitle: 'Firestore structure, schemas & live data',
              color: const Color(0xFF0EA5E9),
              onTap: () => context.push(AppRoutes.adminDatabase),
            ),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.api_rounded,
              title: 'API Info',
              subtitle: 'All Firebase & Firestore endpoints',
              color: const Color(0xFFEC4899),
              onTap: () => context.push(AppRoutes.adminApi),
            ),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.wifi_rounded,
              title: 'Networking',
              subtitle: 'Connection status, pings & request log',
              color: const Color(0xFF10B981),
              onTap: () => context.push(AppRoutes.adminNetworking),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _getMaxRevenue(List<DailySales> sales) {
    if (sales.isEmpty) return 1000;
    final max = sales.map((s) => s.revenue).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1000 : max;
  }
}

// ── Stat Card ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alert Card ───────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AlertCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Nav Tile ─────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Seed Banner ───────────────────────────────────────────────
class _SeedBanner extends StatefulWidget {
  final dynamic stats;
  const _SeedBanner({required this.stats});

  @override
  State<_SeedBanner> createState() => _SeedBannerState();
}

class _SeedBannerState extends State<_SeedBanner> {
  bool _seeding = false;
  bool _done = false;

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await SeedData.run();
      setState(() { _seeding = false; _done = true; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 40 products added to Firestore!'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      setState(() => _seeding = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProducts = widget.stats.totalProducts > 0;
    if (hasProducts || _done) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'No products yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Seed 40 sample products with real images',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _seeding ? null : _seed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
            child: _seeding
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Seed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
