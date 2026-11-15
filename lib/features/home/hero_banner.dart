import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/mock_catalog.dart';
import '../../state/cart_controller.dart';
import '../../features/catalog/product_hover_card.dart';
import 'sound_finder_quiz.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({required this.cart, required this.onInspect, super.key});

  final CartController cart;
  final VoidCallback onInspect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 760;
      final text = _copy(context);
      final image = ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CatalogImage(url: flagshipHeadphone.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xB8000000), Colors.transparent],
                ),
              ),
            ),
            const Positioned(
              left: 18,
              bottom: 18,
              child: Text(
                'APEX ANC PRO  /  01',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(22),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text,
                  const SizedBox(height: 22),
                  SizedBox(height: 260, width: double.infinity, child: image),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 6, child: text),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: SizedBox(height: 380, child: image)),
                ],
              ),
      );
    },
  );

  Widget _copy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
        ),
        child: Text(
          'NEW FLAGSHIP RELEASE',
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'SonicFlow Apex\nANC Pro',
        style: TextStyle(
          fontSize: 38,
          height: 1.05,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Quiet the outside. Keep every detail.',
        style: TextStyle(color: AppColors.muted, fontSize: 15),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _AcousticPill('60h Battery'),
          _AcousticPill('50mm Planar Drivers'),
          _AcousticPill('Lossless LDAC'),
          _AcousticPill('-48dB Hybrid ANC'),
        ],
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await cart.add(flagshipHeadphone, flagshipHeadphone.colors.first);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Apex ANC Pro added to your bag.'),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Buy Now • \$449'),
          ),
          OutlinedButton.icon(
            onPressed: onInspect,
            icon: const Icon(Icons.graphic_eq, size: 18),
            label: const Text('Inspect full specs'),
          ),
          OutlinedButton.icon(
            onPressed: () => SoundFinderQuiz.show(context, cart),
            icon: const Icon(Icons.tune),
            label: const Text('Find your sound'),
          ),
        ],
      ),
    ],
  );
}

class _AcousticPill extends StatelessWidget {
  const _AcousticPill(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: AppColors.text)),
  );
}
