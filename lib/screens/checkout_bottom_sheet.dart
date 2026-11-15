import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import '../state/grocery_state.dart';
import 'orders_screen.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CheckoutBottomSheet(),
    );
  }

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  String _address = 'St. 214, Daun Penh, Phnom Penh';
  String _paymentMethod = 'ABA Pay / KHQR';
  final _promoController = TextEditingController();
  double _discount = 0.0;
  String? _promoMessage;
  bool _isProcessing = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo(double subtotal) {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'FRESH10') {
      setState(() {
        _discount = subtotal * 0.10;
        _promoMessage = '10% discount applied!';
      });
    } else if (code.isNotEmpty) {
      setState(() {
        _discount = 0.0;
        _promoMessage = 'Invalid code. Try "FRESH10"';
      });
    }
  }

  void _changeAddress() {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: _address);
        return AlertDialog(
          title: const Text('Delivery Address'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Enter your delivery address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((val) {
      if (val != null && val.isNotEmpty) {
        setState(() => _address = val);
      }
    });
  }

  void _selectPayment() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.green),
              title: const Text('ABA Pay / KHQR'),
              trailing: _paymentMethod == 'ABA Pay / KHQR'
                  ? const Icon(Icons.check, color: AppColors.green)
                  : null,
              onTap: () => Navigator.of(ctx).pop('ABA Pay / KHQR'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Credit or Debit Card'),
              trailing: _paymentMethod == 'Credit or Debit Card'
                  ? const Icon(Icons.check, color: AppColors.green)
                  : null,
              onTap: () => Navigator.of(ctx).pop('Credit or Debit Card'),
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.amber),
              title: const Text('Cash on Delivery'),
              trailing: _paymentMethod == 'Cash on Delivery'
                  ? const Icon(Icons.check, color: AppColors.green)
                  : null,
              onTap: () => Navigator.of(ctx).pop('Cash on Delivery'),
            ),
          ],
        ),
      ),
    ).then((val) {
      if (val != null) {
        setState(() => _paymentMethod = val);
      }
    });
  }

  Future<void> _placeOrder(GroceryState state) async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final order = state.placeOrder(
      address: _address,
      paymentMethod: _paymentMethod,
      discount: _discount,
    );

    Navigator.of(context).pop(); // Dismiss bottom sheet

    // Show Accepted Dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Order Has Been Accepted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Order ID: ${order.id}\nYour items have been placed and are on their way to being prepared for delivery.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const OrdersScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Track Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GroceryScope.of(context);
    final subtotal = state.cartSubtotal;
    final delivery = state.deliveryFee;
    final total = (subtotal - _discount + delivery).clamp(0.0, double.infinity);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Checkout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),

          // Delivery Address
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _changeAddress,
          ),
          const Divider(height: 16, color: AppColors.border),

          // Payment Method
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Payment Method',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _paymentMethod,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectPayment,
          ),
          const Divider(height: 16, color: AppColors.border),

          // Promo Code Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Promo code (try FRESH10)',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _applyPromo(subtotal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_promoMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              _promoMessage!,
              style: TextStyle(
                fontSize: 12,
                color: _discount > 0 ? AppColors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Divider(height: 24, color: AppColors.border),

          // Cost Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppColors.muted)),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_discount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Promo Discount',
                  style: TextStyle(color: AppColors.green),
                ),
                Text(
                  '-\$${_discount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee',
                style: TextStyle(color: AppColors.muted),
              ),
              Text(
                delivery == 0 ? 'FREE' : '\$${delivery.toStringAsFixed(2)}',
                style: TextStyle(
                  color: delivery == 0 ? AppColors.green : AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'By placing an order you agree to our Terms And Conditions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 16),

          // Place Order Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _placeOrder(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
