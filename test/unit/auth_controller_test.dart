import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_homepage/state/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpTestEnvironment();

  test('sign up stores the backend session and restores it after restart', () async {
    final controller = AuthController(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register');
        expect(
          jsonDecode(request.body),
          {
            'name': 'Demo Buyer',
            'email': 'buyer@example.com',
            'password': 'secret123',
          },
        );
        return authenticatedResponse(statusCode: 201);
      }),
    );
    addTearDown(controller.dispose);

    await controller.signUp(
      name: 'Demo Buyer',
      email: 'buyer@example.com',
      password: 'secret123',
    );

    expect(controller.isAuthenticated, isTrue);
    expect(controller.user?['email'], 'buyer@example.com');

    final restored = AuthController();
    addTearDown(restored.dispose);
    await restored.hydrate();
    expect(restored.isAuthenticated, isTrue);
    expect(restored.accessToken, 'demo-access-token');
  });

  test('sign in surfaces backend errors without creating a session', () async {
    final controller = AuthController(
      client: MockClient(
        (_) async => httpResponse(
          {
            'success': false,
            'message': 'Invalid email or password',
            'data': null,
          },
          statusCode: 401,
        ),
      ),
    );
    addTearDown(controller.dispose);

    await expectLater(
      controller.signIn(email: 'buyer@example.com', password: 'wrong'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Invalid email or password',
        ),
      ),
    );
    expect(controller.isAuthenticated, isFalse);
  });
}

http.Response authenticatedResponse({int statusCode = 200}) => http.Response(
  jsonEncode({
    'success': true,
    'message': 'Authentication successful',
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
  statusCode,
);

http.Response httpResponse(Map<String, Object?> body, {int statusCode = 200}) =>
    http.Response(jsonEncode(body), statusCode);
