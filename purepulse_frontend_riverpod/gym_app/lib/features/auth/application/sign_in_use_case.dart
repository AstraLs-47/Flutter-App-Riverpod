import '../../../core/domain/repositories/i_auth_repository.dart';
import '../domain/user_role.dart';

class SignInUseCase {
  final IAuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<UserRole> call(String email, String password) {
    return _authRepository.signIn(email, password);
  }
}
