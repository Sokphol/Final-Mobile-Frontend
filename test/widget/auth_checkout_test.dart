import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/features/auth/auth_dialog.dart';
import 'package:flutter_homepage/state/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  testWidgets('customer can create an account before checkout', (tester) async {
    final auth = AuthController(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register');
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Registration successful',
            'data': {
              'access_token': 'demo-access-token',
              'refresh_token': 'demo-refresh-token',
              'user': {
                'id': 42,
                'name': 'Demo Buyer',
                'email': 'buyer@example.com',
                'role': 'customer',
              },
            },
          }),
          201,
        );
      }),
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AuthDialog.show(context, auth),
              child: const Text('Continue to checkout'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Continue to checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Demo Buyer');
    await tester.enterText(find.byType(TextFormField).at(1), 'buyer@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(auth.isAuthenticated, isTrue);
    expect(find.text('Create your account'), findsNothing);
  });
}
