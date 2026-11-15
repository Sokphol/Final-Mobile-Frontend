import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/core/theme/app_colors.dart';
import 'package:flutter_homepage/core/theme/app_theme.dart';
import 'package:flutter_homepage/screens/appearance_settings_screen.dart';
import 'package:flutter_homepage/state/appearance_controller.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();
  setUp(() async {
    await AppearanceController.instance.select(AppAppearanceMode.system);
  });

  testWidgets('appearance controls switch modes and update live specimen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(780, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AppearanceSettingsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(
      find.text('The quick brown fox jumps over the lazy dog'),
      findsOneWidget,
    );
    expect(find.text('Drop your font here'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(3));

    await tester.tap(find.text('Dark').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Theme && widget.data.brightness == Brightness.dark,
      ),
      findsWidgets,
    );

    await tester.tap(find.text('Light').first);
    await tester.pumpAndSettle();
    expect(AppearanceController.instance.mode, AppAppearanceMode.light);
    expect(AppearanceController.instance.themeMode, ThemeMode.light);
    expect(AppColors.background, const Color(0xFFF5F5F7));
    expect(AppColors.surface, Colors.white);
    expect(AppColors.text, Colors.black);
    expect(AppColors.onAccent, Colors.white);
    expect(AppTheme.light.colorScheme.primary, Colors.black);
    expect(AppTheme.light.colorScheme.onPrimary, Colors.white);
    expect(
      AppTheme.light.elevatedButtonTheme.style?.foregroundColor?.resolve({}),
      Colors.white,
    );
    expect(
      AppTheme.light.elevatedButtonTheme.style?.backgroundColor?.resolve({}),
      Colors.black,
    );
    expect(
      AppTheme.light.outlinedButtonTheme.style?.minimumSize?.resolve({}),
      const Size(48, 44),
    );

    final editableText = find.byType(TextField);
    await tester.enterText(editableText, 'My custom type sample');
    await tester.pump();
    expect(find.text('My custom type sample'), findsOneWidget);
  });

  testWidgets('appearance screen fits a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AppearanceSettingsScreen()),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Live preview'), findsOneWidget);
  });
}
