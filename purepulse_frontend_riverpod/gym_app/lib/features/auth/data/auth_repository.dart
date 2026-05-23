// Project imports:
import '../../../core/data/database_helper.dart';
import '../../../core/data/token_storage.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/domain/repositories/i_auth_repository.dart';
import '../domain/user_role.dart';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final DatabaseHelper _dbHelper;

  AuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
    DatabaseHelper? dbHelper,
  }) : _apiClient = apiClient ?? ApiClient(),
       _tokenStorage = tokenStorage ?? TokenStorage(),
       _dbHelper = dbHelper ?? DatabaseHelper();

  Future<UserRole> signIn(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      includeAuth: false,
    );

    final token = response['token'] as String;
    final userMap = response['user'] as Map<String, dynamic>;

    await _tokenStorage.saveToken(token);
    await _tokenStorage.saveUserSession(userMap);

    return _mapRole(userMap['role']);
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Split name into first and last name as expected by the backend
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : name;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
      includeAuth: false,
    );

    final token = response['token'] as String;
    final userMap = response['user'] as Map<String, dynamic>;

    await _tokenStorage.saveToken(token);
    await _tokenStorage.saveUserSession(userMap);

    return true;
  }

  Future<void> onboard({
    required String goal,
    required String activityLevel,
    required String dateOfBirth,
    required double currentWeight,
    required double goalWeight,
    required double height,
    required String gender,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.onboard,
      body: {
        'goal': goal,
        'activityLevel': activityLevel,
        'dateOfBirth': dateOfBirth,
        'currentWeight': currentWeight,
        'goalWeight': goalWeight,
        'height': height,
        'gender': gender,
      },
      includeAuth: true,
    );

    if (response != null && response is Map<String, dynamic>) {
      await _tokenStorage.saveUserSession({
        'id': response['id'],
        'email': response['email'],
        'firstName': response['firstName'],
        'lastName': response['lastName'],
        'role': response['role'],
      });
    }
  }

  Future<void> signOut() async {
    try {
      await _apiClient.post(ApiEndpoints.signout, includeAuth: true);
    } catch (_) {
      // Ignore API logout failures so user can still clear local session
    }
    await _tokenStorage.clearAll();
    await _dbHelper.clearAllCaches();
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete(ApiEndpoints.deleteAccount);
    await _tokenStorage.clearAll();
    await _dbHelper.clearAllCaches();
  }

  Future<User?> getCurrentUser() async {
    try {
      final userMap = await _apiClient.get(ApiEndpoints.profile);
      // Backend returns firstName, lastName. Let's merge them into name
      final name = '${userMap['firstName'] ?? ''} ${userMap['lastName'] ?? ''}'
          .trim();
      final user = User(
        id: userMap['id'].toString(),
        name: name.isEmpty ? 'User' : name,
        email: userMap['email'],
        bio: userMap['goal'] ?? '',
      );

      // Update local storage user session
      await _tokenStorage.saveUserSession({
        'id': userMap['id'],
        'email': userMap['email'],
        'firstName': userMap['firstName'],
        'lastName': userMap['lastName'],
        'role': userMap['role'],
      });

      return user;
    } catch (_) {
      // Fallback to local session cache
      final localSession = await _tokenStorage.getUserSession();
      if (localSession != null) {
        final name =
            '${localSession['firstName'] ?? ''} ${localSession['lastName'] ?? ''}'
                .trim();
        return User(
          id: localSession['id'].toString(),
          name: name.isEmpty ? 'User' : name,
          email: localSession['email'],
          bio: '',
        );
      }
      return null;
    }
  }

  Future<UserRole> getStoredRole() async {
    final session = await _tokenStorage.getUserSession();
    if (session == null) return UserRole.invalid;
    return _mapRole(session['role']);
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null;
  }

  UserRole _mapRole(String? roleStr) {
    if (roleStr == 'admin') return UserRole.admin;
    if (roleStr == 'user') return UserRole.user;
    return UserRole.invalid;
  }
}
