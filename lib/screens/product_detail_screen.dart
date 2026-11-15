import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../models/product.dart';
import '../state/grocery_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isDetailExpanded = true;
  bool _isNutritionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = GroceryScope.of(context);
    final isFav = state.isFavorite(widget.product);
    final unitPrice = widget.product.priceValue;
    final totalPrice = (unitPrice * _quantity).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.dark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : AppColors.dark,
            ),
            onPressed: () => state.toggleFavorite(widget.product),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Product Image Canvas
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F3F2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Hero(
                        tag: 'product-${widget.product.productId}',
                        child: Image.asset(
                          widget.product.image,
                          fit: BoxFit.contain,
                          height: 200,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Favorite
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name.replaceAll('\n', ' '),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.detail,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quantity selector & Live price
                        Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Container(
                              width: 48,
                              height: 44,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              isAdd: true,
                              onTap: () => setState(() => _quantity++),
                            ),
                            const Spacer(),
                            Text(
                              '\$ $totalPrice',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 36, color: AppColors.border),

                        // Product Details Expandable
                        InkWell(
                          onTap: () => setState(
                            () => _isDetailExpanded = !_isDetailExpanded,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Product Detail',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              Icon(
                                _isDetailExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.dark,
                              ),
                            ],
                          ),
                        ),
                        if (_isDetailExpanded) ...[
                          const SizedBox(height: 10),
                          Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const Divider(height: 32, color: AppColors.border),

                        // Nutritions
                        InkWell(
                          onTap: () => setState(
                            () => _isNutritionExpanded = !_isNutritionExpanded,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nutritions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBEBEB),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      widget.product.nutritions,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _isNutritionExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.dark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_isNutritionExpanded) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Contains essential dietary vitamins, fiber, zero added sugars, and 100% natural organic harvest value.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const Divider(height: 32, color: AppColors.border),

                        // Review & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star,
                                    color: Color(0xFFF3603F),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${widget.product.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Add to Basket Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    state.addToCart(widget.product, _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Added $_quantity x ${widget.product.name.replaceAll('\n', ' ')} to Cart',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.green,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Add To Basket',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isAdd = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: isAdd ? AppColors.green : AppColors.border),
        color: isAdd
            ? AppColors.green.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isAdd ? AppColors.green : AppColors.muted,
        size: 22,
      ),
    ),
  );
}
