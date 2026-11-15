import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../../models/mock_catalog.dart';
import '../../state/cart_controller.dart';

class SoundFinderQuiz extends StatefulWidget {
  const SoundFinderQuiz({required this.cart, super.key});

  final CartController cart;

  static Future<void> show(BuildContext context, CartController cart) =>
      showDialog<void>(
        context: context,
        builder: (context) => SoundFinderQuiz(cart: cart),
      );

  @override
  State<SoundFinderQuiz> createState() => _SoundFinderQuizState();
}

class _SoundFinderQuizState extends State<SoundFinderQuiz> {
  static const _steps = <(String, List<String>)>[
    ('Environment', ['Commute', 'Studio', 'At home']),
    ('Signature', ['Balanced', 'Bass-forward', 'Detailed']),
    ('Form Factor', ['Over-ear', 'True wireless', 'Open-back']),
    ('Budget', ['Under \$200', '\$200–\$500', 'Any budget']),
  ];

  final List<String> _answers = [];
  bool _complete = false;

  Headphone get _winner =>
      mockCatalog.firstWhere((product) => product.id == 'apex-anc-pro');
  Headphone get _runnerUp =>
      mockCatalog.firstWhere((product) => product.id == 'roam-anc');

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _complete ? _result(context) : _question(context),
      ),
    ),
  );

  Widget _question(BuildContext context) {
    final step = _answers.length;
    final current = _steps[step];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FIND YOUR SOUND',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (step + 1) / _steps.length),
        const SizedBox(height: 18),
        Text(
          '${step + 1}/4  ·  ${current.$1}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        for (final answer in current.$2)
          ListTile(
            title: Text(answer),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() {
              _answers.add(answer);
              if (_answers.length == _steps.length) _complete = true;
            }),
          ),
      ],
    );
  }

  Widget _result(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR SOUND MATCH',
          style: TextStyle(color: AppColors.gold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        const Text(
          '98% Match Winner',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Text(_winner.name, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text('Runner-up: ${_runnerUp.name}'),
        const SizedBox(height: 18),
        Wrap(
          spacing: 6,
          children: [for (final answer in _answers) Chip(label: Text(answer))],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await widget.cart.add(_winner, _winner.colors.first);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add Match to Cart'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ],
    ),
  );
}
