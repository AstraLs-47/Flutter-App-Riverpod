import '../../../core/domain/repositories/i_auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<bool> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _authRepository.signUp(
      name: name,
      email: email,
      password: password,
    );
  }
}
