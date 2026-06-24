import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'admin_shell.dart';

// ─────────────────────────────────────────────────────────────
// Admin Database Screen
// Shows Firestore collection structure, live document counts,
// field schemas, and sample data for each collection.
// ─────────────────────────────────────────────────────────────
class AdminDatabaseScreen extends StatefulWidget {
  const AdminDatabaseScreen({super.key});

  @override
  State<AdminDatabaseScreen> createState() => _AdminDatabaseScreenState();
}

class _AdminDatabaseScreenState extends State<AdminDatabaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collections = ['users', 'products', 'orders'];
  final _firestore = FirebaseFirestore.instance;

  final Map<String, int> _counts = {};
  final Map<String, List<Map<String, dynamic>>> _sampleDocs = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _collections.length, vsync: this);
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    for (final col in _collections) {
      try {
        final snap = await _firestore.collection(col).limit(5).get();
        _counts[col] = snap.size;
        _sampleDocs[col] = snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
      } catch (_) {
        _counts[col] = 0;
        _sampleDocs[col] = [];
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(title: '🗄️ Database Structure'),
      body: Column(
        children: [
          // ── Tab bar ─────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textLight,
              indicatorColor: AppTheme.primary,
              tabs: _collections
                  .map((c) => Tab(text: c[0].toUpperCase() + c.substring(1)))
                  .toList(),
            ),
          ),

          // ── Tab views ────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _CollectionView(
                        name: 'users',
                        icon: Icons.people_rounded,
                        color: AppTheme.success,
                        count: _counts['users'] ?? 0,
                        sampleDocs: _sampleDocs['users'] ?? [],
                        schema: _usersSchema,
                      ),
                      _CollectionView(
                        name: 'products',
                        icon: Icons.inventory_2_rounded,
                        color: AppTheme.primary,
                        count: _counts['products'] ?? 0,
                        sampleDocs: _sampleDocs['products'] ?? [],
                        schema: _productsSchema,
                      ),
                      _CollectionView(
                        name: 'orders',
                        icon: Icons.receipt_long_rounded,
                        color: AppTheme.accent,
                        count: _counts['orders'] ?? 0,
                        sampleDocs: _sampleDocs['orders'] ?? [],
                        schema: _ordersSchema,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Schema definitions
// ─────────────────────────────────────────────────────────────
const _usersSchema = [
  _FieldDef('uid', 'String', 'Auto-generated Firebase Auth UID', true),
  _FieldDef('name', 'String', 'Full display name', true),
  _FieldDef('email', 'String', 'Email address (unique)', true),
  _FieldDef('phone', 'String', 'Phone number', false),
  _FieldDef('photoUrl', 'String', 'Profile photo URL', false),
  _FieldDef('role', 'String', '"customer" or "admin"', true),
  _FieldDef('address', 'String', 'Delivery address', false),
  _FieldDef('createdAt', 'ISO String', 'Account creation timestamp', true),
  _FieldDef('updatedAt', 'ISO String', 'Last profile update', true),
];

const _productsSchema = [
  _FieldDef('name', 'String', 'Product display name', true),
  _FieldDef('description', 'String', 'Product description text', true),
  _FieldDef('price', 'Number', 'Current selling price (KSh)', true),
  _FieldDef('originalPrice', 'Number?', 'Original price for discount display', false),
  _FieldDef('imageUrl', 'String', 'Product image URL', false),
  _FieldDef('category', 'String', 'Category enum name (fruits, dairy, etc.)', true),
  _FieldDef('stockQuantity', 'Number', 'Units currently in stock', true),
  _FieldDef('unit', 'String', 'Unit label (kg, pcs, litre, etc.)', true),
  _FieldDef('isAvailable', 'Boolean', 'Whether product is purchasable', true),
  _FieldDef('isFeatured', 'Boolean', 'Show in featured carousel', true),
  _FieldDef('rating', 'Number', 'Average rating 0–5', true),
  _FieldDef('reviewCount', 'Number', 'Total number of ratings', true),
  _FieldDef('createdAt', 'Timestamp', 'Firestore server timestamp', true),
  _FieldDef('updatedAt', 'Timestamp', 'Firestore server timestamp', true),
];

const _ordersSchema = [
  _FieldDef('userId', 'String', 'UID of the ordering customer', true),
  _FieldDef('userName', 'String', 'Customer name snapshot', true),
  _FieldDef('userPhone', 'String', 'Customer phone snapshot', true),
  _FieldDef('items', 'Array<OrderItem>', 'Snapshot of cart items at order time', true),
  _FieldDef('subtotal', 'Number', 'Sum of all item prices (KSh)', true),
  _FieldDef('deliveryFee', 'Number', 'Delivery charge (KSh)', true),
  _FieldDef('total', 'Number', 'subtotal + deliveryFee', true),
  _FieldDef('status', 'String', 'pending | confirmed | processing | shipped | delivered | cancelled', true),
  _FieldDef('deliveryAddress', 'String', 'Full delivery address string', true),
  _FieldDef('notes', 'String?', 'Optional customer notes', false),
  _FieldDef('createdAt', 'ISO String', 'Order placement timestamp', true),
  _FieldDef('updatedAt', 'ISO String', 'Last status update timestamp', true),
];

// ─────────────────────────────────────────────────────────────
// Collection view widget
// ─────────────────────────────────────────────────────────────
class _CollectionView extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final List<Map<String, dynamic>> sampleDocs;
  final List<_FieldDef> schema;

  const _CollectionView({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.sampleDocs,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Collection header ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '/$name',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Firestore Collection  •  ${count >= 5 ? "$count+" : count} documents',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Schema ──────────────────────────────────────────
        _SectionHeader(title: 'Field Schema', icon: Icons.schema_rounded),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: schema
                .asMap()
                .entries
                .map((e) => _FieldRow(
                      field: e.value,
                      isLast: e.key == schema.length - 1,
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 16),

        // ── Sample data ──────────────────────────────────────
        _SectionHeader(
            title: 'Sample Documents (up to 5)', icon: Icons.dataset_rounded),
        const SizedBox(height: 8),
        if (sampleDocs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: const Center(
              child: Text(
                'No documents found in this collection.',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ),
          )
        else
          ...sampleDocs.map((doc) => _DocCard(doc: doc, color: color)),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Field row
// ─────────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final _FieldDef field;
  final bool isLast;

  const _FieldRow({required this.field, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required indicator
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: field.required
                      ? AppTheme.success
                      : AppTheme.textHint,
                ),
              ),
              const SizedBox(width: 10),
              // Field name
              SizedBox(
                width: 110,
                child: Text(
                  field.name,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              // Type
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  field.type,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Description
              Expanded(
                child: Text(
                  field.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Document card (sample data)
// ─────────────────────────────────────────────────────────────
class _DocCard extends StatefulWidget {
  final Map<String, dynamic> doc;
  final Color color;

  const _DocCard({required this.doc, required this.color});

  @override
  State<_DocCard> createState() => _DocCardState();
}

class _DocCardState extends State<_DocCard> {
  bool _expanded = false;

  String _prettyValue(dynamic v) {
    if (v == null) return 'null';
    if (v is Map) return '{...}';
    if (v is List) return '[${v.length} items]';
    final s = v.toString();
    return s.length > 60 ? '${s.substring(0, 60)}…' : s;
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.doc['id']?.toString() ?? '';
    final entries = widget.doc.entries
        .where((e) => e.key != 'id')
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_rounded,
                      size: 16, color: widget.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Clipboard.setData(
                        ClipboardData(text: widget.doc.toString())),
                    child: const Icon(Icons.copy_rounded,
                        size: 14, color: AppTheme.textHint),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textHint,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          // Expanded fields
          if (_expanded) ...[
            const Divider(height: 1, color: AppTheme.divider),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _prettyValue(e.value),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _FieldDef {
  final String name;
  final String type;
  final String description;
  final bool required;

  const _FieldDef(this.name, this.type, this.description, this.required);
}
