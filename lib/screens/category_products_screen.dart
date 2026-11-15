import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../component/product_card.dart';
import '../models/grocery_catalog.dart';
import '../models/product.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.categoryName});

  final String categoryName;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String _selectedFilter = 'All';
  String _sortOption = 'Default';

  List<Product> _getFilteredProducts() {
    var list = GroceryCatalog.byCategory(widget.categoryName);

    if (_selectedFilter == 'Under \$5') {
      list = list.where((p) => p.priceValue < 5.0).toList();
    } else if (_selectedFilter == 'Under \$10') {
      list = list.where((p) => p.priceValue < 10.0).toList();
    } else if (_selectedFilter == 'Rating 4.8+') {
      list = list.where((p) => p.rating >= 4.8).toList();
    }

    if (_sortOption == 'Price: Low to High') {
      list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_sortOption == 'Price: High to Low') {
      list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    } else if (_sortOption == 'Top Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredProducts();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.dark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.dark),
            tooltip: 'Sort Products',
            onSelected: (val) => setState(() => _sortOption = val),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Default', child: Text('Default Order')),
              PopupMenuItem(
                value: 'Price: Low to High',
                child: Text('Price: Low to High'),
              ),
              PopupMenuItem(
                value: 'Price: High to Low',
                child: Text('Price: High to Low'),
              ),
              PopupMenuItem(value: 'Top Rated', child: Text('Top Rated')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Row
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip('All'),
                  _chip('Under \$5'),
                  _chip('Under \$10'),
                  _chip('Rating 4.8+'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Products Grid
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.muted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No products match the selected filters.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 170 / 235,
                          ),
                      itemCount: products.length,
                      itemBuilder: (_, index) =>
                          ProductCard(product: products[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = label);
        },
        selectedColor: AppColors.green.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: selected ? AppColors.green : AppColors.dark,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(color: selected ? AppColors.green : AppColors.border),
        backgroundColor: Colors.white,
      ),
    );
  }
}
