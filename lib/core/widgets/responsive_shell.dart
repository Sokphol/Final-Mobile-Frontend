import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({required this.child, this.maxWidth = 1440, super.key});

  final Widget child;
  final double maxWidth;

  static bool isDesktop(double width) => width > 1080;
  static bool isTablet(double width) => width >= 650 && width <= 1080;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
