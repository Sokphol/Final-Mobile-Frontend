import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/features/home/storefront_page.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  testWidgets(
    'storefront lays out without overflow at phone, tablet, and desktop sizes',
    (tester) async {
      const viewports = <Size>[
        Size(320, 568),
        Size(402, 874),
        Size(1024, 1366),
        Size(1920, 1080),
      ];
      addTearDown(tester.resetViewport);

      for (final viewport in viewports) {
        tester.setViewport(viewport);
        await tester.pumpWidget(const MaterialApp(home: StorefrontPage()));
        await tester.pumpAndSettle();
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: exception is FlutterError
              ? exception.toStringDeep()
              : 'Unexpected Flutter exception at $viewport',
        );
        expect(find.text('SONICFLOW'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );
}
