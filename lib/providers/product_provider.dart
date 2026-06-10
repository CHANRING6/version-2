import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

// ─────────────────────────────────────────────────────────────
// 50 SUPERMARKET PRODUCTS — 15 categories, Unsplash images
// ─────────────────────────────────────────────────────────────
final _mockProducts = <ProductModel>[

  // ── FRUITS ──────────────────────────────────────────────────
  ProductModel(
    id: 'p001', name: 'Fresh Strawberries',
    description: 'Sweet and juicy strawberries picked fresh from the farm. Perfect for smoothies, desserts, or eating straight from the punnet.',
    price: 250, originalPrice: 320,
    imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600&fit=crop',
    category: ProductCategory.fruits, stockQuantity: 50, unit: 'punnet',
    isFeatured: true, rating: 4.8, reviewCount: 124,
    createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
  ),
  ProductModel(
    id: 'p002', name: 'Ripe Mangoes',
    description: 'Juicy Kenyan mangoes at peak ripeness. Rich, sweet flavour with a smooth texture. Great for juice or eating fresh.',
    price: 180,
    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&fit=crop',
    category: ProductCategory.fruits, stockQuantity: 80, unit: 'kg',
    isFeatured: true, rating: 4.7, reviewCount: 98,
    createdAt: DateTime(2024, 1, 2), updatedAt: DateTime(2024, 1, 2),
  ),
  ProductModel(
    id: 'p003', name: 'Bananas',
    description: 'Fresh bunch of ripe bananas. High in potassium and natural energy. A household staple.',
    price: 60,
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&fit=crop',
    category: ProductCategory.fruits, stockQuantity: 120, unit: 'bunch',
    rating: 4.5, reviewCount: 210,
    createdAt: DateTime(2024, 1, 3), updatedAt: DateTime(2024, 1, 3),
  ),
  ProductModel(
    id: 'p004', name: 'Watermelon',
    description: 'Large sweet Kenyan watermelon. Refreshing and hydrating. Perfect for hot days.',
    price: 120, originalPrice: 150,
    imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&fit=crop',
    category: ProductCategory.fruits, stockQuantity: 30, unit: 'pcs',
    rating: 4.6, reviewCount: 77,
    createdAt: DateTime(2024, 1, 4), updatedAt: DateTime(2024, 1, 4),
  ),
  ProductModel(
    id: 'p005', name: 'Avocados',
    description: 'Creamy ripe Kenyan avocados. Rich in healthy fats. Great on toast, in salads or as guacamole.',
    price: 50,
    imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&fit=crop',
    category: ProductCategory.fruits, stockQuantity: 90, unit: 'pcs',
    isFeatured: true, rating: 4.9, reviewCount: 340,
    createdAt: DateTime(2024, 1, 5), updatedAt: DateTime(2024, 1, 5),
  ),

  // ── VEGETABLES ───────────────────────────────────────────────
  ProductModel(
    id: 'p006', name: 'Sukuma Wiki',
    description: 'Fresh collard greens sourced locally. A Kenyan staple rich in iron and vitamins.',
    price: 30,
    imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&fit=crop',
    category: ProductCategory.vegetables, stockQuantity: 200, unit: 'bunch',
    rating: 4.4, reviewCount: 305,
    createdAt: DateTime(2024, 1, 6), updatedAt: DateTime(2024, 1, 6),
  ),
  ProductModel(
    id: 'p007', name: 'Tomatoes',
    description: 'Farm-fresh red tomatoes. Plump, juicy and perfect for cooking or salads.',
    price: 80,
    imageUrl: 'https://images.unsplash.com/photo-1546470427-1ec6b777af4c?w=600&fit=crop',
    category: ProductCategory.vegetables, stockQuantity: 150, unit: 'kg',
    isFeatured: true, rating: 4.3, reviewCount: 189,
    createdAt: DateTime(2024, 1, 7), updatedAt: DateTime(2024, 1, 7),
  ),
  ProductModel(
    id: 'p008', name: 'Onions',
    description: 'Fresh red onions. A cooking essential for adding depth of flavour to any dish.',
    price: 60,
    imageUrl: 'https://images.unsplash.com/photo-1580201092675-a0a6a6cafbb1?w=600&fit=crop',
    category: ProductCategory.vegetables, stockQuantity: 200, unit: 'kg',
    rating: 4.2, reviewCount: 267,
    createdAt: DateTime(2024, 1, 8), updatedAt: DateTime(2024, 1, 8),
  ),
  ProductModel(
    id: 'p009', name: 'Capsicum / Pilipili Hoho',
    description: 'Colourful mixed bell peppers. Sweet and crisp. Perfect for stir fries, salads and stuffed pepper recipes.',
    price: 90, originalPrice: 120,
    imageUrl: 'https://images.unsplash.com/photo-1588891557811-5b3e3f3d0a8b?w=600&fit=crop',
    category: ProductCategory.vegetables, stockQuantity: 80, unit: 'pack',
    rating: 4.5, reviewCount: 143,
    createdAt: DateTime(2024, 1, 9), updatedAt: DateTime(2024, 1, 9),
  ),

  // ── DAIRY & EGGS ─────────────────────────────────────────────
  ProductModel(
    id: 'p010', name: 'Fresh Whole Milk',
    description: 'Pure pasteurised whole milk. Rich in calcium and protein. Delivered fresh daily.',
    price: 65,
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&fit=crop',
    category: ProductCategory.dairy, stockQuantity: 80, unit: '500ml',
    rating: 4.6, reviewCount: 412,
    createdAt: DateTime(2024, 1, 10), updatedAt: DateTime(2024, 1, 10),
  ),
  ProductModel(
    id: 'p011', name: 'Free Range Eggs',
    description: 'Fresh free-range eggs. High in protein and omega-3. Direct from local farms.',
    price: 180, originalPrice: 210,
    imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=600&fit=crop',
    category: ProductCategory.dairy, stockQuantity: 200, unit: 'tray (30)',
    isFeatured: true, rating: 4.9, reviewCount: 567,
    createdAt: DateTime(2024, 1, 11), updatedAt: DateTime(2024, 1, 11),
  ),
  ProductModel(
    id: 'p012', name: 'Natural Yoghurt',
    description: 'Creamy natural yoghurt rich in probiotics and calcium. No added sugar.',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&fit=crop',
    category: ProductCategory.dairy, stockQuantity: 60, unit: '400g',
    rating: 4.5, reviewCount: 88,
    createdAt: DateTime(2024, 1, 12), updatedAt: DateTime(2024, 1, 12),
  ),
  ProductModel(
    id: 'p013', name: 'Butter',
    description: 'Creamy unsalted butter made from pure fresh cream. Perfect for baking and cooking.',
    price: 200,
    imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=600&fit=crop',
    category: ProductCategory.dairy, stockQuantity: 45, unit: '250g',
    rating: 4.4, reviewCount: 155,
    createdAt: DateTime(2024, 1, 13), updatedAt: DateTime(2024, 1, 13),
  ),

  // ── MEAT & FISH ───────────────────────────────────────────────
  ProductModel(
    id: 'p014', name: 'Beef Mince',
    description: 'Fresh lean beef mince. Perfect for burgers, bolognese and pilau. Sourced from local butchers.',
    price: 550,
    imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=600&fit=crop',
    category: ProductCategory.meat, stockQuantity: 40, unit: 'kg',
    isFeatured: true, rating: 4.7, reviewCount: 201,
    createdAt: DateTime(2024, 1, 14), updatedAt: DateTime(2024, 1, 14),
  ),
  ProductModel(
    id: 'p015', name: 'Chicken Breast',
    description: 'Boneless skinless chicken breast. High in protein and low in fat.',
    price: 480, originalPrice: 550,
    imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=600&fit=crop',
    category: ProductCategory.meat, stockQuantity: 35, unit: 'kg',
    rating: 4.6, reviewCount: 178,
    createdAt: DateTime(2024, 1, 15), updatedAt: DateTime(2024, 1, 15),
  ),
  ProductModel(
    id: 'p016', name: 'Tilapia Fish',
    description: 'Fresh whole tilapia from Lake Victoria. Cleaned and ready to cook.',
    price: 350,
    imageUrl: 'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=600&fit=crop',
    category: ProductCategory.meat, stockQuantity: 25, unit: 'pcs',
    rating: 4.5, reviewCount: 134,
    createdAt: DateTime(2024, 1, 16), updatedAt: DateTime(2024, 1, 16),
  ),

  // ── BAKERY ───────────────────────────────────────────────────
  ProductModel(
    id: 'p017', name: 'Sliced White Bread',
    description: 'Freshly baked sliced white bread. Soft and fluffy. Perfect for sandwiches and toast.',
    price: 65,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&fit=crop',
    category: ProductCategory.bakery, stockQuantity: 90, unit: 'loaf',
    rating: 4.4, reviewCount: 320,
    createdAt: DateTime(2024, 1, 17), updatedAt: DateTime(2024, 1, 17),
  ),
  ProductModel(
    id: 'p018', name: 'Mandazi',
    description: 'Freshly fried Kenyan mandazi. Light, airy and slightly sweet.',
    price: 20,
    imageUrl: 'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?w=600&fit=crop',
    category: ProductCategory.bakery, stockQuantity: 100, unit: 'pcs',
    rating: 4.8, reviewCount: 445,
    createdAt: DateTime(2024, 1, 18), updatedAt: DateTime(2024, 1, 18),
  ),
  ProductModel(
    id: 'p019', name: 'Doughnuts',
    description: 'Freshly made glazed doughnuts. Soft, fluffy and irresistibly sweet.',
    price: 40,
    imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&fit=crop',
    category: ProductCategory.bakery, stockQuantity: 60, unit: 'pcs',
    rating: 4.7, reviewCount: 289,
    createdAt: DateTime(2024, 1, 19), updatedAt: DateTime(2024, 1, 19),
  ),

  // ── BEVERAGES ────────────────────────────────────────────────
  ProductModel(
    id: 'p020', name: 'Mineral Water',
    description: 'Pure natural mineral water. Crisp and refreshing.',
    price: 60,
    imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600&fit=crop',
    category: ProductCategory.beverages, stockQuantity: 300, unit: '1.5L',
    rating: 4.3, reviewCount: 230,
    createdAt: DateTime(2024, 1, 20), updatedAt: DateTime(2024, 1, 20),
  ),
  ProductModel(
    id: 'p021', name: 'Mango Juice',
    description: 'Natural mango juice with no added preservatives. Thick, sweet and refreshing.',
    price: 95, originalPrice: 120,
    imageUrl: 'https://images.unsplash.com/photo-1546173159-315724a31696?w=600&fit=crop',
    category: ProductCategory.beverages, stockQuantity: 120, unit: '500ml',
    isFeatured: true, rating: 4.7, reviewCount: 167,
    createdAt: DateTime(2024, 1, 21), updatedAt: DateTime(2024, 1, 21),
  ),
  ProductModel(
    id: 'p022', name: 'Kenyan Tea (Chai)',
    description: 'Premium loose leaf Kenyan tea from the highlands. Rich, bold and full of flavour.',
    price: 150,
    imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&fit=crop',
    category: ProductCategory.beverages, stockQuantity: 100, unit: '200g',
    isFeatured: true, rating: 4.9, reviewCount: 520,
    createdAt: DateTime(2024, 1, 22), updatedAt: DateTime(2024, 1, 22),
  ),
  ProductModel(
    id: 'p023', name: 'Instant Coffee',
    description: 'Rich and aromatic instant coffee. Ready in seconds for a perfect morning cup.',
    price: 280,
    imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&fit=crop',
    category: ProductCategory.beverages, stockQuantity: 80, unit: '200g',
    rating: 4.5, reviewCount: 312,
    createdAt: DateTime(2024, 1, 23), updatedAt: DateTime(2024, 1, 23),
  ),

  // ── SNACKS ───────────────────────────────────────────────────
  ProductModel(
    id: 'p024', name: 'Potato Crisps',
    description: 'Crunchy salted potato crisps. The perfect snack for any time of day.',
    price: 50,
    imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=600&fit=crop',
    category: ProductCategory.snacks, stockQuantity: 200, unit: 'pack',
    rating: 4.2, reviewCount: 389,
    createdAt: DateTime(2024, 1, 24), updatedAt: DateTime(2024, 1, 24),
  ),
  ProductModel(
    id: 'p025', name: 'Chocolate Bar',
    description: 'Rich creamy milk chocolate. A classic indulgence for chocolate lovers.',
    price: 85,
    imageUrl: 'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=600&fit=crop',
    category: ProductCategory.snacks, stockQuantity: 150, unit: '100g',
    rating: 4.5, reviewCount: 276,
    createdAt: DateTime(2024, 1, 25), updatedAt: DateTime(2024, 1, 25),
  ),
  ProductModel(
    id: 'p026', name: 'Groundnuts / Peanuts',
    description: 'Roasted and salted groundnuts. A protein-packed Kenyan street food favourite.',
    price: 40,
    imageUrl: 'https://images.unsplash.com/photo-1567892737950-30c4db37cd89?w=600&fit=crop',
    category: ProductCategory.snacks, stockQuantity: 250, unit: '200g',
    rating: 4.6, reviewCount: 198,
    createdAt: DateTime(2024, 1, 26), updatedAt: DateTime(2024, 1, 26),
  ),

  // ── CONDIMENTS ───────────────────────────────────────────────
  ProductModel(
    id: 'p027', name: 'Tomato Ketchup',
    description: 'Classic rich tomato ketchup. Great with fries, burgers and sausages.',
    price: 180,
    imageUrl: 'https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=600&fit=crop',
    category: ProductCategory.condiments, stockQuantity: 70, unit: '500g',
    rating: 4.3, reviewCount: 145,
    createdAt: DateTime(2024, 1, 27), updatedAt: DateTime(2024, 1, 27),
  ),
  ProductModel(
    id: 'p028', name: 'Cooking Oil',
    description: 'Pure sunflower cooking oil. Light, neutral flavour ideal for frying and baking.',
    price: 350, originalPrice: 400,
    imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600&fit=crop',
    category: ProductCategory.condiments, stockQuantity: 90, unit: '2L',
    isFeatured: true, rating: 4.5, reviewCount: 430,
    createdAt: DateTime(2024, 1, 28), updatedAt: DateTime(2024, 1, 28),
  ),
  ProductModel(
    id: 'p029', name: 'Sugar',
    description: 'Fine white granulated sugar. A pantry essential for cooking, baking and beverages.',
    price: 200,
    imageUrl: 'https://images.unsplash.com/photo-1585854467604-cf2080ccbc46?w=600&fit=crop',
    category: ProductCategory.condiments, stockQuantity: 120, unit: '2kg',
    rating: 4.4, reviewCount: 380,
    createdAt: DateTime(2024, 1, 29), updatedAt: DateTime(2024, 1, 29),
  ),
  ProductModel(
    id: 'p030', name: 'Salt',
    description: 'Iodised table salt. Essential for seasoning every meal.',
    price: 50,
    imageUrl: 'https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=600&fit=crop',
    category: ProductCategory.condiments, stockQuantity: 200, unit: '500g',
    rating: 4.2, reviewCount: 210,
    createdAt: DateTime(2024, 1, 30), updatedAt: DateTime(2024, 1, 30),
  ),

  // ── FROZEN FOODS ─────────────────────────────────────────────
  ProductModel(
    id: 'p031', name: 'Frozen Chips / Fries',
    description: 'Pre-cut frozen potato chips. Ready in minutes. Perfect golden and crispy every time.',
    price: 280,
    imageUrl: 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600&fit=crop',
    category: ProductCategory.frozen, stockQuantity: 60, unit: '1kg',
    rating: 4.6, reviewCount: 312,
    createdAt: DateTime(2024, 2, 1), updatedAt: DateTime(2024, 2, 1),
  ),
  ProductModel(
    id: 'p032', name: 'Ice Cream',
    description: 'Creamy vanilla ice cream. Made with real dairy for the richest flavour.',
    price: 320, originalPrice: 380,
    imageUrl: 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=600&fit=crop',
    category: ProductCategory.frozen, stockQuantity: 40, unit: '500ml',
    isFeatured: true, rating: 4.8, reviewCount: 278,
    createdAt: DateTime(2024, 2, 2), updatedAt: DateTime(2024, 2, 2),
  ),
  ProductModel(
    id: 'p033', name: 'Frozen Peas',
    description: 'Sweet garden peas flash-frozen at peak freshness. Retain all their nutrients and flavour.',
    price: 160,
    imageUrl: 'https://images.unsplash.com/photo-1587049332298-1c42e83937a7?w=600&fit=crop',
    category: ProductCategory.frozen, stockQuantity: 55, unit: '500g',
    rating: 4.3, reviewCount: 112,
    createdAt: DateTime(2024, 2, 3), updatedAt: DateTime(2024, 2, 3),
  ),

  // ── HOUSEHOLD ────────────────────────────────────────────────
  ProductModel(
    id: 'p034', name: 'Dishwashing Liquid',
    description: 'Powerful dishwashing liquid that cuts through grease. Gentle on hands, tough on stains.',
    price: 110,
    imageUrl: 'https://images.unsplash.com/photo-1585837146751-a44118595680?w=600&fit=crop',
    category: ProductCategory.household, stockQuantity: 80, unit: '500ml',
    rating: 4.3, reviewCount: 142,
    createdAt: DateTime(2024, 2, 4), updatedAt: DateTime(2024, 2, 4),
  ),
  ProductModel(
    id: 'p035', name: 'Laundry Detergent',
    description: 'High-performance laundry powder. Removes tough stains and leaves clothes smelling fresh.',
    price: 250, originalPrice: 300,
    imageUrl: 'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?w=600&fit=crop',
    category: ProductCategory.household, stockQuantity: 60, unit: '1kg',
    rating: 4.4, reviewCount: 198,
    createdAt: DateTime(2024, 2, 5), updatedAt: DateTime(2024, 2, 5),
  ),
  ProductModel(
    id: 'p036', name: 'Toilet Paper',
    description: '3-ply super soft toilet rolls. Strong and gentle. Pack of 10 rolls.',
    price: 320,
    imageUrl: 'https://images.unsplash.com/photo-1584949091598-c31daaaa4aa9?w=600&fit=crop',
    category: ProductCategory.household, stockQuantity: 100, unit: 'pack (10)',
    isFeatured: true, rating: 4.6, reviewCount: 445,
    createdAt: DateTime(2024, 2, 6), updatedAt: DateTime(2024, 2, 6),
  ),
  ProductModel(
    id: 'p037', name: 'Mosquito Coils',
    description: 'Long-lasting mosquito coils. Burn for up to 8 hours keeping mosquitoes away.',
    price: 80,
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&fit=crop',
    category: ProductCategory.household, stockQuantity: 150, unit: 'pack (10)',
    rating: 4.2, reviewCount: 267,
    createdAt: DateTime(2024, 2, 7), updatedAt: DateTime(2024, 2, 7),
  ),

  // ── PERSONAL CARE ─────────────────────────────────────────────
  ProductModel(
    id: 'p038', name: 'Body Lotion',
    description: 'Nourishing body lotion with shea butter. Keeps skin soft and moisturised all day.',
    price: 320,
    imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=600&fit=crop',
    category: ProductCategory.personal, stockQuantity: 45, unit: '400ml',
    rating: 4.6, reviewCount: 112,
    createdAt: DateTime(2024, 2, 8), updatedAt: DateTime(2024, 2, 8),
  ),
  ProductModel(
    id: 'p039', name: 'Toothpaste',
    description: 'Fluoride toothpaste for strong teeth and fresh breath. Protects against cavities.',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1559591935-c4c6b58d8dc0?w=600&fit=crop',
    category: ProductCategory.personal, stockQuantity: 100, unit: '100ml',
    rating: 4.4, reviewCount: 234,
    createdAt: DateTime(2024, 2, 9), updatedAt: DateTime(2024, 2, 9),
  ),
  ProductModel(
    id: 'p040', name: 'Shower Gel',
    description: 'Refreshing shower gel with a long-lasting fresh scent. Leaves skin clean and soft.',
    price: 180, originalPrice: 220,
    imageUrl: 'https://images.unsplash.com/photo-1556760544-74068565f05c?w=600&fit=crop',
    category: ProductCategory.personal, stockQuantity: 70, unit: '250ml',
    rating: 4.5, reviewCount: 178,
    createdAt: DateTime(2024, 2, 10), updatedAt: DateTime(2024, 2, 10),
  ),
  ProductModel(
    id: 'p041', name: 'Sanitary Pads',
    description: 'Ultra-thin sanitary pads with wings. Maximum comfort and protection all day.',
    price: 150,
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&fit=crop',
    category: ProductCategory.personal, stockQuantity: 120, unit: 'pack (8)',
    rating: 4.7, reviewCount: 389,
    createdAt: DateTime(2024, 2, 11), updatedAt: DateTime(2024, 2, 11),
  ),

  // ── ELECTRONICS ──────────────────────────────────────────────
  ProductModel(
    id: 'p042', name: 'AA Batteries',
    description: 'Long-lasting AA alkaline batteries. Reliable power for remotes, torches and toys. Pack of 4.',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&fit=crop',
    category: ProductCategory.electronics, stockQuantity: 200, unit: 'pack (4)',
    rating: 4.4, reviewCount: 156,
    createdAt: DateTime(2024, 2, 12), updatedAt: DateTime(2024, 2, 12),
  ),
  ProductModel(
    id: 'p043', name: 'Phone Charger Cable',
    description: 'Universal fast-charging cable. Compatible with most Android and iOS devices. 1 metre.',
    price: 350, originalPrice: 450,
    imageUrl: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=600&fit=crop',
    category: ProductCategory.electronics, stockQuantity: 80, unit: 'pcs',
    isFeatured: true, rating: 4.3, reviewCount: 223,
    createdAt: DateTime(2024, 2, 13), updatedAt: DateTime(2024, 2, 13),
  ),
  ProductModel(
    id: 'p044', name: 'LED Bulb',
    description: 'Energy-saving LED bulb. Lasts up to 25,000 hours. Bright white light ideal for any room.',
    price: 180,
    imageUrl: 'https://images.unsplash.com/photo-1513506003901-1e6a35f87251?w=600&fit=crop',
    category: ProductCategory.electronics, stockQuantity: 100, unit: 'pcs',
    rating: 4.6, reviewCount: 312,
    createdAt: DateTime(2024, 2, 14), updatedAt: DateTime(2024, 2, 14),
  ),
  ProductModel(
    id: 'p045', name: 'Extension Cord',
    description: '4-socket extension cord with surge protection. 1.8m cable. Safe and durable.',
    price: 650, originalPrice: 800,
    imageUrl: 'https://images.unsplash.com/photo-1558618047-f8e8e4c87dcb?w=600&fit=crop',
    category: ProductCategory.electronics, stockQuantity: 45, unit: 'pcs',
    rating: 4.5, reviewCount: 134,
    createdAt: DateTime(2024, 2, 15), updatedAt: DateTime(2024, 2, 15),
  ),

  // ── STATIONERY ───────────────────────────────────────────────
  ProductModel(
    id: 'p046', name: 'Exercise Books',
    description: 'A4 ruled exercise books. 96 pages. High quality paper. Ideal for school and office.',
    price: 35,
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&fit=crop',
    category: ProductCategory.stationery, stockQuantity: 300, unit: 'pcs',
    rating: 4.3, reviewCount: 445,
    createdAt: DateTime(2024, 2, 16), updatedAt: DateTime(2024, 2, 16),
  ),
  ProductModel(
    id: 'p047', name: 'Ballpoint Pens',
    description: 'Smooth-writing ballpoint pens. Blue ink. Pack of 10. Perfect for everyday use.',
    price: 80,
    imageUrl: 'https://images.unsplash.com/photo-1585336261022-680e295ce3fe?w=600&fit=crop',
    category: ProductCategory.stationery, stockQuantity: 250, unit: 'pack (10)',
    rating: 4.4, reviewCount: 289,
    createdAt: DateTime(2024, 2, 17), updatedAt: DateTime(2024, 2, 17),
  ),
  ProductModel(
    id: 'p048', name: 'Stapler',
    description: 'Heavy duty desktop stapler. Includes 1000 staples. Handles up to 30 sheets.',
    price: 320, originalPrice: 400,
    imageUrl: 'https://images.unsplash.com/photo-1568952433726-3896e3881c65?w=600&fit=crop',
    category: ProductCategory.stationery, stockQuantity: 60, unit: 'pcs',
    rating: 4.2, reviewCount: 78,
    createdAt: DateTime(2024, 2, 18), updatedAt: DateTime(2024, 2, 18),
  ),

  // ── BABY CARE ─────────────────────────────────────────────────
  ProductModel(
    id: 'p049', name: 'Baby Diapers',
    description: 'Ultra-absorbent baby diapers. Soft inner lining prevents rashes. Available in size M.',
    price: 950, originalPrice: 1100,
    imageUrl: 'https://images.unsplash.com/photo-1612035165219-7e3b89dbb5bf?w=600&fit=crop',
    category: ProductCategory.babycare, stockQuantity: 40, unit: 'pack (40)',
    isFeatured: true, rating: 4.8, reviewCount: 567,
    createdAt: DateTime(2024, 2, 19), updatedAt: DateTime(2024, 2, 19),
  ),
  ProductModel(
    id: 'p050', name: 'Baby Wipes',
    description: 'Gentle fragrance-free baby wipes. Hypoallergenic and safe for sensitive skin. Pack of 80.',
    price: 280,
    imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=600&fit=crop',
    category: ProductCategory.babycare, stockQuantity: 80, unit: 'pack (80)',
    rating: 4.7, reviewCount: 312,
    createdAt: DateTime(2024, 2, 20), updatedAt: DateTime(2024, 2, 20),
  ),
];

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────
final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  return Stream.value(_mockProducts);
});

