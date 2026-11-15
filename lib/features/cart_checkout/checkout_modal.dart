import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/orders_controller.dart';

class CheckoutModal extends StatefulWidget {
  const CheckoutModal({
    required this.cart,
    required this.orders,
    required this.auth,
    super.key,
  });

  final CartController cart;
  final OrdersController orders;
  final AuthController auth;

  static Future<void> show(
    BuildContext context,
    CartController cart,
    OrdersController orders,
    AuthController auth,
  ) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        CheckoutModal(cart: cart, orders: orders, auth: auth),
  );

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  static const _draftKey = 'sonicflow.shippingDraft';
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  int _step = 0;
  String? _orderId;
  StoreOrder? _submittedOrder;
  bool _isPaying = false;
  String? _paymentError;

  @override
  void initState() {
    super.initState();
    _name.text = widget.auth.user?['name'] as String? ?? '';
    _email.text = widget.auth.user?['email'] as String? ?? '';
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_draftKey);
    if (encoded == null || !mounted) return;
    final draft = jsonDecode(encoded) as Map<String, dynamic>;
    _name.text = draft['name'] as String? ?? '';
    _email.text = draft['email'] as String? ?? '';
    _street.text = draft['street'] as String? ?? '';
    _city.text = draft['city'] as String? ?? '';
    _postal.text = draft['postal'] as String? ?? '';
    setState(() {});
  }

  Future<void> _saveDraft() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _draftKey,
      jsonEncode({
        'name': _name.text,
        'email': _email.text,
        'street': _street.text,
        'city': _city.text,
        'postal': _postal.text,
      }),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _street.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.elevated,
    insetPadding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.border),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'SECURE CHECKOUT',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (_step < 2)
                  IconButton(
                    tooltip: 'Close checkout',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StepLabel(
                  '01',
                  'Shipping',
                  active: _step == 0,
                  complete: _step > 0,
                ),
                _line(),
                _StepLabel(
                  '02',
                  'Payment',
                  active: _step == 1,
                  complete: _step > 1,
                ),
                _line(),
                _StepLabel('03', 'Confirm', active: _step == 2),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: _step == 0
                    ? _shippingForm()
                    : _step == 1
                    ? _paymentForm()
                    : _confirmation(),
              ),
            ),
            const SizedBox(height: 12),
            if (_step < 2)
              Row(
                children: [
                  TextButton(
                    onPressed: _isPaying
                        ? null
                        : _step == 0
                        ? () => Navigator.pop(context)
                        : () => setState(() => _step--),
                    child: Text(_step == 0 ? 'Cancel' : 'Back'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isPaying
                        ? null
                        : _step == 0
                        ? _next
                        : _payWithKhqr,
                    icon: _isPaying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _step == 0
                                ? Icons.arrow_forward
                                : Icons.qr_code_2,
                            size: 16,
                          ),
                    label: Text(
                      _step == 0
                          ? 'Continue to payment'
                          : _isPaying
                          ? 'Processing...'
                          : 'Pay with KHQR',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );

  Widget _shippingForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where should we send your sound?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        _field(_name, 'Full name', validator: _required),
        const SizedBox(height: 10),
        _field(
          _email,
          'Email',
          keyboard: TextInputType.emailAddress,
          validator: (value) =>
              value != null &&
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
              ? null
              : 'Enter a valid email',
        ),
        const SizedBox(height: 10),
        _field(_street, 'Street address', validator: _required),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _field(_city, 'City', validator: _required)),
            const SizedBox(width: 10),
            Expanded(
              child: _field(_postal, 'Postal code', validator: _required),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Delivery speed',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final option in const [
              ('Standard', 0.0),
              ('Priority', 15.0),
              ('Same-Day', 29.0),
            ])
              ChoiceChip(
                label: Text('${option.$1} +\$${option.$2.toStringAsFixed(0)}'),
                selected: widget.cart.deliverySpeed == option.$1,
                onSelected: (_) => widget.cart.setDeliverySpeed(option.$1),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _paymentForm() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KHQR payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Total: \$${widget.cart.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap “Pay with KHQR” to display the QR code. This classroom demo '
          'simulates payment success after 20 seconds; it does not verify a '
          'transfer or charge an account.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.5),
        ),
        if (_paymentError != null) ...[
          const SizedBox(height: 10),
          Text(
            _paymentError!,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ],
  );

  Widget _confirmation() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.check_circle, color: AppColors.success, size: 42),
      const SizedBox(height: 12),
      const Text(
        'Demo payment successful!',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Text(
        'Order #${_orderId ?? 'SF-2026-0000'}',
        style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      const _DeliveryTimeline(),
      const SizedBox(height: 14),
      Text(
        'A confirmation will be sent to ${_email.text}. Estimated delivery: ${_deliveryDate()}.',
        style: TextStyle(color: AppColors.muted, height: 1.6),
      ),
      const SizedBox(height: 6),
      Text(
        'This is a simulated payment. No money was transferred.',
        style: TextStyle(color: AppColors.muted, fontSize: 11),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (final item in _submittedOrder?.lines ?? const <OrderLine>[])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity} × ${item.productName}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '\$${_submittedOrder?.total.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.done),
          label: const Text('Done'),
        ),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    validator: validator,
    onChanged: (_) {
      _saveDraft();
      if (mounted) setState(() {});
    },
    decoration: InputDecoration(labelText: label, isDense: true),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _next() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _step++);
  }

  Future<void> _payWithKhqr() async {
    setState(() {
      _isPaying = true;
      _paymentError = null;
    });

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _KhqrPaymentDialog(total: widget.cart.total),
      );
      final order = await widget.orders.record(widget.cart, email: _email.text);
      await widget.cart.clear();
      if (!mounted) return;
      setState(() {
        _orderId = order.id;
        _submittedOrder = order;
        _isPaying = false;
        _step = 2;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _paymentError = 'Could not save your demo order: $error';
      });
    }
  }

  String _deliveryDate() {
    final date = DateTime.now().add(const Duration(days: 5));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _KhqrPaymentDialog extends StatefulWidget {
  const _KhqrPaymentDialog({required this.total});

  final double total;

  @override
  State<_KhqrPaymentDialog> createState() => _KhqrPaymentDialogState();
}

class _KhqrPaymentDialogState extends State<_KhqrPaymentDialog> {
  Timer? _timer;
  int _secondsRemaining = 20;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        Navigator.of(context).pop();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Scan KHQR'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/KHQR.jpg',
            width: 240,
            height: 240,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.square(
                  dimension: 240,
                  child: Center(child: Text('KHQR image could not be loaded.')),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Demo amount: \$${widget.total.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        Text(
          'Simulating payment… $_secondsRemaining',
          key: const ValueKey('khqr-countdown'),
        ),
        const SizedBox(height: 8),
        const Text(
          'No real payment is being requested or verified.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(
    this.number,
    this.title, {
    this.active = false,
    this.complete = false,
  });
  final String number;
  final String title;
  final bool active;
  final bool complete;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 13,
        backgroundColor: active || complete
            ? AppColors.orange
            : AppColors.surface,
        child: Text(number, style: const TextStyle(fontSize: 9)),
      ),
      const SizedBox(width: 6),
      Text(
        title,
        style: TextStyle(
          color: active ? AppColors.text : AppColors.muted,
          fontSize: 10,
        ),
      ),
    ],
  );
}

Widget _line() => const Expanded(child: Divider(indent: 8, endIndent: 8));


class _DeliveryTimeline extends StatelessWidget {
  const _DeliveryTimeline();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Delivery timeline', style: TextStyle(fontWeight: FontWeight.w700)),
      SizedBox(height: 8),
      _TimelineStage('Order confirmed'),
      _TimelineStage('Preparing your headphones'),
      _TimelineStage('On the way'),
      _TimelineStage('Delivered'),
    ],
  );
}

class _TimelineStage extends StatelessWidget {
  const _TimelineStage(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: AppColors.orange),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}
