import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../utils/image_url.dart';

class CatalogImage extends StatelessWidget {
  const CatalogImage({required this.url, this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.network(
    optimizedImageUrl(url),
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Icon(Icons.headphones_rounded, size: 54, color: AppColors.orange),
    ),
  );
}

class ProductHoverCard extends StatefulWidget {
  const ProductHoverCard({
    required this.product,
    required this.catalog,
    required this.cart,
    required this.onOpen,
    super.key,
  });

  final Headphone product;
  final CatalogController catalog;
  final CartController cart;
  final ValueChanged<Headphone> onOpen;

  @override
  State<ProductHoverCard> createState() => _ProductHoverCardState();
}

class _ProductHoverCardState extends State<ProductHoverCard> {
  bool _hovered = false;
  int _colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? AppColors.orange : AppColors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.09),
                      blurRadius: 22,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: GestureDetector(
                          onTap: () => widget.onOpen(product),
                          child: CatalogImage(url: product.imageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _ProductBadge(product: product),
                    ),
                    Positioned(
                      right: 6,
                      top: 4,
                      child: ListenableBuilder(
                        listenable: widget.catalog,
                        builder: (context, _) => Row(
                          children: [
                            IconButton(
                              tooltip: 'Add to wishlist',
                              onPressed: () async =>
                                  widget.catalog.toggleFavorite(product),
                              icon: Icon(
                                widget.catalog.favoriteIds.contains(product.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    widget.catalog.favoriteIds.contains(
                                      product.id,
                                    )
                                    ? AppColors.orange
                                    : AppColors.text,
                                size: 19,
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  widget.catalog.comparedIds.contains(
                                    product.id,
                                  )
                                  ? 'Remove from compare'
                                  : 'Compare',
                              onPressed: () async {
                                final wasCompared = widget.catalog.comparedIds
                                    .contains(product.id);
                                final added = await widget.catalog
                                    .toggleCompare(product);
                                if (!context.mounted) return;
                                if (!wasCompared && !added) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Compare up to three headphones at a time.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                widget.catalog.comparedIds.contains(product.id)
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.gold, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating}  (${product.reviewCount})',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => widget.onOpen(product),
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        if (product.hasANC) const SpecBadge('ANC'),
                        if (product.isWireless)
                          SpecBadge('${product.batteryLifeHours}h battery')
                        else
                          SpecBadge(product.specValue('Impedance')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (var i = 0; i < product.colors.length; i++)
                          _ColorDot(
                            color: product.colors[i].color,
                            selected: i == _colorIndex,
                            onTap: () => setState(() => _colorIndex = i),
                          ),
                        const Spacer(),
                        Text(
                          product.colors[_colorIndex].name,
                          style: TextStyle(color: AppColors.muted, fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (product.originalPrice != null)
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () async {
                            await widget.cart.add(
                              product,
                              product.colors[_colorIndex],
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to bag'),
                              ),
                            );
                          },
                          tooltip: 'Add to bag',
                          icon: const Icon(Icons.add_shopping_cart, size: 19),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.product});
  final Headphone product;
  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    final text = discount != null
        ? 'SAVE $discount%'
        : product.isBestSeller
        ? 'BEST SELLER'
        : product.isNewArrival
        ? 'NEW'
        : null;
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: discount != null ? AppColors.orange : AppColors.elevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
      ),
    ),
  );
}

class SpecBadge extends StatelessWidget {
  const SpecBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(label, style: TextStyle(color: AppColors.muted, fontSize: 9)),
  );
}
