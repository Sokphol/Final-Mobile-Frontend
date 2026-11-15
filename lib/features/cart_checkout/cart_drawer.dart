import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/cart_item.dart';
import '../../models/mock_catalog.dart';
import '../../features/auth/auth_dialog.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/orders_controller.dart';
import '../catalog/product_hover_card.dart';
import 'checkout_modal.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({
    required this.cart,
    required this.orders,
    required this.auth,
    super.key,
  });

  final CartController cart;
  final OrdersController orders;
  final AuthController auth;

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Drawer(
    width: MediaQuery.sizeOf(context).width < 440
        ? MediaQuery.sizeOf(context).width
        : 420,
    backgroundColor: AppColors.elevated,
    child: SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.cart, widget.auth]),
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'YOUR BAG  ·  ${widget.cart.itemCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close cart',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.auth.isAuthenticated
                          ? (widget.auth.user?['email'] as String?) ?? ''
                          : 'Guest checkout is available',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.auth.isAuthenticated
                        ? _signOut
                        : _openAccount,
                    child: Text(
                      widget.auth.isAuthenticated
                          ? 'Sign out'
                          : 'Optional sign in',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: widget.cart.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 42,
                            color: AppColors.muted,
                          ),
                          SizedBox(height: 12),
                          Text('Your bag is waiting for a soundtrack.'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.cart.items.length + 1,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 24),
                      itemBuilder: (context, index) {
                        if (index == widget.cart.items.length) {
                          return _accessoryUpsells();
                        }
                        return _CartLine(
                          item: widget.cart.items[index],
                          cart: widget.cart,
                        );
                      },
                    ),
            ),
            if (widget.cart.items.isNotEmpty) _summary(context),
          ],
        ),
      ),
    ),
  );

  Widget _summary(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promo,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Promo code',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                final applied = await widget.cart.applyPromo(_promo.text);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      applied
                          ? '${widget.cart.promoCode} applied.'
                          : widget.cart.promoError.isEmpty
                          ? 'Code not recognized. Try AUDIO10, VIP20, or FREESHIP.'
                          : widget.cart.promoError,
                    ),
                  ),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Available codes',
          style: TextStyle(color: AppColors.muted, fontSize: 10),
        ),
        Wrap(
          spacing: 4,
          children: [
            for (final code in const ['AUDIO10', 'VIP20', 'FREESHIP'])
              ActionChip(
                label: Text(code),
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final applied = await widget.cart.applyPromo(code);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        applied
                            ? '$code applied.'
                            : widget.cart.promoError.isEmpty
                            ? 'Could not apply $code.'
                            : widget.cart.promoError,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        if (widget.cart.promoApplied)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  switch (widget.cart.promoCode) {
                    'AUDIO10' => 'AUDIO10  ·  10% off',
                    'VIP20' => 'VIP20  ·  20% off',
                    _ => 'FREESHIP  ·  free shipping',
                  },
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        if (widget.cart.promoError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.cart.promoError,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
        if (widget.cart.subtotal < 300 && widget.cart.promoCode != 'FREESHIP')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${(300 - widget.cart.subtotal).toStringAsFixed(2)} away from free shipping',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: (widget.cart.subtotal / 300).clamp(0, 1),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        _SummaryLine('Subtotal', widget.cart.subtotal),
        if (widget.cart.promoApplied)
          _SummaryLine(
            'Promo discount',
            -widget.cart.discount,
            color: AppColors.success,
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Shipping',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            Text(
              widget.cart.shipping == 0
                  ? 'FREE (\$0.00)'
                  : '\$${widget.cart.shipping.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _SummaryLine('Estimated tax', widget.cart.tax),
        const Divider(height: 20),
        _SummaryLine('Grand total', widget.cart.total, strong: true),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startCheckout,
            icon: const Icon(Icons.lock_outline, size: 17),
            label: const Text('Proceed to checkout'),
          ),
        ),
      ],
    ),
  );

  Future<void> _startCheckout() async {
    if (!mounted) return;
    await CheckoutModal.show(context, widget.cart, widget.orders, widget.auth);
  }

  Future<void> _openAccount() async {
    await AuthDialog.show(context, widget.auth);
  }

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not sign out: $error')));
    }
  }

  Widget _accessoryUpsells() => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Complete your setup',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        for (final accessory in storeAccessories)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(accessory.name, style: const TextStyle(fontSize: 11)),
            subtitle: Text('\$${accessory.price.toStringAsFixed(2)}'),
            trailing: TextButton(
              onPressed: () async =>
                  widget.cart.add(accessory, accessory.colors.first),
              child: const Text('+ Add'),
            ),
          ),
      ],
    ),
  );
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.cart});
  final CartItem item;
  final CartController cart;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 68,
          height: 68,
          child: CatalogImage(url: item.headphone.imageUrl),
        ),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.headphone.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.variant.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  item.variant.name,
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async =>
                      cart.updateQuantity(item, item.quantity - 1),
                  icon: const Icon(Icons.remove, size: 15),
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 11)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async =>
                      cart.updateQuantity(item, item.quantity + 1),
                  icon: const Icon(Icons.add, size: 15),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: () => cart.remove(item),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 17,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '\$${item.total.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      ),
    ],
  );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(
    this.label,
    this.amount, {
    this.color,
    this.strong = false,
  });
  final String label;
  final double amount;
  final Color? color;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.muted,
              fontSize: strong ? 13 : 11,
              fontWeight: strong ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '${amount < 0 ? '−' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: strong ? 15 : 11,
            fontWeight: strong ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
