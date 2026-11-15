import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_homepage/main.dart';
import 'package:flutter_homepage/screens/cart_screen.dart';
import 'package:flutter_homepage/screens/account_screen.dart';
import 'package:flutter_homepage/screens/favourite_screen.dart';
import 'package:flutter_homepage/screens/explore_screen.dart';
import 'package:flutter_homepage/screens/login_screen.dart';
import 'package:flutter_homepage/screens/product_detail_screen.dart';
import 'package:flutter_homepage/models/grocery_catalog.dart';
import 'package:flutter_homepage/state/grocery_state.dart';
import 'package:flutter_homepage/features/home/storefront_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('App launches directly into the headphone storefront', (
    tester,
  ) async {
    await tester.pumpWidget(const GroceryApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(StorefrontPage), findsOneWidget);
    expect(find.text('NEW FLAGSHIP RELEASE'), findsOneWidget);
    expect(find.text('SonicFlow Apex\nANC Pro'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches through all 5 screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      GroceryScope(
        state: GroceryState.instance,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Sign in first
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'pass1234',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // 1. Explore tab
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(find.text('Find Products'), findsOneWidget);

    // 2. Cart tab
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('My Cart'), findsOneWidget);

    // 3. Favourite tab
    await tester.tap(find.text('Favourite'));
    await tester.pumpAndSettle();
    expect(find.byType(FavouriteScreen), findsOneWidget);
    expect(find.text('Favourites'), findsOneWidget);

    // 4. Account tab
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
  });

  testWidgets('Product detail screen opens and allows adding to basket', (
    tester,
  ) async {
    final sampleProduct = GroceryCatalog.allProducts.first;

    await tester.pumpWidget(
      GroceryScope(
        state: GroceryState.instance,
        child: MaterialApp(home: ProductDetailScreen(product: sampleProduct)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Organic Bananas'), findsOneWidget);
    expect(find.text('Product Detail'), findsOneWidget);
    expect(find.text('Add To Basket'), findsOneWidget);

    await tester.tap(find.text('Add To Basket'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
