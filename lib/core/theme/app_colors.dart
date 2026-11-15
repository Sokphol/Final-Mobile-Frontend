import 'package:flutter/material.dart';

abstract final class AppColors {
  static bool _isDark = true;
  static Color _accent = const Color(0xFFD4AF37);

  static bool get isDark => _isDark;
  static Color get background =>
      _isDark ? const Color(0xFF0B0C10) : const Color(0xFFF5F5F7);
  static Color get surface =>
      _isDark ? const Color(0xFF16181F) : const Color(0xFFFFFFFF);
  static Color get elevated =>
      _isDark ? const Color(0xFF1D2028) : const Color(0xFFFFFFFF);
  static Color get orange => _isDark ? _accent : Colors.black;
  static set orange(Color value) => _accent = value;
  static Color get gold => _isDark ? const Color(0xFFD4AF37) : Colors.black;
  static Color get onAccent => _isDark ? Colors.black : Colors.white;
  static const cyan = Color(0xFF00DCEB);
  static Color get text => _isDark ? Colors.white : Colors.black;
  static Color get muted =>
      _isDark ? const Color(0xFF9BA1AE) : const Color(0xFF6E6E73);
  static Color get border =>
      _isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);
  static const success = Color(0xFF66D19E);

  static void setBrightness(bool isDark) {
    _isDark = isDark;
  }
}