final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return Stream.value(
      _mockProducts.where((p) => p.isFeatured).toList());
});

final selectedCategoryProvider =
    StateProvider<ProductCategory?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider =
    Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery =
      ref.watch(searchQueryProvider).toLowerCase().trim();

  return productsAsync.whenData((products) {
    var filtered = products;
    if (selectedCategory != null) {
      filtered =
          filtered.where((p) => p.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery) ||
              p.description.toLowerCase().contains(searchQuery) ||
              p.categoryLabel.toLowerCase().contains(searchQuery))
          .toList();
    }
    return filtered;
  });
});

final productByIdProvider =
    FutureProvider.family<ProductModel?, String>((ref, productId) async {
  try {
    return _mockProducts.firstWhere((p) => p.id == productId);
  } catch (_) {
    return _mockProducts.isNotEmpty ? _mockProducts.first : null;
  }
});

// ── Cart Notifier ────────────────────────────────────────────
class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(ProductModel product) {
    final existingIndex =
        state.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      final updated = List<CartItemModel>.from(state);
      updated[existingIndex] = updated[existingIndex].copyWith(
          quantity: updated[existingIndex].quantity + 1);
      state = updated;
    } else {
      state = [
        ...state,
        CartItemModel(id: product.id, product: product, quantity: 1),
      ];
    }
  }

  void removeItem(String productId) {
    final existingIndex =
        state.indexWhere((item) => item.id == productId);
    if (existingIndex < 0) return;
    final current = state[existingIndex];
    if (current.quantity > 1) {
      final updated = List<CartItemModel>.from(state);
      updated[existingIndex] =
          current.copyWith(quantity: current.quantity - 1);
      state = updated;
    } else {
      state = state.where((item) => item.id != productId).toList();
    }
  }

  void deleteItem(String productId) =>
      state = state.where((item) => item.id != productId).toList();

  void clearCart() => state = [];

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      deleteItem(productId);
      return;
    }
    final updated = List<CartItemModel>.from(state);
    final index = updated.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = updated;
    }
  }

  bool isInCart(String productId) =>
      state.any((item) => item.id == productId);

  int getQuantity(String productId) {
    final index = state.indexWhere((item) => item.id == productId);
    return index < 0 ? 0 : state[index].quantity;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>(
        (ref) => CartNotifier());

final cartItemCountProvider = Provider<int>((ref) =>
    ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity));

final cartSubtotalProvider = Provider<double>((ref) =>
    ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.totalPrice));

final deliveryFeeProvider = Provider<double>(
    (ref) => ref.watch(cartSubtotalProvider) >= 2000 ? 0.0 : 200.0);

final cartTotalProvider = Provider<double>((ref) =>
    ref.watch(cartSubtotalProvider) + ref.watch(deliveryFeeProvider));

final cartSubtotalStringProvider = Provider<String>((ref) =>
    'KSh ${ref.watch(cartSubtotalProvider).toStringAsFixed(0)}');

final cartTotalStringProvider = Provider<String>((ref) =>
    'KSh ${ref.watch(cartTotalProvider).toStringAsFixed(0)}');

final deliveryFeeStringProvider = Provider<String>((ref) {
  final fee = ref.watch(deliveryFeeProvider);
  return fee == 0 ? 'FREE' : 'KSh ${fee.toStringAsFixed(0)}';
});

final isCartEmptyProvider =
    Provider<bool>((ref) => ref.watch(cartProvider).isEmpty);