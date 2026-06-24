import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import 'admin_shell.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  final String? productId; // null = add, non-null = edit

  const AdminProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<AdminProductFormScreen> createState() =>
      _AdminProductFormScreenState();
}

class _AdminProductFormScreenState
    extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _originalPriceCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _unitCtrl;

  ProductCategory _category = ProductCategory.other;
  bool _isAvailable = true;
  bool _isFeatured = false;

  ProductModel? _editingProduct;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final products = ref.read(adminProductProvider);

    if (widget.productId != null) {
      try {
        _editingProduct =
            products.firstWhere((p) => p.id == widget.productId);
      } catch (_) {}
    }

    final p = _editingProduct;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? '${p.price.toInt()}' : '');
    _originalPriceCtrl = TextEditingController(
        text: p?.originalPrice != null
            ? '${p!.originalPrice!.toInt()}'
            : '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _stockCtrl = TextEditingController(
        text: p != null ? '${p.stockQuantity}' : '');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'pcs');
    _category = p?.category ?? ProductCategory.other;
    _isAvailable = p?.isAvailable ?? true;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _imageCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingProduct != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AdminAppBar(
        title: isEditing ? 'Edit Product' : 'Add Product',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Image preview ────────────────────────────
              if (_imageCtrl.text.isNotEmpty)
                Container(
                  height: 160,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    child: CachedNetworkImage(
                      imageUrl: _imageCtrl.text,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: AppTheme.textHint, size: 40),
                      ),
                    ),
                  ),
                ),

              _SectionLabel('Basic Info'),

              // Name
              _Field(
                controller: _nameCtrl,
                label: 'Product Name',
                icon: Icons.label_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              // Description
              _Field(
                controller: _descCtrl,
                label: 'Description',
                icon: Icons.notes_rounded,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 12),

              // Image URL
              TextFormField(
                controller: _imageCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon:
                      const Icon(Icons.image_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _SectionLabel('Pricing'),

              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _priceCtrl,
                      label: 'Price (KSh)',
                      icon: Icons.attach_money_rounded,
                      inputType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _originalPriceCtrl,
                      label: 'Original Price (optional)',
                      icon: Icons.money_off_rounded,
                      inputType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionLabel('Inventory'),

              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _stockCtrl,
                      label: 'Stock Qty',
                      icon: Icons.warehouse_rounded,
                      inputType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _unitCtrl,
                      label: 'Unit (e.g. kg, pcs)',
                      icon: Icons.straighten_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _SectionLabel('Category'),

              DropdownButtonFormField<ProductCategory>(
                value: _category,
                onChanged: (v) => setState(() => _category = v!),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.category_rounded, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMD),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                ),
                items: ProductCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_categoryLabel(cat)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _SectionLabel('Flags'),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Available for purchase',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Toggle to show/hide from customers',
                          style: TextStyle(fontSize: 12)),
                      value: _isAvailable,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                    const Divider(height: 1, color: AppTheme.divider),
                    SwitchListTile(
                      title: const Text('Featured product',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Shows in homepage banner',
                          style: TextStyle(fontSize: 12)),
                      value: _isFeatured,
                      activeColor: AppTheme.warning,
                      onChanged: (v) => setState(() => _isFeatured = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Save Button ──────────────────────────────
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Save Changes' : 'Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLG),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final notifier = ref.read(adminProductProvider.notifier);
    final now = DateTime.now();

    final product = ProductModel(
      id: _editingProduct?.id ?? notifier.generateId(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      originalPrice: _originalPriceCtrl.text.trim().isNotEmpty
          ? double.parse(_originalPriceCtrl.text.trim())
          : null,
      imageUrl: _imageCtrl.text.trim(),
      category: _category,
      stockQuantity: int.parse(_stockCtrl.text.trim()),
      unit: _unitCtrl.text.trim(),
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
      rating: _editingProduct?.rating ?? 0.0,
      reviewCount: _editingProduct?.reviewCount ?? 0,
      createdAt: _editingProduct?.createdAt ?? now,
      updatedAt: now,
    );

    if (_editingProduct != null) {
      notifier.updateProduct(product);
    } else {
      notifier.addProduct(product);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingProduct != null
              ? '${product.name} updated!'
              : '${product.name} added!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  String _categoryLabel(ProductCategory cat) {
    switch (cat) {
      case ProductCategory.fruits:      return 'Fruits';
      case ProductCategory.vegetables:  return 'Vegetables';
      case ProductCategory.dairy:       return 'Dairy & Eggs';
      case ProductCategory.meat:        return 'Meat & Fish';
      case ProductCategory.bakery:      return 'Bakery';
      case ProductCategory.beverages:   return 'Beverages';
      case ProductCategory.snacks:      return 'Snacks';
      case ProductCategory.household:   return 'Household';
      case ProductCategory.personal:    return 'Personal Care';
      case ProductCategory.electronics: return 'Electronics';
      case ProductCategory.stationery:  return 'Stationery';
      case ProductCategory.babycare:    return 'Baby Care';
      case ProductCategory.frozen:      return 'Frozen Foods';
      case ProductCategory.condiments:  return 'Condiments';
      case ProductCategory.other:       return 'Other';
    }
  }
}

// ── Helper Widgets ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.inputType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
      ),
    );
  }
}
