// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/auth_service.dart';
import '../../domain/auth_state.dart';
import '../../domain/user_role.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => checkAuthStatus());
    return AuthState.initial();
  }

  Future<void> checkAuthStatus() async {
    final checkAuthStatusUseCase = ref.read(checkAuthStatusUseCaseProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final loggedIn = await checkAuthStatusUseCase.isLoggedIn();
    if (loggedIn) {
      final user = await authRepo.getCurrentUser();
      final role = await checkAuthStatusUseCase.getStoredRole();
      if (user != null) {
        state = AuthState(isAuthenticated: true, user: user, role: role);
      } else {
        state = AuthState.initial();
      }
    } else {
      state = AuthState.initial();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final signInUseCase = ref.read(signInUseCaseProvider);
      final authRepo = ref.read(authRepositoryProvider);
      final role = await signInUseCase.call(email, password);
      final user = await authRepo.getCurrentUser();
      state = AuthState(isAuthenticated: true, user: user, role: role);
      return null; // Return null on success
    } catch (e) {
      final errorMsg = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '');
      state = state.copyWith(error: errorMsg);
      return errorMsg;
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final signUpUseCase = ref.read(signUpUseCaseProvider);
      final authRepo = ref.read(authRepositoryProvider);
      await signUpUseCase.call(name: name, email: email, password: password);
      final user = await authRepo.getCurrentUser();
      final role = await authRepo.getStoredRole();
      state = AuthState(isAuthenticated: true, user: user, role: role);
      return null;
    } catch (e) {
      final errorMsg = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '');
      state = state.copyWith(error: errorMsg);
      return errorMsg;
    }
  }

  Future<void> signOut() async {
    final signOutUseCase = ref.read(signOutUseCaseProvider);
    await signOutUseCase.call();
    AuthService.currentUserName = 'User';
    AuthService.currentUserEmail = 'user@example.com';
    state = AuthState.initial();
  }

  Future<void> deleteAccount() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.deleteAccount();
    AuthService.currentUserName = 'User';
    AuthService.currentUserEmail = 'user@example.com';
    state = AuthState.initial();
  }
}

// Provider Definitions
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authProvider).role;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
