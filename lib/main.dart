import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/dev_preview_frame.dart';
import 'core/widgets/sonicflow_splash_wrapper.dart';
import 'features/home/storefront_page.dart';
import 'models/headphone.dart';
import 'services/catalog_api.dart';
import 'state/appearance_controller.dart';
import 'state/grocery_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppearanceController.instance.hydrate();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final isDark = AppearanceController.instance.isDark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? const Color(0xFF0B0C10)
          : const Color(0xFFF5F5F7),
      systemNavigationBarDividerColor: isDark
          ? const Color(0xFF16181E)
          : const Color(0xFFE5E5EA),
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    ),
  );

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final isTablet = logicalSize.shortestSide >= 600;
    await SystemChrome.setPreferredOrientations(
      isTablet
          ? DeviceOrientation.values
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  runApp(const GroceryApp(catalogLoader: fetchCatalog));
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key, this.catalogLoader});

  final Future<List<Headphone>> Function()? catalogLoader;

  @override
  Widget build(BuildContext context) => GroceryScope(
    state: GroceryState.instance,
    child: ListenableBuilder(
      listenable: AppearanceController.instance,
      builder: (context, _) {
        final appearance = AppearanceController.instance;
        final isDark = appearance.isDark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDark
                ? const Color(0xFF0B0C10)
                : const Color(0xFFF5F5F7),
            systemNavigationBarDividerColor: isDark
                ? const Color(0xFF16181E)
                : const Color(0xFFE5E5EA),
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SONICFLOW',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appearance.themeMode,
            home: SonicFlowSplashWrapper(
              child: DevPreviewFrame(
                child: StorefrontPage(catalogLoader: catalogLoader),
              ),
            ),
          ),
        );
      },
    ),
  );
}
