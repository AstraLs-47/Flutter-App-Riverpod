// Integration test: Login flow
//
// Tests the full login pipeline:
//   AuthNotifier.signIn()  →  state update  →  GoRouter redirect
//
// Because SignInScreen directly uses AuthService (a legacy seam), this
// integration test exercises the *intended* Riverpod-based flow by building a
// minimal app shell that uses AuthNotifier and GoRouter together, overriding
// the repository layer with mocks so no real HTTP calls are made.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/domain/repositories/i_auth_repository.dart';
import 'package:gym_app/core/models/user_model.dart';
import 'package:gym_app/core/providers/core_providers.dart';
import 'package:gym_app/features/auth/domain/auth_state.dart';
import 'package:gym_app/features/auth/domain/user_role.dart';
import 'package:gym_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockAuthRepository extends Mock implements IAuthRepository {}

// ---------------------------------------------------------------------------
// Test helper: minimal app that mirrors the real login → dashboard flow
// ---------------------------------------------------------------------------
class _LoginIntegrationApp extends ConsumerWidget {
  const _LoginIntegrationApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(routerConfig: router);
  }
}

// A minimal login form widget that goes through AuthNotifier (not AuthService)
class _TestLoginForm extends ConsumerStatefulWidget {
  const _TestLoginForm();

  @override
  ConsumerState<_TestLoginForm> createState() => _TestLoginFormState();
}

class _TestLoginFormState extends ConsumerState<_TestLoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(key: const Key('email'), controller: _emailCtrl),
          TextField(
            key: const Key('password'),
            controller: _passCtrl,
            obscureText: true,
          ),
          ElevatedButton(
            key: const Key('signInBtn'),
            onPressed: () async {
              final error = await ref
                  .read(authProvider.notifier)
                  .signIn(_emailCtrl.text, _passCtrl.text);
              if (error == null && context.mounted) {
                final role = ref.read(authProvider).role;
                if (role == UserRole.admin) {
                  context.goNamed('admin');
                } else {
                  context.goNamed('dashboard');
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------
GoRouter _buildRouter() => GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const _TestLoginForm(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (_, __) =>
              const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (_, __) =>
              const Scaffold(body: Text('Admin Home')),
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late MockAuthRepository mockAuthRepo;

  final testUser = User(id: '1', name: 'Test User', email: 'user@test.com');

  setUpAll(() {
    registerFallbackValue(UserRole.invalid);
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    // Default: not logged in
    when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);
  });

  ProviderContainer _makeContainer() {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget _buildApp(ProviderContainer container) {
    final router = _buildRouter();
    return UncontrolledProviderScope(
      container: container,
      child: _LoginIntegrationApp(router: router),
    );
  }

  group('Login flow integration', () {
    testWidgets('successful user login navigates to /dashboard',
        (tester) async {
      when(() => mockAuthRepo.signIn(any(), any()))
          .thenAnswer((_) async => UserRole.user);
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final container = _makeContainer();
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Fill in credentials
      await tester.enterText(find.byKey(const Key('email')), 'user@test.com');
      await tester.enterText(
          find.byKey(const Key('password')), 'password123');

      // Tap sign in
      await tester.tap(find.byKey(const Key('signInBtn')));
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('successful admin login navigates to /admin', (tester) async {
      when(() => mockAuthRepo.signIn(any(), any()))
          .thenAnswer((_) async => UserRole.admin);
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final container = _makeContainer();
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('email')), 'admin@test.com');
      await tester.enterText(
          find.byKey(const Key('password')), 'adminpass');

      await tester.tap(find.byKey(const Key('signInBtn')));
      await tester.pumpAndSettle();

      expect(find.text('Admin Home'), findsOneWidget);
    });

    testWidgets('failed login keeps user on login screen', (tester) async {
      when(() => mockAuthRepo.signIn(any(), any()))
          .thenThrow(Exception('Invalid credentials'));
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => null);

      final container = _makeContainer();
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('email')), 'bad@test.com');
      await tester.enterText(
          find.byKey(const Key('password')), 'wrongpass');

      await tester.tap(find.byKey(const Key('signInBtn')));
      await tester.pumpAndSettle();

      // Still on the login form — dashboard should NOT be visible
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('AuthNotifier state reflects authenticated user after sign-in',
        (tester) async {
      when(() => mockAuthRepo.signIn(any(), any()))
          .thenAnswer((_) async => UserRole.user);
      when(() => mockAuthRepo.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final container = _makeContainer();
      // Stub initial isLoggedIn check
      when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);

      await container.read(authProvider.notifier).signIn(
            'user@test.com',
            'password123',
          );

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.role, UserRole.user);
      expect(state.user?.email, 'user@test.com');
    });

    testWidgets('AuthState remains unauthenticated after failed sign-in',
        (tester) async {
      when(() => mockAuthRepo.signIn(any(), any()))
          .thenThrow(Exception('Wrong password'));

      final container = _makeContainer();

      await container.read(authProvider.notifier).signIn(
            'user@test.com',
            'wrongpass',
          );

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.error, isNotNull);
    });
  });
}
