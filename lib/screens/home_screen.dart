import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../component/category_card.dart';
import '../component/hero_carousel.dart';
import '../component/product_card.dart';
import '../component/section_header.dart';
import '../models/product.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const exclusive = [
    Product(
      id: 'organic-bananas',
      image: 'assets/products/banana.png',
      name: 'Organic\nBananas',
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
      id: 'fresh-carrot',
      image: 'assets/products/carrot.png',
      name: 'Fresh Carrot',
      detail: '1Kg, Price',
      price: '\$ 9.99',
      category: 'Fresh Produce & Vegetables',
      description:
          'Crunchy, sweet, premium grade carrots packed with beta-carotene, fiber, and essential minerals.',
      nutritions: '100gr (~41 kcal)',
      rating: 4.9,
      reviewCount: 110,
    ),
  ];

  static const bestSelling = [
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
  ];

  static const groceries = [
    Product(
      id: 'fresh-beef',
      image: 'assets/products/Beef.png',
      name: 'Beef',
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
      name: 'Chicken',
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
      id: 'green-apple-groceries',
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
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        children: [
          Center(
            child: Image.asset('assets/logo/carrot.png', width: 26, height: 28),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.muted),
              SizedBox(width: 7),
              Text(
                'Phnom Penh, Cambodia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: TextField(
              readOnly: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
              decoration: InputDecoration(
                hintText: 'Search your product',
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(Icons.search, size: 28),
                filled: true,
                fillColor: AppColors.searchBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const HeroCarousel(),
          _section('Exclusive Offer', exclusive),
          _section('Best Selling', bestSelling),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Groceries'),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryCard(
                  image: 'assets/categories/pulse.png',
                  title: 'Pulses',
                  color: Color(0x26F8A44C),
                ),
                CategoryCard(
                  image: 'assets/categories/rices.png',
                  title: 'Rices',
                  color: Color(0x2653B175),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _productRow(groceries),
        ],
      ),
    ),
  );

  Widget _section(String title, List<Product> products) => Column(
    children: [
      const SizedBox(height: 22),
      SectionHeader(title: title),
      const SizedBox(height: 16),
      _productRow(products),
    ],
  );

  Widget _productRow(List<Product> products) => SizedBox(
    height: 248,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    ),
  );
}
