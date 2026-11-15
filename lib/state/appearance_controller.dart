import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';

enum AppAppearanceMode { light, dark, system }

class AppearanceController extends ChangeNotifier with WidgetsBindingObserver {
  AppearanceController._() {
    WidgetsBinding.instance.addObserver(this);
    AppColors.setBrightness(isDark);
  }

  static final AppearanceController instance = AppearanceController._();
  static const storageKey = 'sonicflow.appearanceMode';

  AppAppearanceMode _mode = AppAppearanceMode.system;

  AppAppearanceMode get mode => _mode;
  ThemeMode get themeMode => switch (_mode) {
    AppAppearanceMode.light => ThemeMode.light,
    AppAppearanceMode.dark => ThemeMode.dark,
    AppAppearanceMode.system => ThemeMode.system,
  };
  bool get isDark => switch (_mode) {
    AppAppearanceMode.light => false,
    AppAppearanceMode.dark => true,
    AppAppearanceMode.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
  };

  Future<void> hydrate() async {
    final preferences = await SharedPreferences.getInstance();
    _mode = switch (preferences.getString(storageKey)) {
      'light' => AppAppearanceMode.light,
      'dark' => AppAppearanceMode.dark,
      _ => AppAppearanceMode.system,
    };
    AppColors.setBrightness(isDark);
    notifyListeners();
  }

  Future<void> select(AppAppearanceMode mode) async {
    _mode = mode;
    AppColors.setBrightness(isDark);
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, mode.name);
  }

  @override
  void didChangePlatformBrightness() {
    if (_mode != AppAppearanceMode.system) return;
    AppColors.setBrightness(isDark);
    notifyListeners();
  }
}
