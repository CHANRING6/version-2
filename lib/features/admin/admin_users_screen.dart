import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import 'admin_shell.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  UserRole? _filterRole;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUserProvider);
    final orders = ref.watch(adminOrderProvider);
    final notifier = ref.read(adminUserProvider.notifier);

    final filtered = users.where((u) {
      final matchesQuery = _query.isEmpty ||
          u.name.toLowerCase().contains(_query) ||
          u.email.toLowerCase().contains(_query) ||
          u.phone.contains(_query);
      final matchesRole = _filterRole == null || u.role == _filterRole;
      return matchesQuery && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AdminAppBar(title: 'Users'),
      body: Column(
        children: [
          // ── Stats Summary ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total',
                    count: users.length,
                    icon: Icons.people_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    title: 'Customers',
                    count: users.where((u) => u.isCustomer).length,
                    icon: Icons.person_outline_rounded,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    title: 'Admins',
                    count: users.where((u) => u.isAdmin).length,
                    icon: Icons.admin_panel_settings_rounded,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),

          // ── Search + Filter ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or phone...',
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
                Row(
                  children: [
                    _RoleChip(
                      label: 'All (${users.length})',
                      isSelected: _filterRole == null,
                      color: AppTheme.primary,
                      onTap: () => setState(() => _filterRole = null),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label:
                          'Customers (${users.where((u) => u.isCustomer).length})',
                      isSelected: _filterRole == UserRole.customer,
                      color: AppTheme.success,
                      onTap: () =>
                          setState(() => _filterRole = UserRole.customer),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label:
                          'Admins (${users.where((u) => u.isAdmin).length})',
                      isSelected: _filterRole == UserRole.admin,
                      color: AppTheme.accent,
                      onTap: () =>
                          setState(() => _filterRole = UserRole.admin),
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
                        Icon(Icons.people_outline,
                            size: 52, color: AppTheme.textHint),
                        SizedBox(height: 12),
                        Text('No users found',
                            style: TextStyle(color: AppTheme.textLight)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final user = filtered[i];
                      final userOrders = orders.where((o) => o.userId == user.uid).length;
                      return _UserCard(
                        user: user,
                        orderCount: userOrders,
                        onToggleRole: () {
                          _confirmRoleToggle(context, notifier, user);
                        },
                        onDelete: () {
                          _confirmDelete(context, notifier, user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmRoleToggle(BuildContext context, AdminUserNotifier notifier,
      UserModel user) {
    final isPromoting = user.isCustomer;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
        title: Text(isPromoting ? 'Promote to Admin?' : 'Remove Admin?'),
        content: Text(isPromoting
            ? 'Give ${user.name} admin privileges?'
            : 'Remove admin privileges from ${user.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.toggleRole(user.uid);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isPromoting
                      ? '${user.name} is now an Admin'
                      : '${user.name} is now a Customer'),
                  backgroundColor:
                      isPromoting ? AppTheme.accent : AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              isPromoting ? 'Promote' : 'Demote',
              style: TextStyle(
                  color: isPromoting ? AppTheme.accent : AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminUserNotifier notifier,
      UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
        title: const Text('Delete User?'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.deleteUser(user.uid);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} deleted'),
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

// ── User Card ─────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserModel user;
  final int orderCount;
  final VoidCallback onToggleRole;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.orderCount,
    required this.onToggleRole,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
        border: isAdmin
            ? Border.all(color: AppTheme.accent.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [AppTheme.accent, const Color(0xFFFF9A62)]
                    : [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppTheme.accent.withValues(alpha: 0.1)
                            : AppTheme.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        isAdmin ? '👑 Admin' : '🛒 Customer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAdmin ? AppTheme.accent : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight)),
                Text(user.phone,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textHint)),
                if (user.address.isNotEmpty)
                  Text(
                    user.address,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 12, color: AppTheme.primary.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      '$orderCount order${orderCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppTheme.textLight),
            onSelected: (v) {
              if (v == 'role') onToggleRole();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'role',
                child: Row(children: [
                  Icon(
                    isAdmin ? Icons.person_rounded : Icons.admin_panel_settings_rounded,
                    size: 16,
                    color: isAdmin ? AppTheme.primary : AppTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(isAdmin ? 'Remove Admin' : 'Make Admin'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_rounded,
                      size: 16, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text('Delete User',
                      style: TextStyle(color: AppTheme.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ── Summary Card ────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label,
      required this.isSelected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
              color: isSelected ? color : AppTheme.divider),
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
