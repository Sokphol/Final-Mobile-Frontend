import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../state/orders_controller.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({required this.order, super.key});

  final StoreOrder order;

  static const _stages = [
    ('Order confirmed', 'Your demo order has been recorded.'),
    ('Preparing your order', 'Your items are being prepared.'),
    ('On the way', 'Your order is on its way to you.'),
    ('Delivered', 'Your delivery is complete.'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeStage = order.deliveryStage;
    return Scaffold(
      appBar: AppBar(title: const Text('Track delivery')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            order.id,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            order.deliveryStatus,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            activeStage == 3
                ? 'Delivered ${_formatDate(order.estimatedDelivery)}'
                : 'Estimated delivery ${_formatDate(order.estimatedDelivery)}',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          for (var index = 0; index < _stages.length; index++)
            _TrackingStage(
              title: _stages[index].$1,
              detail: _stages[index].$2,
              complete: index <= activeStage,
              current: index == activeStage,
              isLast: index == _stages.length - 1,
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Demo tracking only. Status advances locally over five days; '
              'there are no live carrier updates or real delivery events.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ITEMS IN THIS ORDER',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in order.lines)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(line.productName),
              subtitle: Text('${line.variant} · Qty ${line.quantity}'),
              trailing: Text('\$${line.total.toStringAsFixed(2)}'),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
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
}

class _TrackingStage extends StatelessWidget {
  const _TrackingStage({
    required this.title,
    required this.detail,
    required this.complete,
    required this.current,
    required this.isLast,
  });

  final String title;
  final String detail;
  final bool complete;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Icon(
                complete ? Icons.check_circle : Icons.radio_button_unchecked,
                color: complete ? AppColors.gold : AppColors.muted,
                size: 19,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: complete
                        ? AppColors.gold.withValues(alpha: 0.6)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                    color: complete ? AppColors.text : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
