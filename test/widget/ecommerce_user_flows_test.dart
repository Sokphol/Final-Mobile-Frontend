import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/state/auth_controller.dart';
import 'package:flutter_homepage/features/home/mobile_storefront_view.dart';
import 'package:flutter_homepage/features/home/storefront_page.dart';
import 'package:flutter_homepage/models/mock_catalog.dart';
import 'package:flutter_homepage/features/product_detail/soundstage_tester.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('mobile storefront supports browsing and thumb navigation', (
    tester,
  ) async {
    tester.setViewport(const Size(390, 844));
    addTearDown(tester.resetViewport);
    await tester.pumpWidget(const MaterialApp(home: StorefrontPage()));
    await tester.pumpAndSettle();

    expect(mockCatalog.length, greaterThanOrEqualTo(8));
    expect(find.text('Hear more.\nCarry less.'), findsOneWidget);
    expect(find.byType(MobileFeaturedCarousel), findsOneWidget);
    expect(find.text('The collection'), findsOneWidget);
    expect(find.text('ANC Wireless'), findsOneWidget);

    await tester.tap(find.text('Sound lab'));
    await tester.pumpAndSettle();
    expect(find.byType(SoundstageTester), findsOneWidget);
    expect(find.text('Find your perfect headphones'), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Your saved sound'), findsOneWidget);
    expect(find.text('Nothing saved just yet'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    final saveButton = find.byTooltip('Save to wishlist').first;
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('SonicFlow Apex ANC Pro'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    final addButton = find.byTooltip('Add SonicFlow Apex ANC Pro to bag');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bag'));
    await tester.pumpAndSettle();
    expect(find.textContaining('YOUR BAG'), findsOneWidget);
    expect(find.text('SonicFlow Apex ANC Pro'), findsOneWidget);
  });

  testWidgets('mobile profile opens About and Contact pages', (tester) async {
    tester.setViewport(const Size(390, 844));
    addTearDown(tester.resetViewport);
    await tester.pumpWidget(const MaterialApp(home: StorefrontPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listener care'));
    await tester.pumpAndSettle();
    expect(find.text('We’re here to help.'), findsOneWidget);
    expect(find.text('+855 12 345 678'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('About SonicFlow'));
    await tester.pumpAndSettle();
    expect(find.text('A better kind of listening.'), findsOneWidget);
  });

  testWidgets('browse, inspect a product, add to cart, and complete checkout', (
    tester,
  ) async {
    tester.setViewport(const Size(1280, 900));
    addTearDown(tester.resetViewport);
    final auth = AuthController(
      client: MockClient(
        (_) async => http.Response(
          '{"success":true,"data":{"access_token":"demo-token","refresh_token":"demo-refresh","user":{"id":1,"name":"Test Buyer","email":"buyer@example.com","role":"customer"}}}',
          200,
        ),
      ),
    );
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StorefrontPage(authController: auth)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Find your frequency'), findsOneWidget);
    await tester.tap(find.text('Inspect full specs'));
    await tester.pumpAndSettle();
    expect(find.text('SonicFlow Apex ANC Pro'), findsNWidgets(2));

    await tester.tap(find.textContaining('Add to Cart'));
    await tester.pumpAndSettle();
    expect(find.text('SonicFlow Apex ANC Pro'), findsOneWidget);

    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    expect(find.textContaining('YOUR BAG'), findsOneWidget);
    expect(find.text('SonicFlow Apex ANC Pro'), findsNWidgets(2));

    await tester.tap(find.text('Proceed to checkout'));
    await tester.pumpAndSettle();
    expect(find.text('SECURE CHECKOUT'), findsOneWidget);
    expect(auth.isAuthenticated, isFalse);

    final shippingFields = find.byType(TextFormField);
    await tester.enterText(shippingFields.at(0), 'Test Buyer');
    await tester.enterText(shippingFields.at(1), 'buyer@example.com');
    await tester.enterText(shippingFields.at(2), '10 Audio Lane');
    await tester.enterText(shippingFields.at(3), 'Phnom Penh');
    await tester.enterText(shippingFields.at(4), '12000');
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();

    expect(find.text('KHQR payment'), findsOneWidget);
    await tester.tap(find.text('Pay with KHQR'));
    await tester.pump();
    expect(find.text('Scan KHQR'), findsOneWidget);
    expect(find.textContaining('Demo amount:'), findsOneWidget);
    expect(find.textContaining('No real payment'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/KHQR.jpg',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(find.text('Demo payment successful!'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Your bag is waiting for a soundtrack.'), findsOneWidget);
  });
}
