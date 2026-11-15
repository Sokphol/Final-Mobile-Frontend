import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/models/mock_catalog.dart';
import 'package:flutter_homepage/state/cart_controller.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  late CartController cart;

  setUp(() => cart = CartController());
  tearDown(() => cart.dispose());

  test(
    'adding increments matching variants and quantity one removes item',
    () async {
      final product = mockCatalog.first;
      final firstVariant = product.colors.first;
      final secondVariant = product.colors.last;

      await cart.add(product, firstVariant);
      await cart.add(product, firstVariant, quantity: 2);
      await cart.add(product, secondVariant);

      expect(cart.itemCount, 4);
      expect(cart.items, hasLength(2));
      expect(cart.items.first.quantity, 3);

      await cart.updateQuantity(cart.items.first, 1);
      await cart.remove(cart.items.last);
      expect(cart.itemCount, 1);
      expect(cart.items, hasLength(1));
    },
  );

  test('subtotal, tax, and standard shipping threshold are correct', () async {
    final headphone = mockCatalog.firstWhere(
      (product) => product.id == 'studio-classic',
    );
    await cart.add(headphone, headphone.colors.first);

    expect(cart.subtotal, 159);
    expect(cart.shipping, 18);
    expect(cart.tax, closeTo(12.72, 0.001));

    await cart.updateQuantity(cart.items.single, 2);
    expect(cart.subtotal, 318);
    expect(cart.shipping, 0);
  });

  test('AUDIO10 and VIP20 discounts reduce taxable amount', () async {
    final headphone = mockCatalog.firstWhere(
      (product) => product.id == 'echo-mini',
    );
    await cart.add(headphone, headphone.colors.first);

    expect(await cart.applyPromo(' audio10 '), isTrue);
    expect(cart.discount, closeTo(11.9, 0.001));
    expect(cart.tax, closeTo((119 - 11.9) * 0.08, 0.001));

    expect(await cart.applyPromo('VIP20'), isFalse);
    expect(cart.promoError, contains('\$500'));
    expect(cart.discount, closeTo(11.9, 0.001));

    await cart.add(headphone, headphone.colors.first, quantity: 4);
    expect(cart.subtotal, 595);
    expect(await cart.applyPromo('VIP20'), isTrue);
    expect(cart.discount, closeTo(119, 0.001));

    expect(await cart.applyPromo('NOPE'), isFalse);
    expect(cart.discount, 0);
  });

  test(
    'FREESHIP waives shipping without discount and clear resets promo',
    () async {
      final headphone = mockCatalog.firstWhere(
        (product) => product.id == 'echo-mini',
      );
      await cart.add(headphone, headphone.colors.first);

      expect(await cart.applyPromo('FREESHIP'), isTrue);
      expect(cart.discount, 0);
      expect(cart.shipping, 0);
      await cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.promoApplied, isFalse);
      expect(cart.shipping, 0);
    },
  );
}
