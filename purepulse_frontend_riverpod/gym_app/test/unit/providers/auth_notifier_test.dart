import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_auth_repository.dart';
import 'package:gym_app/core/providers/core_providers.dart';
import 'package:gym_app/features/auth/domain/auth_state.dart';
import 'package:gym_app/features/auth/domain/user_role.dart';
import 'package:gym_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_app/features/auth/application/sign_in_use_case.dart';
import 'package:gym_app/features/auth/application/check_auth_status_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier', () {
    test('initial state should be initial/loading-check', () async {
      when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => false);

      final container = makeContainer();
      final authState = container.read(authProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.user, null);
      expect(authState.role, UserRole.invalid);
    });

    test('sign in updates state with user and role on success', () async {
      when(() => mockAuthRepository.isLoggedIn()).thenAnswer((_) async => false);
      when(() => mockAuthRepository.signIn(any(), any())).thenAnswer((_) async => UserRole.user);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      final container = makeContainer();
      final notifier = container.read(authProvider.notifier);

      await notifier.signIn('user@example.com', 'password123');

      final finalState = container.read(authProvider);
      expect(finalState.isAuthenticated, true);
      expect(finalState.role, UserRole.user);
    });
  });
}
