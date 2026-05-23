import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/core/data/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockHttpClient mockClient;
  late MockTokenStorage mockTokenStorage;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockTokenStorage = MockTokenStorage();
    apiClient = ApiClient(
      client: mockClient,
      tokenStorage: mockTokenStorage,
      defaultTimeout: const Duration(seconds: 1),
      maxRetries: 2,
    );
  });

  group('ApiClient', () {
    test('should succeed on first attempt if 200 OK', () async {
      when(() => mockTokenStorage.getToken()).thenAnswer((_) async => 'fake_token');
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'data': 'ok'}), 200));

      final result = await apiClient.get('http://localhost/test');

      expect(result['data'], 'ok');
      verify(() => mockClient.get(any(), headers: any(named: 'headers'))).called(1);
    });

    test('should retry on 5xx errors and then succeed if later 200', () async {
      when(() => mockTokenStorage.getToken()).thenAnswer((_) async => 'fake_token');
      
      int count = 0;
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async {
        count++;
        if (count == 1) {
          return http.Response('Server Error', 500);
        }
        return http.Response(jsonEncode({'data': 'success'}), 200);
      });

      final result = await apiClient.get('http://localhost/test');

      expect(result['data'], 'success');
      expect(count, 2);
    });

    test('should call onUnauthorized on 401 response status', () async {
      bool unauthorizedCalled = false;
      apiClient = ApiClient(
        client: mockClient,
        tokenStorage: mockTokenStorage,
        defaultTimeout: const Duration(seconds: 1),
        maxRetries: 1,
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      when(() => mockTokenStorage.getToken()).thenAnswer((_) async => 'fake_token');
      when(() => mockTokenStorage.clearAll()).thenAnswer((_) async {});
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => apiClient.get('http://localhost/test'),
        throwsA(isA<ApiException>()),
      );

      // Give microtask/async loops time to run
      await Future.delayed(const Duration(milliseconds: 10));
      expect(unauthorizedCalled, true);
    });
  });
}
