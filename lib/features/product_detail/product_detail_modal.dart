import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../catalog/product_hover_card.dart';
import 'headphone_360_viewer.dart';

class ProductDetailModal extends StatefulWidget {
  const ProductDetailModal({
    required this.product,
    required this.cart,
    this.catalog,
    super.key,
  });

  final Headphone product;
  final CartController cart;
  final CatalogController? catalog;

  static Future<void> show(
    BuildContext context,
    Headphone product,
    CartController cart, {
    CatalogController? catalog,
  }) => showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    builder: (context) =>
        ProductDetailModal(product: product, cart: cart, catalog: catalog),
  );

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  int _selectedColor = 0;
  int _selectedGallery = 0;
  int _quantity = 1;
  int _eqPreset = 0;
  final _reviewName = TextEditingController();
  final _reviewTitle = TextEditingController();
  final _reviewBody = TextEditingController();
  int _reviewRating = 5;

  static const _eqPresets = <(String, List<double>)>[
    ('Flat Reference', [0.5, 0.5, 0.5, 0.5, 0.5]),
    ('Bass Boost', [0.95, 0.84, 0.56, 0.47, 0.45]),
    ('Vocal Presence', [0.44, 0.52, 0.91, 0.68, 0.61]),
    ('Spatial Cinema', [0.72, 0.58, 0.65, 0.88, 0.96]),
  ];

  @override
  void dispose() {
    _reviewName.dispose();
    _reviewTitle.dispose();
    _reviewBody.dispose();
    super.dispose();
  }

  List<double> get _frequencyProfile => _eqPreset == 0
      ? widget.product.frequencyProfile
      : _eqPresets[_eqPreset].$2;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.galleryUrls.isEmpty
        ? [product.imageUrl]
        : product.galleryUrls;
    return Dialog(
      backgroundColor: AppColors.elevated,
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 820),
        child: DefaultTabController(
          length: 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;
              final left = _gallery(context, images);
              final right = _details(context);
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close details',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: stacked
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                left,
                                const SizedBox(height: 22),
                                right,
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: left),
                                const SizedBox(width: 30),
                                Expanded(child: right),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _gallery(BuildContext context, List<String> images) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 310,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CatalogImage(url: images[_selectedGallery % images.length]),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => setState(() => _selectedGallery = index),
            child: Container(
              width: 76,
              decoration: BoxDecoration(
                border: Border.all(
                  color: index == _selectedGallery
                      ? AppColors.orange
                      : AppColors.border,
                  width: index == _selectedGallery ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CatalogImage(url: images[index]),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Headphone360Viewer(product: widget.product),
      const SizedBox(height: 14),
      const Text('EQ PRESETS', style: TextStyle(fontWeight: FontWeight.w700)),
      Wrap(
        spacing: 4,
        children: [
          for (var index = 0; index < _eqPresets.length; index++)
            ChoiceChip(
              label: Text(_eqPresets[index].$1),
              selected: _eqPreset == index,
              onSelected: (_) => setState(() => _eqPreset = index),
            ),
        ],
      ),
      _SoundSignatureBars(profile: _frequencyProfile),
    ],
  );

  Widget _details(BuildContext context) {
    final product = widget.product;
    final variant = product.colors[_selectedColor];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.brand.toUpperCase()}  /  ${product.category.toUpperCase()}',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 10,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: AppColors.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              '${widget.catalog?.ratingFor(product) ?? product.rating}  ·  ${(widget.catalog?.reviewsFor(product).length ?? product.reviewCount)} reviews',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.description,
          style: TextStyle(color: AppColors.muted, height: 1.6, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            if (product.originalPrice != null) ...[
              const SizedBox(width: 9),
              Text(
                '\$${product.originalPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.muted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              _Pill('SAVE ${product.discountPercent}%'),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'COLOR FINISH: ${variant.name.toUpperCase()}',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < product.colors.length; i++)
              GestureDetector(
                onTap: () => setState(() => _selectedColor = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 9),
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: product.colors[i].color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i == _selectedColor
                          ? AppColors.orange
                          : AppColors.border,
                      width: i == _selectedColor ? 4 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          variant.name,
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: Row(
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_quantity',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await widget.cart.add(
                      product,
                      variant,
                      quantity: _quantity,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 17),
                  label: Text(
                    'Add to Cart • \$${(product.price * _quantity).toStringAsFixed(2)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Technical specs'),
            Tab(text: '360° & Acoustic Lab'),
            Tab(text: 'Verified Reviews'),
            Tab(text: 'In The Box'),
          ],
        ),
        SizedBox(
          height: 265,
          child: TabBarView(
            children: [
              _specs(),
              Headphone360Viewer(product: widget.product),
              _reviews(),
              _inTheBox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specs() => ListView(
    shrinkWrap: true,
    children: widget.product.specs
        .map(
          (spec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    spec.label,
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec.value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );

  Widget _inTheBox() => ListView(
    children: const [
      _IncludedItem('Hard-shell travel case'),
      _IncludedItem('USB-C DAC cable'),
      _IncludedItem('6.35mm studio adapter'),
      _IncludedItem('Airplane adapter'),
    ],
  );

  Widget _reviews() => ListView(
    children: [
      if (widget.catalog != null) _reviewForm(),
      ...(widget.catalog?.reviewsFor(widget.product) ?? widget.product.reviews)
          .map(
            (review) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _Pill('VERIFIED BUYER'),
                      const Spacer(),
                      Text(
                        review.date,
                        style: TextStyle(color: AppColors.muted, fontSize: 9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${'★' * review.rating}  ${review.title}',
                    style: TextStyle(color: AppColors.gold, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.body,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
    ],
  );

  Widget _reviewForm() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a review',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        TextField(
          controller: _reviewName,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _reviewTitle,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: _reviewBody,
          decoration: const InputDecoration(labelText: 'Review'),
          maxLines: 2,
        ),
        Row(
          children: [
            const Text('Rating'),
            DropdownButton<int>(
              value: _reviewRating,
              items: [
                for (var rating = 1; rating <= 5; rating++)
                  DropdownMenuItem(value: rating, child: Text('$rating stars')),
              ],
              onChanged: (value) => setState(() => _reviewRating = value ?? 5),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                await widget.catalog!.addReview(
                  widget.product,
                  name: _reviewName.text,
                  title: _reviewTitle.text,
                  body: _reviewBody.text,
                  rating: _reviewRating,
                );
                if (mounted) setState(() {});
                _reviewTitle.clear();
                _reviewBody.clear();
              },
              child: Text('Submit review'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SoundSignatureBars extends StatelessWidget {
  const _SoundSignatureBars({required this.profile});
  final List<double> profile;
  static const labels = ['SUB', 'BASS', 'MIDS', 'TREBLE', 'AIR'];
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SOUND SIGNATURE',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < profile.length && i < labels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 43,
                  child: Text(
                    labels[i],
                    style: TextStyle(color: AppColors.muted, fontSize: 8),
                  ),
                ),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: profile[i]),
                    duration: Duration(milliseconds: 450 + i * 70),
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppColors.elevated,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.orange.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: AppColors.orange,
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _IncludedItem extends StatelessWidget {
  const _IncludedItem(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      Icons.check_circle_outline,
      color: AppColors.orange,
      size: 17,
    ),
    title: Text(title, style: const TextStyle(fontSize: 11)),
  );
}
