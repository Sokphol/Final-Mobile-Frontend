import 'headphone.dart';

class CartItem {
  CartItem({required this.headphone, required this.variant, this.quantity = 1});

  final Headphone headphone;
  final ColorVariant variant;
  int quantity;

  String get key => '${headphone.id}:${variant.name}';
  double get total => headphone.price * quantity;
}
