// ─────────────────────────────────────────────────────────────
// SEED DATA SCRIPT
// Run once to populate Firestore with sample products.
// Call SeedData.run() from a temporary button or from main().
// ─────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static final _db = FirebaseFirestore.instance;

  static Future<void> run() async {
    final batch = _db.batch();
    for (final p in _products) {
      final ref = _db.collection('products').doc();
      batch.set(ref, {
        ...p,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    print('✅ Seeded ${_products.length} products!');
  }

  static final _products = [
    // ── FRUITS ──────────────────────────────────────────────
    {
      'name': 'Fresh Bananas',
      'description': 'Sweet and ripe bananas, perfect for snacking or smoothies. Rich in potassium and natural energy.',
      'price': 80.0, 'originalPrice': 100.0,
      'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&q=80',
      'category': 'fruits', 'stockQuantity': 150, 'unit': 'bunch',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.8, 'reviewCount': 124,
    },
    {
      'name': 'Red Apples',
      'description': 'Crisp and juicy red apples sourced from the highlands. High in fiber and antioxidants.',
      'price': 200.0, 'originalPrice': 250.0,
      'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&q=80',
      'category': 'fruits', 'stockQuantity': 80, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.6, 'reviewCount': 89,
    },
    {
      'name': 'Watermelon',
      'description': 'Large, sweet watermelon. Perfect for hot days. Hydrating and delicious.',
      'price': 350.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&q=80',
      'category': 'fruits', 'stockQuantity': 30, 'unit': 'piece',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.7, 'reviewCount': 56,
    },
    {
      'name': 'Mango',
      'description': 'Sweet Kenyan mangoes, hand-picked at peak ripeness. Rich in vitamin C.',
      'price': 50.0, 'originalPrice': 70.0,
      'imageUrl': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400&q=80',
      'category': 'fruits', 'stockQuantity': 100, 'unit': 'piece',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.9, 'reviewCount': 203,
    },
    {
      'name': 'Strawberries',
      'description': 'Fresh, plump strawberries. Perfect for desserts, smoothies, or eating fresh.',
      'price': 180.0, 'originalPrice': 220.0,
      'imageUrl': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&q=80',
      'category': 'fruits', 'stockQuantity': 60, 'unit': 'punnet',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 78,
    },

    // ── VEGETABLES ──────────────────────────────────────────
    {
      'name': 'Tomatoes',
      'description': 'Farm-fresh tomatoes, great for cooking, sauces, and salads. Juicy and flavourful.',
      'price': 60.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1546470427-e26264be0b0e?w=400&q=80',
      'category': 'vegetables', 'stockQuantity': 200, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 112,
    },
    {
      'name': 'Spinach',
      'description': 'Fresh organic spinach. Loaded with iron, vitamins, and minerals.',
      'price': 40.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
      'category': 'vegetables', 'stockQuantity': 120, 'unit': 'bunch',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.3, 'reviewCount': 67,
    },
    {
      'name': 'Carrots',
      'description': 'Crunchy orange carrots. Excellent for cooking, juicing, or snacking.',
      'price': 70.0, 'originalPrice': 90.0,
      'imageUrl': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
      'category': 'vegetables', 'stockQuantity': 150, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 84,
    },
    {
      'name': 'Broccoli',
      'description': 'Fresh green broccoli heads. A superfood packed with vitamins C and K.',
      'price': 120.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80',
      'category': 'vegetables', 'stockQuantity': 75, 'unit': 'head',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 45,
    },
    {
      'name': 'Onions',
      'description': 'Red and white onions. Essential kitchen staple for all types of cooking.',
      'price': 80.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
      'category': 'vegetables', 'stockQuantity': 300, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.2, 'reviewCount': 93,
    },

    // ── DAIRY ───────────────────────────────────────────────
    {
      'name': 'Fresh Milk (1L)',
      'description': 'Fresh whole milk from local Kenyan dairy farms. Pasteurized and homogenized.',
      'price': 65.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80',
      'category': 'dairy', 'stockQuantity': 200, 'unit': 'litre',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.7, 'reviewCount': 189,
    },
    {
      'name': 'Cheddar Cheese',
      'description': 'Mature cheddar cheese block. Rich, sharp flavour perfect for sandwiches and cooking.',
      'price': 450.0, 'originalPrice': 520.0,
      'imageUrl': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&q=80',
      'category': 'dairy', 'stockQuantity': 50, 'unit': '250g',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 72,
    },
    {
      'name': 'Natural Yoghurt',
      'description': 'Creamy natural yoghurt with live cultures. Great for breakfast or as a snack.',
      'price': 120.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&q=80',
      'category': 'dairy', 'stockQuantity': 80, 'unit': '500g',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 98,
    },
    {
      'name': 'Eggs (Tray)',
      'description': 'Farm-fresh eggs from free-range hens. 30 eggs per tray.',
      'price': 550.0, 'originalPrice': 600.0,
      'imageUrl': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
      'category': 'dairy', 'stockQuantity': 60, 'unit': 'tray',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.8, 'reviewCount': 215,
    },
    {
      'name': 'Butter (250g)',
      'description': 'Creamy salted butter. Perfect for baking, cooking, or spreading on bread.',
      'price': 280.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&q=80',
      'category': 'dairy', 'stockQuantity': 90, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 63,
    },

    // ── MEAT ────────────────────────────────────────────────
    {
      'name': 'Chicken Breast',
      'description': 'Boneless, skinless chicken breast. Lean protein perfect for grilling or stir-frying.',
      'price': 650.0, 'originalPrice': 800.0,
      'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80',
      'category': 'meat', 'stockQuantity': 40, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.7, 'reviewCount': 143,
    },
    {
      'name': 'Beef Mince',
      'description': 'Fresh lean beef mince. Ideal for bolognese, burgers, or chapati filling.',
      'price': 750.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&q=80',
      'category': 'meat', 'stockQuantity': 35, 'unit': 'kg',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 87,
    },
    {
      'name': 'Tilapia Fish',
      'description': 'Fresh Lake Victoria tilapia. Cleaned and ready to cook.',
      'price': 400.0, 'originalPrice': 480.0,
      'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80',
      'category': 'meat', 'stockQuantity': 25, 'unit': 'piece',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 59,
    },

    // ── BAKERY ──────────────────────────────────────────────
    {
      'name': 'White Bread Loaf',
      'description': 'Freshly baked soft white bread. Sliced and ready for sandwiches or toast.',
      'price': 65.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
      'category': 'bakery', 'stockQuantity': 100, 'unit': 'loaf',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 176,
    },
    {
      'name': 'Croissants (4-pack)',
      'description': 'Buttery, flaky croissants baked fresh daily. Perfect with jam or cheese.',
      'price': 250.0, 'originalPrice': 300.0,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
      'category': 'bakery', 'stockQuantity': 40, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.8, 'reviewCount': 92,
    },
    {
      'name': 'Chocolate Cake',
      'description': 'Rich moist chocolate cake with chocolate frosting. Serves 8.',
      'price': 950.0, 'originalPrice': 1100.0,
      'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80',
      'category': 'bakery', 'stockQuantity': 15, 'unit': 'whole',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.9, 'reviewCount': 134,
    },

    // ── BEVERAGES ───────────────────────────────────────────
    {
      'name': 'Orange Juice (1L)',
      'description': '100% pure squeezed orange juice. No added sugar or preservatives.',
      'price': 220.0, 'originalPrice': 260.0,
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&q=80',
      'category': 'beverages', 'stockQuantity': 90, 'unit': 'litre',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 108,
    },
    {
      'name': 'Mineral Water (6-pack)',
      'description': 'Pure natural mineral water. 500ml bottles, pack of 6.',
      'price': 180.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&q=80',
      'category': 'beverages', 'stockQuantity': 200, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.3, 'reviewCount': 241,
    },
    {
      'name': 'Kenyan Tea (500g)',
      'description': 'Premium loose-leaf Kenyan black tea from the highlands of Kericho.',
      'price': 320.0, 'originalPrice': 380.0,
      'imageUrl': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&q=80',
      'category': 'beverages', 'stockQuantity': 75, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.8, 'reviewCount': 167,
    },
    {
      'name': 'Instant Coffee (200g)',
      'description': 'Rich Arabica instant coffee. Smooth and aromatic, perfect to start your day.',
      'price': 480.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&q=80',
      'category': 'beverages', 'stockQuantity': 60, 'unit': 'jar',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 129,
    },
    {
      'name': 'Soda Cans (4-pack)',
      'description': 'Assorted soft drinks — Coke, Fanta, Sprite. Chilled and refreshing.',
      'price': 280.0, 'originalPrice': 320.0,
      'imageUrl': 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=400&q=80',
      'category': 'beverages', 'stockQuantity': 120, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 95,
    },

    // ── SNACKS ──────────────────────────────────────────────
    {
      'name': 'Potato Crisps',
      'description': 'Crunchy salted potato crisps. The ultimate snack for movie nights.',
      'price': 90.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&q=80',
      'category': 'snacks', 'stockQuantity': 180, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.3, 'reviewCount': 201,
    },
    {
      'name': 'Dark Chocolate Bar',
      'description': '70% dark chocolate. Rich, smooth, and indulgent. Great for gifting.',
      'price': 350.0, 'originalPrice': 420.0,
      'imageUrl': 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&q=80',
      'category': 'snacks', 'stockQuantity': 70, 'unit': 'bar',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.7, 'reviewCount': 118,
    },
    {
      'name': 'Mixed Nuts (200g)',
      'description': 'Premium blend of cashews, almonds, peanuts, and walnuts.',
      'price': 420.0, 'originalPrice': 500.0,
      'imageUrl': 'https://images.unsplash.com/photo-1599599810694-b5b37304c041?w=400&q=80',
      'category': 'snacks', 'stockQuantity': 55, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 88,
    },

    // ── HOUSEHOLD ───────────────────────────────────────────
    {
      'name': 'Dish Soap (500ml)',
      'description': 'Powerful grease-cutting dish soap. Gentle on hands, tough on grease.',
      'price': 120.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1585664811087-47f65abbad64?w=400&q=80',
      'category': 'household', 'stockQuantity': 150, 'unit': 'bottle',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 143,
    },
    {
      'name': 'Laundry Detergent (2kg)',
      'description': 'Powerful washing powder for all fabric types. Fresh scent, effective stain removal.',
      'price': 480.0, 'originalPrice': 550.0,
      'imageUrl': 'https://images.unsplash.com/photo-1626806787461-102c1a82e967?w=400&q=80',
      'category': 'household', 'stockQuantity': 80, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 97,
    },
    {
      'name': 'Toilet Paper (12 rolls)',
      'description': 'Soft 3-ply toilet paper. Individually wrapped for hygiene.',
      'price': 380.0, 'originalPrice': 430.0,
      'imageUrl': 'https://images.unsplash.com/photo-1584545284372-f22510eb7c26?w=400&q=80',
      'category': 'household', 'stockQuantity': 120, 'unit': 'pack',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.6, 'reviewCount': 224,
    },

    // ── PERSONAL CARE ────────────────────────────────────────
    {
      'name': 'Shampoo (400ml)',
      'description': 'Moisturizing shampoo for all hair types. Leaves hair soft and shiny.',
      'price': 380.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?w=400&q=80',
      'category': 'personal', 'stockQuantity': 65, 'unit': 'bottle',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.3, 'reviewCount': 76,
    },
    {
      'name': 'Hand Sanitizer (500ml)',
      'description': '70% alcohol hand sanitizer with aloe vera. Kills 99.9% of germs.',
      'price': 250.0, 'originalPrice': 300.0,
      'imageUrl': 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=400&q=80',
      'category': 'personal', 'stockQuantity': 100, 'unit': 'bottle',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.5, 'reviewCount': 189,
    },

    // ── FROZEN ──────────────────────────────────────────────
    {
      'name': 'Frozen Pizza',
      'description': 'Margherita frozen pizza. Ready in 15 minutes. Crispy base with rich tomato sauce.',
      'price': 650.0, 'originalPrice': 750.0,
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
      'category': 'frozen', 'stockQuantity': 30, 'unit': 'piece',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.5, 'reviewCount': 83,
    },
    {
      'name': 'Ice Cream (1L)',
      'description': 'Creamy vanilla ice cream. Made with real dairy. Perfect for desserts.',
      'price': 550.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80',
      'category': 'frozen', 'stockQuantity': 45, 'unit': 'tub',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.7, 'reviewCount': 152,
    },

    // ── CONDIMENTS ──────────────────────────────────────────
    {
      'name': 'Tomato Ketchup (500g)',
      'description': 'Classic rich tomato ketchup. Perfect with fries, burgers, and snacks.',
      'price': 180.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1558818498-28c1e002b655?w=400&q=80',
      'category': 'condiments', 'stockQuantity': 120, 'unit': 'bottle',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.4, 'reviewCount': 167,
    },
    {
      'name': 'Olive Oil (500ml)',
      'description': 'Extra virgin cold-pressed olive oil. Rich flavour, ideal for cooking and dressings.',
      'price': 850.0, 'originalPrice': 980.0,
      'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80',
      'category': 'condiments', 'stockQuantity': 40, 'unit': 'bottle',
      'isAvailable': true, 'isFeatured': false, 'rating': 4.7, 'reviewCount': 94,
    },
    {
      'name': 'Honey (350g)',
      'description': 'Pure raw Kenyan honey from acacia blossoms. Unprocessed and full of antioxidants.',
      'price': 480.0, 'originalPrice': null,
      'imageUrl': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&q=80',
      'category': 'condiments', 'stockQuantity': 55, 'unit': 'jar',
      'isAvailable': true, 'isFeatured': true, 'rating': 4.9, 'reviewCount': 211,
    },
  ];
}
