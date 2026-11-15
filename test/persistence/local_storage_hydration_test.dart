import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/models/mock_catalog.dart';
import 'package:flutter_homepage/state/cart_controller.dart';
import 'package:flutter_homepage/state/catalog_controller.dart';
import 'package:flutter_homepage/state/orders_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  test(
    'cart JSON restores product, variant, quantity, and promo after restart',
    () async {
      final product = mockCatalog.first;
      final writer = CartController();
      await writer.add(product, product.colors[1], quantity: 2);
      await writer.applyPromo('VIP20');

      final preferences = await SharedPreferences.getInstance();
      final stored =
          jsonDecode(preferences.getString(CartController.storageKey)!)
              as Map<String, dynamic>;
      expect(stored['items'].single['productId'], product.id);

      final restarted = CartController();
      await restarted.hydrate();
      expect(restarted.itemCount, 2);
      expect(restarted.items.single.variant.name, product.colors[1].name);
      expect(restarted.promoCode, 'VIP20');
      expect(restarted.total, closeTo(writer.total, 0.001));
      writer.dispose();
      restarted.dispose();
    },
  );

  test('wishlist IDs survive controller recreation', () async {
    final writer = CatalogController();
    await writer.toggleFavorite(mockCatalog[2]);
    final restarted = CatalogController();
    await restarted.hydrate();

    expect(restarted.favoriteIds, contains(mockCatalog[2].id));
    expect(restarted.favoriteIds, hasLength(1));
    writer.dispose();
    restarted.dispose();
  });

  test(
    'cart and favorites are isolated between guest and user scopes',
    () async {
      final product = mockCatalog.first;
      final guestCart = CartController();
      final guestCatalog = CatalogController();
      await guestCart.add(product, product.colors.first);
      await guestCatalog.toggleFavorite(product);

      await guestCart.switchUserScope('user-42');
      await guestCatalog.switchFavoriteUserScope('user-42');
      expect(guestCart.items, isEmpty);
      expect(guestCatalog.favoriteIds, isEmpty);

      await guestCart.add(product, product.colors.first, quantity: 2);
      await guestCatalog.toggleFavorite(mockCatalog[1]);

      await guestCart.switchUserScope('user-99');
      await guestCatalog.switchFavoriteUserScope('user-99');
      expect(guestCart.items, isEmpty);
      expect(guestCatalog.favoriteIds, isEmpty);

      await guestCart.switchUserScope('user-42');
      await guestCatalog.switchFavoriteUserScope('user-42');
      expect(guestCart.itemCount, 2);
      expect(guestCatalog.favoriteIds, {mockCatalog[1].id});

      await guestCart.switchUserScope(null);
      await guestCatalog.switchFavoriteUserScope(null);
      expect(guestCart.itemCount, 1);
      expect(guestCatalog.favoriteIds, {product.id});

      guestCart.dispose();
      guestCatalog.dispose();
    },
  );

  test('order history is isolated between guest and user scopes', () async {
    final guestCart = CartController();
    final guestOrders = OrdersController();
    final product = mockCatalog.first;
    await guestCart.add(product, product.colors.first);
    await guestOrders.record(guestCart, email: 'guest@example.com');

    await guestOrders.switchUserScope('user-42');
    expect(guestOrders.orders, isEmpty);
    await guestCart.add(product, product.colors.first);
    await guestOrders.record(guestCart, email: 'buyer@example.com');

    await guestOrders.switchUserScope('user-99');
    expect(guestOrders.orders, isEmpty);
    await guestOrders.switchUserScope('user-42');
    expect(guestOrders.orders, hasLength(1));
    expect(guestOrders.orders.single.email, 'buyer@example.com');
    expect(guestOrders.orders.single.deliveryStatus, 'Order confirmed');
    expect(
      guestOrders.orders.single.estimatedDelivery,
      guestOrders.orders.single.createdAt.add(const Duration(days: 5)),
    );

    await guestOrders.switchUserScope(null);
    expect(guestOrders.orders, hasLength(1));
    expect(guestOrders.orders.single.email, 'guest@example.com');
    guestCart.dispose();
    guestOrders.dispose();
  });

  test('demo delivery status advances through the tracking milestones', () {
    StoreOrder orderPlaced(Duration age) => StoreOrder(
      id: 'SF-2026-test',
      email: 'buyer@example.com',
      createdAt: DateTime.now().subtract(age),
      lines: const [],
      subtotal: 0,
      discount: 0,
      shipping: 0,
      tax: 0,
      total: 0,
    );

    expect(orderPlaced(Duration.zero).deliveryStatus, 'Order confirmed');
    expect(
      orderPlaced(const Duration(days: 1)).deliveryStatus,
      'Preparing your order',
    );
    expect(orderPlaced(const Duration(days: 2)).deliveryStatus, 'On the way');
    expect(orderPlaced(const Duration(days: 5)).deliveryStatus, 'Delivered');
  });

  test(
    'order JSON round-trips and hydrates as an immutable order snapshot',
    () async {
      final cart = CartController();
      final product = mockCatalog.first;
      await cart.add(product, product.colors.first, quantity: 2);
      await cart.applyPromo('AUDIO10');
      final orders = OrdersController();
      final order = await orders.record(cart, email: 'buyer@example.com');

      final serialized = jsonEncode(order.toJson());
      final restored = StoreOrder.fromJson(
        jsonDecode(serialized) as Map<String, dynamic>,
      );
      expect(restored.id, order.id);
      expect(restored.email, 'buyer@example.com');
      expect(restored.lines.single.quantity, 2);
      expect(restored.total, closeTo(order.total, 0.001));

      final restarted = OrdersController();
      await restarted.hydrate();
      expect(restarted.orders, hasLength(1));
      expect(restarted.orders.single.id, order.id);
      expect(restarted.orders.single.lines.single.productId, product.id);
      cart.dispose();
      orders.dispose();
      restarted.dispose();
    },
  );
}
