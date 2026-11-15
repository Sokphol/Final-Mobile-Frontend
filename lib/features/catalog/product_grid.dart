import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import 'product_hover_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.catalog,
    required this.cart,
    required this.onOpen,
    required this.onOpenFilters,
    this.showFilterButton = true,
    super.key,
  });

  final CatalogController catalog;
  final CartController cart;
  final ValueChanged<Headphone> onOpen;
  final VoidCallback onOpenFilters;
  final bool showFilterButton;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: catalog,
    builder: (context, _) {
      final products = catalog.products;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compactHeader = constraints.maxWidth < 700;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find your frequency',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${products.length} considered listening options',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!compactHeader) _sorting(context),
                      if (showFilterButton) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Open filters',
                          onPressed: onOpenFilters,
                          icon: const Icon(Icons.tune),
                        ),
                      ],
                    ],
                  ),
                  if (compactHeader)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _sorting(context),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          if (products.isEmpty)
            _EmptyState(onReset: catalog.reset)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final count = width > 980
                    ? 3
                    : width > 620
                    ? 2
                    : 1;
                final cardWidth = (width - (count - 1) * 14) / count;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: (cardWidth / 1.6 + 245)
                        .clamp(450, 620)
                        .toDouble(),
                  ),
                  itemBuilder: (context, index) => ProductHoverCard(
                    product: products[index],
                    catalog: catalog,
                    cart: cart,
                    onOpen: onOpen,
                  ),
                );
              },
            ),
        ],
      );
    },
  );

  Widget _sorting(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'SORT',
        style: TextStyle(color: AppColors.muted, fontSize: 9, letterSpacing: 1),
      ),
      const SizedBox(width: 8),
      DropdownButton<String>(
        value: catalog.sorting,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.elevated,
        items: const [
          DropdownMenuItem(value: 'Featured', child: Text('Featured')),
          DropdownMenuItem(
            value: 'Price: Low to High',
            child: Text('Price: low to high'),
          ),
          DropdownMenuItem(
            value: 'Price: High to Low',
            child: Text('Price: high to low'),
          ),
          DropdownMenuItem(value: 'Top Rated', child: Text('Top rated')),
        ],
        onChanged: (value) {
          if (value != null) catalog.setSorting(value);
        },
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Icon(Icons.graphic_eq, size: 42, color: AppColors.orange),
        const SizedBox(height: 14),
        const Text(
          'No signal found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Adjust your filters to hear what is out there.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset All Filters'),
        ),
      ],
    ),
  );
}
