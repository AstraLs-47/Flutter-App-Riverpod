import '../../../core/domain/repositories/i_auth_repository.dart';
import '../domain/user_role.dart';

class CheckAuthStatusUseCase {
  final IAuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  Future<bool> isLoggedIn() {
    return _authRepository.isLoggedIn();
  }

  Future<UserRole> getStoredRole() {
    return _authRepository.getStoredRole();
  }
}
