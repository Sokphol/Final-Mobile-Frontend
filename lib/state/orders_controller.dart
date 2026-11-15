import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_controller.dart';

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.productName,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final String variant;
  final int quantity;
  final double unitPrice;

  double get total => unitPrice * quantity;

  Map<String, Object> toJson() => {
    'productId': productId,
    'productName': productName,
    'variant': variant,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    variant: json['variant'] as String,
    quantity: json['quantity'] as int,
    unitPrice: (json['unitPrice'] as num).toDouble(),
  );
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  final String id;
  final String email;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;

  int get deliveryStage {
    final age = DateTime.now().difference(createdAt);
    if (age >= const Duration(days: 5)) return 3;
    if (age >= const Duration(days: 2)) return 2;
    if (age >= const Duration(days: 1)) return 1;
    return 0;
  }

  String get deliveryStatus => const [
    'Order confirmed',
    'Preparing your order',
    'On the way',
    'Delivered',
  ][deliveryStage];

  DateTime get estimatedDelivery => createdAt.add(const Duration(days: 5));

  Map<String, Object> toJson() => {
    'id': id,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
    'lines': lines.map((line) => line.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'shipping': shipping,
    'tax': tax,
    'total': total,
  };

  factory StoreOrder.fromJson(Map<String, dynamic> json) => StoreOrder(
    id: json['id'] as String,
    email: json['email'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lines: (json['lines'] as List<dynamic>)
        .map((line) => OrderLine.fromJson(line as Map<String, dynamic>))
        .toList(growable: false),
    subtotal: (json['subtotal'] as num).toDouble(),
    discount: (json['discount'] as num).toDouble(),
    shipping: (json['shipping'] as num).toDouble(),
    tax: (json['tax'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
  );
}

typedef OrderRecord = StoreOrder;

class OrdersController extends ChangeNotifier {
  static const storageKey = 'sonicflow.orders';

  final List<StoreOrder> orders = [];
  String? _userScope;
  int _scopeLoadGeneration = 0;

  Future<void> hydrate({String? userId}) async {
    _userScope = userId;
    await _loadCurrentScope(++_scopeLoadGeneration);
  }

  Future<void> switchUserScope(String? userId) async {
    if (_userScope == userId) return;
    _userScope = userId;
    final generation = ++_scopeLoadGeneration;
    orders.clear();
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

    final restored = (jsonDecode(encoded) as List<dynamic>)
        .map((entry) => StoreOrder.fromJson(entry as Map<String, dynamic>))
        .toList(growable: false);
    orders
      ..clear()
      ..addAll(restored);
    notifyListeners();
  }

  Future<StoreOrder> record(
    CartController cart, {
    required String email,
  }) async {
    if (cart.items.isEmpty) {
      throw StateError('Cannot create an order from an empty cart.');
    }
    final now = DateTime.now();
    final order = StoreOrder(
      id: 'SF-${now.year}-${now.microsecondsSinceEpoch}',
      email: email.trim(),
      createdAt: now,
      lines: [
        for (final item in cart.items)
          OrderLine(
            productId: item.headphone.id,
            productName: item.headphone.name,
            variant: item.variant.name,
            quantity: item.quantity,
            unitPrice: item.headphone.price,
          ),
      ],
      subtotal: cart.subtotal,
      discount: cart.discount,
      shipping: cart.shipping,
      tax: cart.tax,
      total: cart.total,
    );
    orders.insert(0, order);
    final storageKey = _currentStorageKey;
    final encoded = jsonEncode(
      orders.map((savedOrder) => savedOrder.toJson()).toList(),
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      encoded,
    );
    notifyListeners();
    return order;
  }
}
