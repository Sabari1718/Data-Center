import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../domain/auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initial state; checkAuthStatus is called during startup
    _initAuthCheck();
    return AuthState.initial();
  }

  Future<void> _initAuthCheck() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = AuthState.unauthenticated();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final repo = ref.read(authRepositoryProvider);
    final saved = await repo.updateProfile(updatedUser);
    state = AuthState.authenticated(saved);
  }
}
