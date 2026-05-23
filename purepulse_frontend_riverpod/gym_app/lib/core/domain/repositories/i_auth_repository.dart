import '../../../core/models/user_model.dart';
import '../../../features/auth/domain/user_role.dart';

/// Contract that the Infrastructure layer's [AuthRepository] must fulfil.
abstract interface class IAuthRepository {
  Future<UserRole> signIn(String email, String password);
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> onboard({
    required String goal,
    required String activityLevel,
    required String dateOfBirth,
    required double currentWeight,
    required double goalWeight,
    required double height,
    required String gender,
  });
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<User?> getCurrentUser();
  Future<UserRole> getStoredRole();
  Future<bool> isLoggedIn();
}
