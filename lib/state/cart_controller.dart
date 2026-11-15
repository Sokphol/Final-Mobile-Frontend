import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/headphone.dart';
import '../models/mock_catalog.dart';

class CartController extends ChangeNotifier {
  static const storageKey = 'sonicflow.cart';

  final List<CartItem> items = [];
  String? _userScope;
  int _scopeLoadGeneration = 0;
  String? promoCode;
  double deliveryFee = 0;
  String deliverySpeed = 'Standard';
  String promoError = '';

  bool get promoApplied => promoCode != null;
  int get itemCount => items.fold(0, (count, item) => count + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get discount => switch (promoCode) {
    'AUDIO10' => subtotal * 0.10,
    'VIP20' when subtotal >= 500 => subtotal * 0.20,
    _ => 0,
  };
  double get shipping =>
      deliveryFee +
      (subtotal == 0 || subtotal >= 300 || promoCode == 'FREESHIP' ? 0 : 18);
  double get tax => (subtotal - discount) * 0.08;
  double get total => subtotal - discount + shipping + tax;

  Future<void> hydrate({String? userId}) async {
    _userScope = userId;
    await _loadCurrentScope(++_scopeLoadGeneration);
  }

  Future<void> switchUserScope(String? userId) async {
    if (_userScope == userId) return;
    _userScope = userId;
    final generation = ++_scopeLoadGeneration;
    items.clear();
    promoCode = null;
    deliveryFee = 0;
    deliverySpeed = 'Standard';
    promoError = '';
    notifyListeners();
    await _loadCurrentScope(generation);
  }

  String get _currentStorageKey => _userScope == null
      ? storageKey
      : '$storageKey.user.${Uri.encodeComponent(_userScope!)}';

  Future<void> _loadCurrentScope(int generation) async {
    final storageKey = _currentStorageKey;
    final preferences = await SharedPreferences.getInstance();
    if (_scopeLoadGeneration != generation) return;
    final encoded = preferences.getString(storageKey);
    if (encoded == null) {
      notifyListeners();
      return;
    }

    final data = jsonDecode(encoded) as Map<String, dynamic>;
    final restored = <CartItem>[];
    for (final entry in data['items'] as List<dynamic>) {
      final item = entry as Map<String, dynamic>;
      final product = allStoreProducts.firstWhere(
        (product) => product.id == item['productId'],
      );
      final variant = product.colors.firstWhere(
        (variant) => variant.name == item['variant'],
      );
      restored.add(
        CartItem(
          headphone: product,
          variant: variant,
          quantity: item['quantity'] as int,
        ),
      );
    }
    items
      ..clear()
      ..addAll(restored);
    final savedCode = data['promoCode'] as String?;
    promoCode = const {'AUDIO10', 'VIP20', 'FREESHIP'}.contains(savedCode)
        ? savedCode
        : null;
    deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0;
    deliverySpeed = data['deliverySpeed'] as String? ?? 'Standard';
    notifyListeners();
  }

  Future<void> _persist() async {
    final storageKey = _currentStorageKey;
    final encoded = jsonEncode({
      'promoCode': promoCode,
      'deliveryFee': deliveryFee,
      'deliverySpeed': deliverySpeed,
      'items': [
        for (final item in items)
          {
            'productId': item.headphone.id,
            'variant': item.variant.name,
            'quantity': item.quantity,
          },
      ],
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, encoded);
  }

  Future<void> add(
    Headphone headphone,
    ColorVariant variant, {
    int quantity = 1,
  }) async {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive');
    }
    final existing = items.where(
      (item) => item.key == '${headphone.id}:${variant.name}',
    );
    if (existing.isEmpty) {
      items.add(
        CartItem(headphone: headphone, variant: variant, quantity: quantity),
      );
    } else {
      existing.first.quantity += quantity;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    if (quantity < 1) {
      items.remove(item);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(CartItem item) async {
    items.remove(item);
    notifyListeners();
    await _persist();
  }

  Future<bool> applyPromo(String code) async {
    final normalized = code.trim().toUpperCase();
    promoError = '';
    if (normalized == 'VIP20' && subtotal < 500) {
      promoError = 'VIP20 requires a \$500 minimum purchase.';
      notifyListeners();
      return false;
    }
    if (!const {'AUDIO10', 'VIP20', 'FREESHIP'}.contains(normalized)) {
      promoCode = null;
      promoError = 'Code not recognized.';
      notifyListeners();
      await _persist();
      return false;
    }
    promoCode = normalized;
    notifyListeners();
    await _persist();
    return promoApplied;
  }

  Future<void> setDeliverySpeed(String speed) async {
    final fees = {'Standard': 0.0, 'Priority': 15.0, 'Same-Day': 29.0};
    final fee = fees[speed];
    if (fee == null) throw ArgumentError.value(speed, 'speed');
    deliverySpeed = speed;
    deliveryFee = fee;
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    items.clear();
    promoCode = null;
    deliveryFee = 0;
    deliverySpeed = 'Standard';
    promoError = '';
    notifyListeners();
    await _persist();
  }
}
