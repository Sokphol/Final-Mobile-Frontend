import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';

class CompareModal extends StatelessWidget {
  const CompareModal({required this.catalog, required this.cart, super.key});

  final CatalogController catalog;
  final CartController cart;

  static Future<void> show(
    BuildContext context,
    CatalogController catalog,
    CartController cart,
  ) => showDialog<void>(
    context: context,
    builder: (context) => CompareModal(catalog: catalog, cart: cart),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.elevated,
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.border),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 760),
      child: ListenableBuilder(
        listenable: catalog,
        builder: (context, _) {
          final products = catalog.comparedProducts;
          return Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'LISTEN SIDE BY SIDE',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length}/3 selected',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (products.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Choose up to three headphones from the catalog to compare.',
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.sizeOf(
                            context,
                          ).width.clamp(320, 800),
                        ),
                        child: Column(
                          children: [
                            _ProductHeadings(
                              products: products,
                              catalog: catalog,
                            ),
                            const Divider(height: 24),
                            for (final row in _rows)
                              _CompareRow(
                                label: row.$1,
                                values: products
                                    .map((product) => row.$2(product))
                                    .toList(),
                              ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final product in products)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await cart.add(
                                            product,
                                            product.colors.first,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          size: 16,
                                        ),
                                        label: const Text('Add to bag'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );

  static final _rows = <(String, String Function(Headphone))>[
    ('Price', (p) => '\$${p.price.toStringAsFixed(0)}'),
    ('Category', (p) => p.category),
    ('Rating', (p) => '${p.rating} / 5'),
    ('ANC', (p) => p.hasANC ? 'Yes' : 'No'),
    ('Wireless', (p) => p.isWireless ? 'Yes' : 'No'),
    (
      'Battery life',
      (p) => p.batteryLifeHours == 0 ? 'Wired' : '${p.batteryLifeHours}h',
    ),
    ('Driver', (p) => p.specValue('Driver Type')),
    ('Frequency response', (p) => p.specValue('Frequency Response')),
    ('Impedance', (p) => p.specValue('Impedance')),
    ('Weight', (p) => p.specValue('Weight')),
  ];
}

class _ProductHeadings extends StatelessWidget {
  const _ProductHeadings({required this.products, required this.catalog});
  final List<Headphone> products;
  final CatalogController catalog;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox(width: 150),
      for (final product in products)
        Expanded(
          child: Column(
            children: [
              Text(
                product.brand.toUpperCase(),
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed: () async => catalog.toggleCompare(product),
                child: const Text('Remove', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
    ],
  );
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.values});
  final String label;
  final List<String> values;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ),
        for (final value in values)
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
      ],
    ),
  );
}
