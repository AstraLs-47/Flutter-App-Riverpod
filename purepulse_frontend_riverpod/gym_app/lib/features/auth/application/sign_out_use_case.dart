import '../../../core/domain/repositories/i_auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() {
    return _authRepository.signOut();
  }
}
