import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../screens/category_products_screen.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
      ),
      InkWell(
        onTap:
            onSeeAll ??
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CategoryProductsScreen(categoryName: title),
              ),
            ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
        ),
      ),
    ],
  );
}
