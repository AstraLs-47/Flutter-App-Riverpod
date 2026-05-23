// Project imports:
import '../../../../core/models/user_model.dart';
import 'user_role.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final UserRole role;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.user,
    this.role = UserRole.invalid,
    this.error,
  });

  factory AuthState.initial() => AuthState(isAuthenticated: false);

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    UserRole? role,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      role: role ?? this.role,
      error: error,
    );
  }
}
