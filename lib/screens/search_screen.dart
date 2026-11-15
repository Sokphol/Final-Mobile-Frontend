import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../component/product_card.dart';
import '../models/grocery_catalog.dart';
import '../models/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  String _currentQuery = '';
  String _selectedCategory = 'All';

  static const _quickKeywords = [
    'Banana',
    'Apple',
    'Tomato',
    'Pepper',
    'Chicken',
    'Beef',
    'Rice',
  ];

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> _getResults() {
    var results = GroceryCatalog.search(_currentQuery);
    if (_selectedCategory != 'All') {
      results = results
          .where(
            (p) => p.category.toLowerCase().contains(
              _selectedCategory.toLowerCase(),
            ),
          )
          .toList();
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _getResults();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (val) => setState(() => _currentQuery = val),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.dark,
                  size: 22,
                ),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _currentQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.searchBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Quick suggestion keywords
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickKeywords.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final word = _quickKeywords[i];
                  return ActionChip(
                    label: Text(word, style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFFF6F6F6),
                    onPressed: () {
                      _controller.text = word;
                      setState(() => _currentQuery = word);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryChip('All'),
                  _categoryChip('Produce', filterTag: 'Fresh Produce'),
                  _categoryChip('Meat & Seafood', filterTag: 'Meat'),
                  _categoryChip('Cooking Essentials', filterTag: 'Cooking'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Showing ${results.length} results',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Grid results
            Expanded(
              child: results.isEmpty
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
                          Text(
                            'No products found for "$_currentQuery"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try checking spelling or try other keywords.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
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
                      itemCount: results.length,
                      itemBuilder: (_, index) =>
                          ProductCard(product: results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, {String? filterTag}) {
    final tag = filterTag ?? label;
    final isSelected = _selectedCategory == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _selectedCategory = tag);
        },
        selectedColor: AppColors.green.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.green : AppColors.dark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.green : AppColors.border,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
