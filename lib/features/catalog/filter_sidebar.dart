import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../state/catalog_controller.dart';

class FilterSidebar extends StatelessWidget {
  const FilterSidebar({required this.controller, super.key});

  final CatalogController controller;
  static const _categories = [
    'All',
    'Over-Ear',
    'True Wireless',
    'Studio Open-Back',
    'Gaming',
    'IEMs',
    'DAC/Amps',
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'FILTERS',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (controller.activeFilterCount > 0)
                Text(
                  '${controller.activeFilterCount} active',
                  style: TextStyle(color: AppColors.orange, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const _Label('CATEGORY'),
          const SizedBox(height: 10),
          for (final category in _categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => controller.setCategory(category),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: controller.category == category
                        ? AppColors.orange
                        : AppColors.muted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (controller.category == category)
                        const Icon(Icons.check, size: 15),
                    ],
                  ),
                ),
              ),
            ),
          const Divider(height: 24),
          const _Label('LISTENING FEATURES'),
          Material(
            color: AppColors.surface,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Active noise cancelling',
                style: TextStyle(fontSize: 12),
              ),
              value: controller.ancOnly,
              onChanged: controller.setAnc,
            ),
          ),
          Material(
            color: AppColors.surface,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Wireless Bluetooth',
                style: TextStyle(fontSize: 12),
              ),
              value: controller.wirelessOnly,
              onChanged: controller.setWireless,
            ),
          ),
          const Divider(height: 22),
          const _Label('PRICE RANGE'),
          const SizedBox(height: 6),
          Text(
            '\$${controller.priceRange.start.round()}  —  \$${controller.priceRange.end.round()}',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          RangeSlider(
            values: controller.priceRange,
            min: 100,
            max: 1000,
            divisions: 18,
            activeColor: AppColors.orange,
            onChanged: controller.setPriceRange,
          ),
          if (controller.activeFilterCount > 0) ...[
            const Divider(height: 22),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (controller.category != 'All')
                  _ActiveFilter(
                    controller.category,
                    () => controller.setCategory('All'),
                  ),
                if (controller.ancOnly)
                  _ActiveFilter('ANC', () => controller.setAnc(false)),
                if (controller.wirelessOnly)
                  _ActiveFilter(
                    'Wireless',
                    () => controller.setWireless(false),
                  ),
                if (controller.query.isNotEmpty)
                  _ActiveFilter('Search', () => controller.setQuery('')),
                if (controller.priceRange.start > 100 ||
                    controller.priceRange.end < 1000)
                  _ActiveFilter(
                    'Price',
                    () =>
                        controller.setPriceRange(const RangeValues(100, 1000)),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: controller.reset,
              icon: const Icon(Icons.restart_alt, size: 17),
              label: const Text('Reset all'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: TextStyle(
      color: AppColors.muted,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
  );
}

class _ActiveFilter extends StatelessWidget {
  const _ActiveFilter(this.label, this.onRemove);
  final String label;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => InputChip(
    label: Text(label),
    onDeleted: onRemove,
    visualDensity: VisualDensity.compact,
    deleteIconColor: AppColors.muted,
    side: BorderSide(color: AppColors.border),
  );
}
