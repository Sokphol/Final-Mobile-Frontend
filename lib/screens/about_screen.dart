import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About SonicFlow')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 32),
              const SizedBox(height: 18),
              Text(
                'SOUND, CONSIDERED.',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A better kind of listening.',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'SonicFlow brings together thoughtfully selected headphones '
                'and audio gear for every way you listen, from focused studio '
                'sessions to music on the move.',
                style: TextStyle(color: AppColors.muted, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'WHAT GUIDES US',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _AboutValue(
          icon: Icons.hearing_rounded,
          title: 'Listen first',
          detail:
              'Choose gear for the way it sounds and feels, not just the specs.',
        ),
        const SizedBox(height: 10),
        _AboutValue(
          icon: Icons.tune_rounded,
          title: 'Find your fit',
          detail:
              'Explore different listening styles and find what suits you.',
        ),
        const SizedBox(height: 10),
        _AboutValue(
          icon: Icons.favorite_border_rounded,
          title: 'Keep it personal',
          detail:
              'Save the products you love and compare your favorites.',
        ),
      ],
    ),
  );
}

class _AboutValue extends StatelessWidget {
  const _AboutValue({
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
