import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/screens/order_tracking_screen.dart';
import 'package:flutter_homepage/state/orders_controller.dart';

void main() {
  testWidgets('tracking screen shows order status, ETA, and demo disclaimer', (
    tester,
  ) async {
    final order = StoreOrder(
      id: 'SF-2026-test',
      email: 'buyer@example.com',
      createdAt: DateTime.now(),
      lines: const [
        OrderLine(
          productId: 'apex-anc-pro',
          productName: 'SonicFlow Apex ANC Pro',
          variant: 'Obsidian',
          quantity: 1,
          unitPrice: 499,
        ),
      ],
      subtotal: 499,
      discount: 0,
      shipping: 0,
      tax: 39.92,
      total: 538.92,
    );

    await tester.pumpWidget(
      MaterialApp(home: OrderTrackingScreen(order: order)),
    );

    expect(find.text('Order confirmed'), findsNWidgets(2));
    expect(
      find.text('Estimated delivery ${_format(order.estimatedDelivery)}'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Demo tracking only. Status advances locally over five days; there are no live carrier updates or real delivery events.',
      ),
      findsOneWidget,
    );
    expect(find.text('SonicFlow Apex ANC Pro'), findsOneWidget);
  });
}

String _format(DateTime date) =>
    '${_month(date.month)} ${date.day}, ${date.year}';

String _month(int month) => const [
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
][month - 1];
