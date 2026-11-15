import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DevPreviewFrame extends StatefulWidget {
  const DevPreviewFrame({required this.child, super.key});

  final Widget child;

  @override
  State<DevPreviewFrame> createState() => _DevPreviewFrameState();
}

class _DevPreviewFrameState extends State<DevPreviewFrame> {
  Timer? _resetTimer;
  bool _updated = false;

  @override
  void reassemble() {
    super.reassemble();
    _resetTimer?.cancel();
    setState(() => _updated = true);
    _resetTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _updated = false);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !kDebugMode) return widget.child;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(404.0, constraints.maxWidth - 24);
        final height = math.min(884.0, constraints.maxHeight - 24);
        return ColoredBox(
          color: const Color(0xFF090A0D),
          child: Center(
            child: Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF050506),
                borderRadius: BorderRadius.circular(39),
                border: Border.all(color: const Color(0xFF33353B)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x70000000),
                    blurRadius: 56,
                    offset: Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Column(
                  children: [
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          Text(
                            '9:41',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Row(
                              key: ValueKey(_updated),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _updated ? Icons.bolt_rounded : Icons.circle,
                                  color: _updated
                                      ? AppColors.cyan
                                      : AppColors.gold,
                                  size: _updated ? 12 : 6,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _updated ? 'UPDATED' : 'LIVE PREVIEW',
                                  style: TextStyle(
                                    color: _updated
                                        ? AppColors.cyan
                                        : AppColors.muted,
                                    fontSize: 7,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            Icons.wifi_rounded,
                            size: 11,
                            color: AppColors.text,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.battery_5_bar_rounded,
                            size: 13,
                            color: AppColors.text,
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
