// Project imports:
import '../../../core/models/user_model.dart';
import '../../auth/data/auth_service.dart';

class ProfileService {
  final AuthService _auth = AuthService();

  Future<User?> fetchProfile() async {
    return _auth.getCurrentUser();
  }

  Future<void> updateProfile(User user) async {
    // Placeholder — extend when backend exposes a PUT /auth/profile endpoint
    AuthService.currentUserName = user.name;
    AuthService.currentUserEmail = user.email;
  }
}
