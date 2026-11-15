import 'product.dart';

class GroceryCatalog {
  static const List<Product> allProducts = [
    Product(
      id: 'organic-bananas',
      image: 'assets/products/banana.png',
      name: 'Organic Bananas',
      detail: '7pcs, Price',
      price: '\$ 4.99',
      category: 'Fresh Produce & Vegetables',
      description:
          'Bananas are rich in potassium and provide a quick energy boost. These organic bananas are freshly harvested and naturally ripened.',
      nutritions: '100gr (~89 kcal)',
      rating: 4.9,
      reviewCount: 142,
    ),
    Product(
      id: 'red-apple',
      image: 'assets/products/apple.png',
      name: 'Red Apple',
      detail: '1Kg, Price',
      price: '\$ 8.99',
      category: 'Fresh Produce & Vegetables',
      description:
          'Crisp, sweet, and juicy red apples sourced directly from organic orchards. High in dietary fiber and vitamin C.',
      nutritions: '100gr (~52 kcal)',
      rating: 4.8,
      reviewCount: 98,
    ),
    Product(
      id: 'green-apple',
      image: 'assets/products/green-apple.png',
      name: 'Green Apple',
      detail: '1Kg, Price',
      price: '\$ 12.99',
      category: 'Fresh Produce & Vegetables',
      description:
          'Tart and refreshing green apples. Perfect for healthy salads, fresh juicing, or an invigorating daily snack.',
      nutritions: '100gr (~50 kcal)',
      rating: 4.7,
      reviewCount: 65,
    ),
    Product(
      id: 'bell-pepper',
      image: 'assets/products/pepper.png',
      name: 'Red Pepper',
      detail: '100g, Price',
      price: '\$ 2.79',
      category: 'Fresh Produce & Vegetables',
      description:
          'Vibrant red bell pepper bursting with antioxidants and rich flavor. Ideal for stir-fries, roasting, and crisp salads.',
      nutritions: '100gr (~31 kcal)',
      rating: 4.6,
      reviewCount: 52,
    ),
    Product(
      id: 'fresh-tomato',
      image: 'assets/products/tomato.png',
      name: 'Tomato',
      detail: '1Kg, Price',
      price: '\$ 7.99',
      category: 'Fresh Produce & Vegetables',
      description:
          'Vine-ripened, farm-fresh red tomatoes. Plump, juicy, and perfect for sauces, sandwiches, and culinary dressings.',
      nutritions: '100gr (~18 kcal)',
      rating: 4.8,
      reviewCount: 88,
    ),
    Product(
      id: 'organic-carrot',
      image: 'assets/products/carrot.png',
      name: 'Fresh Carrot',
      detail: '1Kg, Price',
      price: '\$ 3.49',
      category: 'Fresh Produce & Vegetables',
      description:
          'Crunchy, sweet, premium grade carrots packed with beta-carotene, fiber, and essential minerals.',
      nutritions: '100gr (~41 kcal)',
      rating: 4.9,
      reviewCount: 110,
    ),
    Product(
      id: 'fresh-beef',
      image: 'assets/products/Beef.png',
      name: 'Beef Bone-In',
      detail: '100g, Price',
      price: '\$ 20.88',
      category: 'Fresh Meat, Seafood & Poultry',
      description:
          'Premium grain-fed beef cut. Tender, succulent, and rich in natural proteins and essential iron.',
      nutritions: '100gr (~250 kcal)',
      rating: 4.9,
      reviewCount: 175,
    ),
    Product(
      id: 'tender-chicken',
      image: 'assets/products/Chicken.png',
      name: 'Chicken Breast',
      detail: '1pcs, Price',
      price: '\$ 22.75',
      category: 'Fresh Meat, Seafood & Poultry',
      description:
          'Fresh organic farm chicken breast. Lean protein source with no hormones or antibiotics.',
      nutritions: '100gr (~165 kcal)',
      rating: 4.8,
      reviewCount: 130,
    ),
    Product(
      id: 'natural-pulses',
      image: 'assets/categories/pulse.png',
      name: 'Pulses & Lentils',
      detail: '500g, Price',
      price: '\$ 5.99',
      category: 'Oils, Condiments & Cooking Essentials',
      description:
          'Finest quality natural pulses and dried lentils. A rich source of plant protein and wholesome fiber for soups and curries.',
      nutritions: '100gr (~116 kcal)',
      rating: 4.7,
      reviewCount: 44,
    ),
    Product(
      id: 'jasmine-rice',
      image: 'assets/categories/rices.png',
      name: 'Jasmine Rice',
      detail: '5Kg, Price',
      price: '\$ 15.50',
      category: 'Oils, Condiments & Cooking Essentials',
      description:
          'Fragrant, authentic Cambodian jasmine rice. Fluffy texture, subtle floral aroma, and delicious taste.',
      nutritions: '100gr (~130 kcal)',
      rating: 5.0,
      reviewCount: 215,
    ),
  ];

  static List<Product> byCategory(String categoryName) {
    if (categoryName.toLowerCase().contains('all')) {
      return allProducts;
    }
    final filtered = allProducts
        .where(
          (p) =>
              p.category.toLowerCase().contains(categoryName.toLowerCase()) ||
              categoryName.toLowerCase().contains(p.category.toLowerCase()),
        )
        .toList();
    return filtered.isNotEmpty ? filtered : allProducts;
  }

  static List<Product> search(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return allProducts;
    return allProducts
        .where(
          (p) =>
              p.name.toLowerCase().contains(clean) ||
              p.category.toLowerCase().contains(clean) ||
              p.detail.toLowerCase().contains(clean),
        )
        .toList();
  }
}
