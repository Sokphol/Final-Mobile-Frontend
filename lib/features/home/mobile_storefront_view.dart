import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../utils/image_url.dart';
import 'sound_finder_quiz.dart';
import '../product_detail/soundstage_tester.dart';

const mobileCategories = [
  'All',
  'Over-Ear',
  'ANC Wireless',
  'True Wireless',
  'Studio Open-Back',
  'Gaming',
  'IEMs',
  'DAC/Amps',
];

class MobileStorefrontHeader extends StatefulWidget {
  const MobileStorefrontHeader({
    required this.catalog,
    required this.cart,
    required this.onCart,
    required this.onSettings,
    super.key,
  });

  final CatalogController catalog;
  final CartController cart;
  final VoidCallback onCart;
  final VoidCallback onSettings;

  @override
  State<MobileStorefrontHeader> createState() => _MobileStorefrontHeaderState();
}

class _MobileStorefrontHeaderState extends State<MobileStorefrontHeader> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.catalog.query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.gold,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SONICFLOW',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'THE LISTENING ROOM',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 8,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Appearance settings',
              onPressed: widget.onSettings,
              icon: const Icon(Icons.tune_rounded, size: 21),
            ),
            IconButton(
              tooltip: 'Open your bag',
              onPressed: widget.onCart,
              icon: ListenableBuilder(
                listenable: widget.cart,
                builder: (context, _) => Badge(
                  label: Text('${widget.cart.itemCount}'),
                  isLabelVisible: widget.cart.itemCount > 0,
                  backgroundColor: AppColors.gold,
                  textColor: AppColors.background,
                  child: const Icon(Icons.shopping_bag_outlined, size: 22),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _search,
            onChanged: widget.catalog.setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search headphones, DACs, sound...',
              prefixIcon: const Icon(Icons.search_rounded, size: 19),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _search.clear();
                        widget.catalog.setQuery('');
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 34,
          child: ListenableBuilder(
            listenable: widget.catalog,
            builder: (context, _) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mobileCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = mobileCategories[index];
                final selected = widget.catalog.category == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => widget.catalog.setCategory(category),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.onAccent : AppColors.muted,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: selected ? AppColors.gold : AppColors.border,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

class MobileFeaturedCarousel extends StatefulWidget {
  const MobileFeaturedCarousel({
    required this.products,
    required this.cart,
    required this.onOpen,
    super.key,
  });

  final List<Headphone> products;
  final CartController cart;
  final ValueChanged<Headphone> onOpen;

  @override
  State<MobileFeaturedCarousel> createState() => _MobileFeaturedCarouselState();
}

class _MobileFeaturedCarouselState extends State<MobileFeaturedCarousel> {
  final _pageController = PageController(viewportFraction: 0.93);
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featured = widget.products
        .where((product) => product.isBestSeller || product.isNewArrival)
        .take(3)
        .toList();
    if (featured.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 296,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featured.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) => _FeaturedCard(
              product: featured[index],
              cart: widget.cart,
              onOpen: widget.onOpen,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < featured.length; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _page ? 18 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: index == _page ? AppColors.gold : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.product,
    required this.cart,
    required this.onOpen,
  });

  final Headphone product;
  final CartController cart;
  final ValueChanged<Headphone> onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF252832), Color(0xFF17191F), Color(0xFF111217)]
              : const [Color(0xFFFFFFFF), Color(0xFFF7F7F9), Color(0xFFF0F0F2)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            right: -25,
            child: Container(
              width: 216,
              height: 216,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    blurRadius: 52,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -17,
            top: 34,
            width: 215,
            height: 210,
            child: Image.network(
              optimizedImageUrl(product.imageUrl, maxWidth: 720),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const _ArtworkFallback(
                    icon: Icons.headphones_rounded,
                    size: 92,
                  ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? const [
                          Color(0xEE17191F),
                          Color(0xB817191F),
                          Color(0x0017191F),
                        ]
                      : const [
                          Color(0xF2FFFFFF),
                          Color(0xBFFFFFFF),
                          Color(0x00FFFFFF),
                        ],
                  stops: const [0, 0.48, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 17,
            right: 12,
            top: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    product.isNewArrival ? 'JUST ARRIVED' : 'LISTENER FAVORITE',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 8,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 175,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 162,
                  child: Text(
                    product.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 3),
                    Text(
                      '${product.rating}  ·  ${product.reviewCount} reviews',
                      style: TextStyle(fontSize: 9, color: AppColors.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 17,
            right: 16,
            bottom: 17,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => onOpen(product),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Explore'),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Add ${product.name} to bag',
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await cart.add(product, product.colors.first);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to your bag'),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onAccent,
                  ),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileProductGrid extends StatelessWidget {
  const MobileProductGrid({
    required this.products,
    required this.catalog,
    required this.cart,
    required this.onOpen,
    super.key,
  });

  final List<Headphone> products;
  final CatalogController catalog;
  final CartController cart;
  final ValueChanged<Headphone> onOpen;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 30,
              color: AppColors.gold,
            ),
            SizedBox(height: 12),
            Text('Nothing saved just yet'),
            SizedBox(height: 5),
            Text(
              'Tap the heart on any listening essential to keep it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 271,
          ),
          itemBuilder: (context, index) => MobileProductCard(
            product: products[index],
            catalog: catalog,
            cart: cart,
            onOpen: onOpen,
          ),
        );
      },
    );
  }
}

class MobileProductCard extends StatefulWidget {
  const MobileProductCard({
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
  State<MobileProductCard> createState() => _MobileProductCardState();
}

class _MobileProductCardState extends State<MobileProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => widget.onOpen(product),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(17),
                          ),
                          child: Image.network(
                            optimizedImageUrl(product.imageUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const _ArtworkFallback(
                                  icon: Icons.headphones_rounded,
                                  size: 47,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _ProductTag(product: product),
                    ),
                    Positioned(
                      right: 4,
                      top: 2,
                      child: ListenableBuilder(
                        listenable: widget.catalog,
                        builder: (context, _) {
                          final favorite = widget.catalog.favoriteIds.contains(
                            product.id,
                          );
                          return IconButton(
                            tooltip: favorite
                                ? 'Remove from saved'
                                : 'Save to wishlist',
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              await widget.catalog.toggleFavorite(product);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.background.withValues(
                                alpha: 0.76,
                              ),
                              foregroundColor: favorite
                                  ? AppColors.gold
                                  : AppColors.text,
                            ),
                            icon: Icon(
                              favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 17,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 7,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.gold,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${product.rating}  ·  ${product.batteryLifeHours > 0 ? '${product.batteryLifeHours}h battery' : product.specValue('Impedance')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 34,
                          child: IconButton(
                            tooltip: 'Add ${product.name} to bag',
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              await widget.cart.add(
                                product,
                                product.colors.first,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to bag'),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.onAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 19),
                          ),
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

class _ProductTag extends StatelessWidget {
  const _ProductTag({required this.product});

  final Headphone product;

  @override
  Widget build(BuildContext context) {
    final label = product.isNewArrival
        ? 'NEW'
        : product.isBestSeller
        ? 'POPULAR'
        : null;
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class MobileBottomNavigation extends StatelessWidget {
  const MobileBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.cartCount,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int cartCount;

  static const _destinations = [
    (Icons.explore_outlined, Icons.explore_rounded, 'Discover'),
    (Icons.graphic_eq_outlined, Icons.graphic_eq_rounded, 'Sound lab'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Saved'),
    (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Bag'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.88),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.fromLTRB(
          10,
          8,
          10,
          MediaQuery.paddingOf(context).bottom > 0 ? 2 : 8,
        ),
        child: Row(
          children: [
            for (var index = 0; index < _destinations.length; index++)
              Expanded(
                child: _NavigationDestination(
                  icon: _destinations[index].$1,
                  selectedIcon: _destinations[index].$2,
                  label: _destinations[index].$3,
                  selected: selectedIndex == index,
                  badgeCount: index == 3 ? cartCount : 0,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 29,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Badge(
                  label: Text('$badgeCount'),
                  isLabelVisible: badgeCount > 0,
                  backgroundColor: AppColors.gold,
                  textColor: AppColors.onAccent,
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 20,
                    color: selected ? AppColors.gold : AppColors.muted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                color: selected ? AppColors.orange : AppColors.muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        colors: [Color(0xFF36303A), Color(0xFF1B1D24), Color(0xFF111217)],
      ),
    ),
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.18),
              blurRadius: size * 0.48,
              spreadRadius: size * 0.06,
            ),
          ],
        ),
        child: Icon(icon, size: size, color: AppColors.gold),
      ),
    ),
  );
}

class MobileSectionHeading extends StatelessWidget {
  const MobileSectionHeading({
    required this.eyebrow,
    required this.title,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 8,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class MobilePerk extends StatelessWidget {
  const MobilePerk({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Icon(icon, size: 13, color: AppColors.gold),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.muted, fontSize: 8),
          ),
        ),
      ],
    ),
  );
}

class MobileStudioContent extends StatelessWidget {
  const MobileStudioContent({required this.cart, super.key});

  final CartController cart;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobileSectionHeading(
          eyebrow: 'Listen closer',
          title: 'The sound lab',
        ),
        const SizedBox(height: 7),
        Text(
          'Find the sound that feels like yours.',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            gradient: LinearGradient(
              colors: [Color(0xFF26242B), AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'YOUR PERSONAL SOUND CHECK',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 8,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SoundstageTester(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => SoundFinderQuiz.show(context, cart),
                  icon: const Icon(Icons.tune_rounded, size: 17),
                  label: const Text('Find your perfect headphones'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _StudioPerk(
          icon: Icons.spatial_audio_off_rounded,
          title: 'Feel the soundstage',
          detail: 'Explore how an open-back headphone changes your listening.',
        ),
        const SizedBox(height: 10),
        const _StudioPerk(
          icon: Icons.equalizer_rounded,
          title: 'Tune for your taste',
          detail: 'Compare warm, balanced, and detail-forward signatures.',
        ),
      ],
    ),
  );
}

class _StudioPerk extends StatelessWidget {
  const _StudioPerk({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MobileProfileContent extends StatelessWidget {
  const MobileProfileContent({
    required this.cart,
    required this.savedCount,
    required this.onOrders,
    required this.onAbout,
    required this.onContact,
    super.key,
  });

  final CartController cart;
  final int savedCount;
  final VoidCallback onOrders;
  final VoidCallback onAbout;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobileSectionHeading(
          eyebrow: 'Your account',
          title: 'Welcome, listener.',
        ),
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0x26D4AF37),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your listening profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your orders and saved gear, all in one place.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 9,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ProfileAction(
          icon: Icons.receipt_long_outlined,
          title: 'Order history',
          detail: 'Track your listening essentials',
          onTap: onOrders,
        ),
        const SizedBox(height: 9),
        _ProfileAction(
          icon: Icons.favorite_border_rounded,
          title: 'Saved collection',
          detail: '$savedCount favorite${savedCount == 1 ? '' : 's'}',
          onTap: () {},
        ),
        const SizedBox(height: 9),
        _ProfileAction(
          icon: Icons.local_shipping_outlined,
          title: 'Complimentary delivery',
          detail: 'Free shipping on orders over \$300',
          onTap: () {},
        ),
        const SizedBox(height: 9),
        _ProfileAction(
          icon: Icons.headphones_outlined,
          title: 'Listener care',
          detail: 'Support hotline and service hours',
          onTap: onContact,
        ),
        const SizedBox(height: 9),
        _ProfileAction(
          icon: Icons.graphic_eq_rounded,
          title: 'About SonicFlow',
          detail: 'Get to know our listening-first approach',
          onTap: onAbout,
        ),
        if (cart.itemCount > 0) ...[
          const SizedBox(height: 20),
          Text(
            '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} in your bag',
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ],
    ),
  );
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: TextStyle(color: AppColors.muted, fontSize: 8),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}
