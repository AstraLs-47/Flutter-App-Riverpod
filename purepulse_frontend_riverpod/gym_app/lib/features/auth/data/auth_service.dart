// Project imports:
import '../../../core/models/user_model.dart';
import '../domain/user_role.dart';
import 'auth_repository.dart';

class AuthService {
  final AuthRepository _repo = AuthRepository();

  // Session data updated from real API responses
  static String currentUserName = 'User';
  static String currentUserEmail = 'user@example.com';

  // Onboarding data
  static String? selectedGoal;
  static String? activityLevel;
  static String? sex;
  static String? birthDate;
  static String? height;
  static String? weight;
  static String? goalWeight;

  Future<UserRole> login(String email, String password) async {
    final role = await _repo.signIn(email, password);
    // Refresh static fields from stored session
    final user = await _repo.getCurrentUser();
    if (user != null) {
      currentUserName = user.name;
      currentUserEmail = user.email;
    }
    return role;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _repo.signUp(
      name: name,
      email: email,
      password: password,
    );
    currentUserName = name;
    currentUserEmail = email;
    return result;
  }

  Future<void> logout() async {
    await _repo.signOut();
    currentUserName = 'User';
    currentUserEmail = 'user@example.com';
  }

  Future<void> deleteAccount() async {
    await _repo.deleteAccount();
    currentUserName = 'User';
    currentUserEmail = 'user@example.com';
  }

  Future<User?> getCurrentUser() async {
    final user = await _repo.getCurrentUser();
    if (user != null) {
      currentUserName = user.name;
      currentUserEmail = user.email;
    }
    return user;
  }

  Future<UserRole> getStoredRole() async {
    return _repo.getStoredRole();
  }

  Future<bool> isLoggedIn() async {
    return _repo.isLoggedIn();
  }

  Future<void> submitOnboarding() async {
    // Format birthdate from mm/dd/yyyy or ISO to yyyy-mm-dd
    String formattedBirthDate = '2000-01-01';

    if (birthDate != null && birthDate!.isNotEmpty) {
      if (birthDate!.contains('/')) {
        final parts = birthDate!.split('/');
        if (parts.length == 3) {
          final month = parts[0].padLeft(2, '0');
          final day = parts[1].padLeft(2, '0');
          final year = parts[2];
          formattedBirthDate = '$year-$month-$day';
        }
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate!)) {
        formattedBirthDate = birthDate!;
      } else {
        final parsed = DateTime.tryParse(birthDate!);
        if (parsed != null) {
          formattedBirthDate =
              '${parsed.year.toString().padLeft(4, '0')}-'
              '${parsed.month.toString().padLeft(2, '0')}-'
              '${parsed.day.toString().padLeft(2, '0')}';
        }
      }
    }

    final parsedHeight =
        double.tryParse((height ?? '').replaceAll(',', '.')) ?? 1.70;
    final parsedWeight =
        double.tryParse((weight ?? '').replaceAll(',', '.')) ?? 70.0;
    final parsedGoalWeight =
        double.tryParse((goalWeight ?? '').replaceAll(',', '.')) ?? 70.0;

    await _repo.onboard(
      goal: selectedGoal ?? 'Maintain Weight',
      activityLevel: activityLevel ?? 'Active',
      dateOfBirth: formattedBirthDate,
      currentWeight: parsedWeight,
      goalWeight: parsedGoalWeight,
      height: parsedHeight,
      gender: sex ?? 'Female',
    );
  }
}
