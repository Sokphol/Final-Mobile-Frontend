import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';

class ThemeAccentController extends ChangeNotifier {
  static const storageKey = 'sonicflow.themeAccent';
  static const orange = Color(0xFFD4AF37);
  static const champagne = Color(0xFF00DCEB);

  Color accent = orange;

  Future<void> hydrate() async {
    final preferences = await SharedPreferences.getInstance();
    accent = switch (preferences.getString(storageKey)) {
      'cyan' || 'champagne' => champagne,
      _ => orange,
    };
    AppColors.orange = accent;
    notifyListeners();
  }

  Future<void> select(Color value) async {
    if (value != orange && value != champagne) {
      throw ArgumentError.value(value, 'value', 'Unsupported accent color');
    }
    accent = value;
    AppColors.orange = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      storageKey,
      value == champagne ? 'cyan' : 'gold',
    );
  }
}
