import 'package:flutter/material.dart';

import '../models/grocery_catalog.dart';
import '../models/product.dart';

class GroceryCartItem {
  GroceryCartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  double get total => product.priceValue * quantity;
}

class GroceryOrder {
  GroceryOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.address,
    required this.paymentMethod,
    this.status = 'Processing',
  });

  final String id;
  final DateTime date;
  final List<GroceryCartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String address;
  final String paymentMethod;
  final String status;
}

class GroceryState extends ChangeNotifier {
  GroceryState._() {
    _initializeSeedData();
  }

  static final GroceryState instance = GroceryState._();

  final Map<String, GroceryCartItem> _cart = {};
  final Set<String> _favorites = {};
  final List<GroceryOrder> _orders = [];

  void _initializeSeedData() {
    // Seed sample favorites for immediate visual richness
    _favorites.add(GroceryCatalog.allProducts[0].productId); // Bananas
    _favorites.add(GroceryCatalog.allProducts[1].productId); // Red Apple

    // Seed sample cart item so Cart tab is immediately ready to inspect
    final banana = GroceryCatalog.allProducts[0];
    final pepper = GroceryCatalog.allProducts[3];
    _cart[banana.productId] = GroceryCartItem(product: banana, quantity: 2);
    _cart[pepper.productId] = GroceryCartItem(product: pepper, quantity: 3);

    // Seed past order for Orders screen
    _orders.add(
      GroceryOrder(
        id: '#ORD-8821',
        date: DateTime.now().subtract(const Duration(days: 2)),
        items: [
          GroceryCartItem(product: GroceryCatalog.allProducts[1], quantity: 2),
          GroceryCartItem(product: GroceryCatalog.allProducts[4], quantity: 1),
        ],
        subtotal: 25.97,
        deliveryFee: 2.00,
        discount: 0.00,
        total: 27.97,
        address: 'St. 214, Sangkat Boeung Raing, Phnom Penh',
        paymentMethod: 'ABA Pay / KHQR',
        status: 'Delivered',
      ),
    );
  }

  List<GroceryCartItem> get cartItems => _cart.values.toList();
  int get cartCount => _cart.values.fold(0, (acc, item) => acc + item.quantity);

  double get cartSubtotal =>
      _cart.values.fold(0.0, (acc, item) => acc + item.total);

  double get deliveryFee =>
      (cartSubtotal > 30.0 || cartSubtotal == 0.0) ? 0.0 : 2.0;

  double get cartTotal => cartSubtotal + deliveryFee;

  void addToCart(Product product, [int quantity = 1]) {
    final key = product.productId;
    if (_cart.containsKey(key)) {
      _cart[key]!.quantity += quantity;
    } else {
      _cart[key] = GroceryCartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    final key = product.productId;
    if (quantity <= 0) {
      _cart.remove(key);
    } else if (_cart.containsKey(key)) {
      _cart[key]!.quantity = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product.productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool isFavorite(Product product) => _favorites.contains(product.productId);

  void toggleFavorite(Product product) {
    final id = product.productId;
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  List<Product> get favoriteProducts {
    return GroceryCatalog.allProducts
        .where((p) => _favorites.contains(p.productId))
        .toList();
  }

  List<GroceryOrder> get orders => List.unmodifiable(_orders);

  GroceryOrder placeOrder({
    required String address,
    required String paymentMethod,
    double discount = 0.0,
  }) {
    final sub = cartSubtotal;
    final fee = deliveryFee;
    final tot = (sub - discount + fee).clamp(0.0, double.infinity);

    final newOrder = GroceryOrder(
      id: '#ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      date: DateTime.now(),
      items: List.from(cartItems),
      subtotal: sub,
      deliveryFee: fee,
      discount: discount,
      total: tot,
      address: address,
      paymentMethod: paymentMethod,
      status: 'Processing',
    );

    _orders.insert(0, newOrder);
    _cart.clear();
    notifyListeners();
    return newOrder;
  }
}

class GroceryScope extends InheritedNotifier<GroceryState> {
  const GroceryScope({
    super.key,
    required GroceryState state,
    required super.child,
  }) : super(notifier: state);

  static GroceryState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GroceryScope>();
    return scope?.notifier ?? GroceryState.instance;
  }
}
