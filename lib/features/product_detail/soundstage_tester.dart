import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SoundstageTester extends StatefulWidget {
  const SoundstageTester({super.key});

  @override
  State<SoundstageTester> createState() => _SoundstageTesterState();
}

class _SoundstageTesterState extends State<SoundstageTester> {
  double _ambient = 0.62;
  bool _ancEnabled = true;
  final Map<String, Offset> _stems = {
    'Vocals': const Offset(0.5, 0.42),
    'Sub-Bass': const Offset(0.28, 0.72),
    'Guitar': const Offset(0.7, 0.56),
    'Percussion': const Offset(0.74, 0.3),
  };

  List<double> get _spectrum => List.generate(24, (index) {
    final stem = _stems.values.elementAt(index % _stems.length);
    final center = (index / 23);
    return (0.18 + (1 - (center - stem.dx).abs()) * 0.72).clamp(0.08, 1.0);
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'SOUNDSTAGE LAB',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            Icon(Icons.spatial_audio, color: AppColors.orange),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Drag sound sources to shape your listening space.',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: 210,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SoundstagePainter(
                      ambient: _ambient,
                      ancEnabled: _ancEnabled,
                    ),
                  ),
                ),
                for (final entry in _stems.entries)
                  Positioned(
                    left: (constraints.maxWidth - 86) * entry.value.dx,
                    top: (210 - 32) * entry.value.dy,
                    child: GestureDetector(
                      key: ValueKey('stem-${entry.key}'),
                      onPanUpdate: (details) => setState(() {
                        final current = _stems[entry.key]!;
                        _stems[entry.key] = Offset(
                          (current.dx + details.delta.dx / constraints.maxWidth)
                              .clamp(0, 0.9),
                          (current.dy + details.delta.dy / 210).clamp(0, 0.8),
                        );
                      }),
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(entry.key),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Text(
          _stems.entries
              .map((entry) {
                final pan = ((_stems[entry.key]!.dx - 0.5) * 200).round();
                final distance = ((_stems[entry.key]!.dy) * 12 - 6);
                return '${entry.key}: ${pan < 0 ? '${pan.abs()}% L' : '$pan% R'}, ${distance.toStringAsFixed(1)} dB';
              })
              .join('  ·  '),
          key: const ValueKey('soundstage-readout'),
          style: TextStyle(color: AppColors.muted, fontSize: 9),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: CustomPaint(
            key: const ValueKey('eq-spectrum-24-band'),
            painter: _EqSpectrumPainter(_spectrum),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Jet Engine (90dB)',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
            Text(
              _ancEnabled ? '9dB ambient' : '90dB ambient',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        SizedBox(
          height: 34,
          width: double.infinity,
          child: CustomPaint(
            key: ValueKey('noise-scope-$_ancEnabled'),
            painter: _NoiseOscilloscopePainter(ancEnabled: _ancEnabled),
          ),
        ),
        Row(
          children: [
            const Text('Ambient field', style: TextStyle(fontSize: 11)),
            Expanded(
              child: Slider(
                value: _ambient,
                onChanged: (value) => setState(() => _ambient = value),
              ),
            ),
            Text(
              '${(_ambient * 100).round()}%',
              style: TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
        Material(
          color: AppColors.surface,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Hybrid ANC (-48dB)',
              style: TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              _ancEnabled
                  ? 'External noise reduced'
                  : 'Ambient sound passed through',
              style: const TextStyle(fontSize: 10),
            ),
            value: _ancEnabled,
            onChanged: (value) => setState(() => _ancEnabled = value),
          ),
        ),
      ],
    ),
  );
}

class _SoundstagePainter extends CustomPainter {
  const _SoundstagePainter({required this.ambient, required this.ancEnabled});
  final double ambient;
  final bool ancEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;
    final grid = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var ring = 1; ring <= 3; ring++) {
      canvas.drawCircle(center, radius * ring / 3, grid);
    }
    for (var axis = 0; axis < 6; axis++) {
      final angle = -math.pi / 2 + axis * math.pi / 3;
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        grid,
      );
    }
    final values = [
      0.74,
      0.83,
      0.69,
      0.78,
      0.72,
      ancEnabled ? 1 - ambient * 0.7 : ambient,
    ];
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) * radius * values[i];
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.orange.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final text = ['WIDTH', 'AIR', 'DETAIL', 'DEPTH', 'IMAGING', 'ISOLATION'];
    for (var i = 0; i < text.length; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final p =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 14);
      final painter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(p.dx - painter.width / 2, p.dy - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundstagePainter oldDelegate) =>
      oldDelegate.ambient != ambient || oldDelegate.ancEnabled != ancEnabled;
}

class _EqSpectrumPainter extends CustomPainter {
  const _EqSpectrumPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.orange;
    final gap = 3.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;
    for (var index = 0; index < values.length; index++) {
      final height = size.height * values[index];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            index * (barWidth + gap),
            size.height - height,
            barWidth,
            height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqSpectrumPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _NoiseOscilloscopePainter extends CustomPainter {
  const _NoiseOscilloscopePainter({required this.ancEnabled});
  final bool ancEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final attenuation = ancEnabled ? 0.1 : 1.0;
    for (var x = 0; x <= size.width.round(); x++) {
      final y =
          size.height / 2 + math.sin(x / 6) * size.height * 0.44 * attenuation;
      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFF4545)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant _NoiseOscilloscopePainter oldDelegate) =>
      oldDelegate.ancEnabled != ancEnabled;
}
