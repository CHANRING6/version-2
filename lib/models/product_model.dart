import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  fruits,
  vegetables,
  dairy,
  meat,
  bakery,
  beverages,
  snacks,
  household,
  personal,
  electronics,
  stationery,
  babycare,
  frozen,
  condiments,
  other,
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final ProductCategory category;
  final int stockQuantity;
  final String unit;
  final bool isAvailable;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl = '',
    this.category = ProductCategory.other,
    this.stockQuantity = 0,
    this.unit = 'pcs',
    this.isAvailable = true,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Factory: from Firestore document ─────────────────────────
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      category:
          _categoryFromString(map['category'] as String? ?? 'other'),
      stockQuantity: map['stockQuantity'] as int? ?? 0,
      unit: map['unit'] as String? ?? 'pcs',
      isAvailable: map['isAvailable'] as bool? ?? true,
      isFeatured: map['isFeatured'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // ── Factory: from Firestore DocumentSnapshot ─────────────────
  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel.fromMap(data, doc.id);
  }

  // ── Convert to Map for Firestore ─────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category.name,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ── CopyWith ─────────────────────────────────────────────────
  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    ProductCategory? category,
    int? stockQuantity,
    String? unit,
    bool? isAvailable,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  bool get isOnSale =>
      originalPrice != null && originalPrice! > price;

  double get discountPercent {
    if (!isOnSale) return 0;
    return ((originalPrice! - price) / originalPrice! * 100)
        .roundToDouble();
  }

  bool get inStock => stockQuantity > 0 && isAvailable;

  String get formattedPrice => 'KSh ${price.toStringAsFixed(0)}';

  String get formattedOriginalPrice => originalPrice != null
      ? 'KSh ${originalPrice!.toStringAsFixed(0)}'
      : '';

  String get categoryLabel {
    switch (category) {
      case ProductCategory.fruits:       return 'Fruits';
      case ProductCategory.vegetables:   return 'Vegetables';
      case ProductCategory.dairy:        return 'Dairy & Eggs';
      case ProductCategory.meat:         return 'Meat & Fish';
      case ProductCategory.bakery:       return 'Bakery';
      case ProductCategory.beverages:    return 'Beverages';
      case ProductCategory.snacks:       return 'Snacks';
      case ProductCategory.household:    return 'Household';
      case ProductCategory.personal:     return 'Personal Care';
      case ProductCategory.electronics:  return 'Electronics';
      case ProductCategory.stationery:   return 'Stationery';
      case ProductCategory.babycare:     return 'Baby Care';
      case ProductCategory.frozen:       return 'Frozen Foods';
      case ProductCategory.condiments:   return 'Condiments';
      case ProductCategory.other:        return 'Other';
    }
  }

  // ── Private Helpers ───────────────────────────────────────────
  static ProductCategory _categoryFromString(String value) {
    switch (value.toLowerCase()) {
      case 'fruits':       return ProductCategory.fruits;
      case 'vegetables':   return ProductCategory.vegetables;
      case 'dairy':        return ProductCategory.dairy;
      case 'meat':         return ProductCategory.meat;
      case 'bakery':       return ProductCategory.bakery;
      case 'beverages':    return ProductCategory.beverages;
      case 'snacks':       return ProductCategory.snacks;
      case 'household':    return ProductCategory.household;
      case 'personal':     return ProductCategory.personal;
      case 'electronics':  return ProductCategory.electronics;
      case 'stationery':   return ProductCategory.stationery;
      case 'babycare':     return ProductCategory.babycare;
      case 'frozen':       return ProductCategory.frozen;
      case 'condiments':   return ProductCategory.condiments;
      default:             return ProductCategory.other;
    }
  }

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, price: $formattedPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}