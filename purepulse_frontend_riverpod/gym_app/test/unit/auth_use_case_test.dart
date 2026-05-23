import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_auth_repository.dart';
import 'package:gym_app/features/auth/application/sign_in_use_case.dart';
import 'package:gym_app/features/auth/application/sign_up_use_case.dart';
import 'package:gym_app/features/auth/application/sign_out_use_case.dart';
import 'package:gym_app/features/auth/domain/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late SignOutUseCase signOutUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockAuthRepository);
    signUpUseCase = SignUpUseCase(mockAuthRepository);
    signOutUseCase = SignOutUseCase(mockAuthRepository);
  });

  group('SignInUseCase', () {
    test('should return UserRole admin when repository sign in succeeds', () async {
      when(() => mockAuthRepository.signIn('admin@example.com', 'password123'))
          .thenAnswer((_) async => UserRole.admin);

      final result = await signInUseCase.call('admin@example.com', 'password123');

      expect(result, UserRole.admin);
      verify(() => mockAuthRepository.signIn('admin@example.com', 'password123')).called(1);
    });
  });

  group('SignUpUseCase', () {
    test('should return true when repository sign up succeeds', () async {
      when(() => mockAuthRepository.signUp(
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
          )).thenAnswer((_) async => true);

      final result = await signUpUseCase.call(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(result, true);
      verify(() => mockAuthRepository.signUp(
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
          )).called(1);
    });
  });

  group('SignOutUseCase', () {
    test('should complete successfully when repository sign out succeeds', () async {
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      await signOutUseCase.call();

      verify(() => mockAuthRepository.signOut()).called(1);
    });
  });
}
