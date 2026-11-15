import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/headphone.dart';
import '../catalog/product_hover_card.dart';

class Headphone360Viewer extends StatefulWidget {
  const Headphone360Viewer({required this.product, super.key});

  final Headphone product;

  @override
  State<Headphone360Viewer> createState() => _Headphone360ViewerState();
}

class _Headphone360ViewerState extends State<Headphone360Viewer> {
  double _yaw = 0;
  double _pitch = 0;
  bool _autoSpin = true;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanStart: (_) => setState(() => _autoSpin = false),
    onPanUpdate: (details) => setState(() {
      _yaw = (_yaw + details.delta.dx * 0.8) % 360;
      _pitch = (_pitch - details.delta.dy * 0.35).clamp(-25, 25);
    }),
    child: MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Container(
        height: 240,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_yaw * 3.141592653589793 / 180)
                  ..rotateX(_pitch * 3.141592653589793 / 180),
                child: CatalogImage(url: widget.product.imageUrl),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: _Hotspot(
                label: '1 · Driver',
                icon: Icons.graphic_eq,
                onTap: () => _showDetail(
                  context,
                  'Driver system',
                  widget.product.specValue('Driver Type'),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 54,
              child: _Hotspot(
                label: '2 · Cushion',
                icon: Icons.spa_outlined,
                onTap: () => _showDetail(
                  context,
                  'Designed for comfort',
                  '${widget.product.specValue('Weight')} balanced with breathable, replaceable contact surfaces.',
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 96,
              child: _Hotspot(
                label: '3 · Connection',
                icon: Icons.cable,
                onTap: () => _showDetail(
                  context,
                  'Connection',
                  widget.product.specValue('Connector'),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                'YAW ${_yaw.round()}° · PITCH ${_pitch.round()}° · ${_autoSpin ? 'AUTO-SPIN' : 'SPIN PAUSED'}',
                key: const ValueKey('viewer-hud'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 9,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 14,
              child: Text(
                'DRAG TO ROTATE',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showDetail(BuildContext context, String title, String body) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
}

class _Hotspot extends StatelessWidget {
  const _Hotspot({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.background.withValues(alpha: 0.88),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.orange, size: 14),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ),
  );
}
