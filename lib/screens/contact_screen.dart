import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contact')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'We’re here to help.',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Questions about headphones, an order, or finding the right sound? '
          'Reach out to the SonicFlow team.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 22),
        _ContactDetail(
          icon: Icons.phone_outlined,
          title: 'Support hotline',
          detail: '+855 12 345 678',
        ),
        const SizedBox(height: 12),
        _ContactDetail(
          icon: Icons.schedule_outlined,
          title: 'Service hours',
          detail: 'Every day, 7:00 AM – 10:00 PM',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'SonicFlow is a demo storefront. The hotline and service hours '
            'shown here are sample support details and should be replaced '
            'with your store’s contact information before launch.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
        ),
      ],
    ),
  );
}

class _ContactDetail extends StatelessWidget {
  const _ContactDetail({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.gold),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              SelectableText(
                detail,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
