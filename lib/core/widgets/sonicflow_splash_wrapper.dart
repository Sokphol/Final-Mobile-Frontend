import 'package:flutter/material.dart';

class SonicFlowSplashWrapper extends StatefulWidget {
  const SonicFlowSplashWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<SonicFlowSplashWrapper> createState() => _SonicFlowSplashWrapperState();
}

class _SonicFlowSplashWrapperState extends State<SonicFlowSplashWrapper>
    with SingleTickerProviderStateMixin {
  static const _background = Color(0xFF0B0C10);
  static const _orange = Color(0xFFD4AF37);
  static const _gold = Color(0xFFD4AF37);

  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      widget.child,
      AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isCompleted) return const SizedBox.shrink();

          final progress = _progress.value;
          return IgnorePointer(
            child: Opacity(
              opacity: 1 - progress,
              child: Transform.scale(
                scale: 1 - (progress * 0.14),
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: _background),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SonicFlowMark(orange: _orange, gold: _gold),
                        SizedBox(height: 18),
                        Text(
                          'SONICFLOW',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _SonicFlowMark extends StatelessWidget {
  const _SonicFlowMark({required this.orange, required this.gold});

  final Color orange;
  final Color gold;

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: gold, width: 1.5),
    ),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _EqualizerBar(height: 16, color: gold),
          _EqualizerBar(height: 28, color: orange),
          _EqualizerBar(height: 40, color: orange),
          _EqualizerBar(height: 28, color: orange),
          _EqualizerBar(height: 16, color: gold),
        ],
      ),
    ),
  );
}

class _EqualizerBar extends StatelessWidget {
  const _EqualizerBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    height: height,
    margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
