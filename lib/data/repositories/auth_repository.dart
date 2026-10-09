import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_failure.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../datasources/mock_data_store.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final prefs = ref.watch(preferencesServiceProvider);
  return AuthRepository(
    apiClient: apiClient,
    secureStorage: secureStorage,
    preferences: prefs,
  );
});

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final PreferencesService preferences;

  AuthRepository({
    required this.apiClient,
    required this.secureStorage,
    required this.preferences,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Artificial latency for realistic feel
    await Future.delayed(const Duration(milliseconds: 700));

    // When backend API endpoints are ready, replace with:
    // final response = await apiClient.post(ApiEndpoints.login, data: {'email': email, 'password': password});
    // final token = response.data['token'];

    if (email.trim().toLowerCase() == 'invalid@datacenter.io') {
      throw const AuthFailure('Invalid email or password. Please try again.');
    }

    // Mock successful authentication
    const fakeToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.datacenter_mock_jwt_token_2026';
    await secureStorage.saveToken(fakeToken);

    final user = MockDataStore.defaultUser.copyWith(
      email: email,
      name: email.contains('@') ? email.split('@').first.replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase()) : 'Johit',
      lastLoginAt: DateTime.now(),
    );

    await preferences.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    await secureStorage.clearAuthTokens();
    await preferences.remove(AppConstants.userDataKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final rawUser = preferences.getString(AppConstants.userDataKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
        return UserModel.fromJson(decoded);
      } catch (_) {
        return MockDataStore.defaultUser;
      }
    }
    return MockDataStore.defaultUser;
  }

  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await preferences.setString(AppConstants.userDataKey, jsonEncode(updatedUser.toJson()));
    return updatedUser;
  }
}
