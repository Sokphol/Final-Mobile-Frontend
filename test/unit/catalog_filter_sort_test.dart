import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/features/catalog/filter_sidebar.dart';
import 'package:flutter_homepage/models/mock_catalog.dart';
import 'package:flutter_homepage/state/catalog_controller.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  late CatalogController catalog;

  setUp(() => catalog = CatalogController());
  tearDown(() => catalog.dispose());

  test('search trims and matches names, brands, and specification text', () {
    catalog.setQuery('  apex  ');
    expect(catalog.products.map((product) => product.id), ['apex-anc-pro']);

    catalog.setQuery('LDAC');
    expect(
      catalog.products.map((product) => product.id),
      containsAll(['apex-anc-pro', 'pulse-buds']),
    );
  });

  test('category, ANC, wireless, and price range combine as filters', () {
    catalog.setCategory('Over-Ear');
    catalog.setAnc(true);
    catalog.setWireless(true);
    catalog.setPriceRange(const RangeValues(200, 300));

    expect(catalog.products.map((product) => product.id), ['roam-anc']);
    expect(catalog.activeFilterCount, 4);

    catalog.setCategory('All');
    expect(catalog.products.map((product) => product.id), ['roam-anc']);
  });

  test('sorts by price in both directions and by rating', () {
    catalog.setSorting('Price: Low to High');
    expect(
      catalog.products.map((product) => product.price).toList(),
      [...catalog.products.map((product) => product.price)]..sort(),
    );

    catalog.setSorting('Price: High to Low');
    final descending = catalog.products
        .map((product) => product.price)
        .toList();
    expect(descending, [...descending]..sort((a, b) => b.compareTo(a)));

    catalog.setSorting('Top Rated');
    final ratings = catalog.products.map((product) => product.rating).toList();
    expect(ratings, [...ratings]..sort((a, b) => b.compareTo(a)));
  });

  test(
    'featured sorting puts best sellers first and compare is capped at three',
    () async {
      catalog.setSorting('Featured');
      expect(
        catalog.products.take(3).every((product) => product.isBestSeller),
        isTrue,
      );

      for (final product in mockCatalog.take(4)) {
        final added = await catalog.toggleCompare(product);
        expect(added, product != mockCatalog[3]);
      }
      expect(catalog.comparedProducts, hasLength(3));
      expect(await catalog.toggleCompare(mockCatalog[4]), isFalse);
      expect(catalog.comparedProducts, hasLength(3));
    },
  );

  test('guest favorites persist locally without an account', () async {
    final product = mockCatalog.first;
    await catalog.toggleFavorite(product);
    expect(catalog.favoriteIds, contains(product.id));

    final restored = CatalogController();
    addTearDown(restored.dispose);
    await restored.hydrate();
    expect(restored.favoriteIds, contains(product.id));
  });

  testWidgets('price range slider applies the selected minimum', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: FilterSidebar(controller: catalog),
              ),
            ),
          ),
        ),
      ),
    );

    final slider = find.byType(RangeSlider);
    final sliderRect = tester.getRect(slider);
    await tester.dragFrom(
      Offset(sliderRect.left + 16, sliderRect.center.dy),
      const Offset(50, 0),
    );
    await tester.pumpAndSettle();

    expect(catalog.priceRange.start, greaterThan(100));
    expect(
      catalog.products.every(
        (product) => product.price >= catalog.priceRange.start,
      ),
      isTrue,
    );
  });
}
