import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
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
    int? captchaImageId,
  }) async {
    final Map<String, dynamic> requestData = {
      'email': email.trim(),
      'password': password,
    };
    if (captchaImageId != null) {
      requestData['captcha_image_id'] = captchaImageId;
    }

    final response = await apiClient.post(
      ApiEndpoints.login,
      data: requestData,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const AuthFailure('Invalid response format received from server.');
    }

    if (data['captcha_required'] == true) {
      throw CaptchaRequiredException(
        data['message'] ?? 'Captcha verification required',
        captchaImage: data['captcha_image'] is Map ? data['captcha_image'] : null,
      );
    }

    // Check backend explicit failure message
    if (data['result'] != null &&
        data['result'].toString().toLowerCase() == 'failure') {
      final msg = (data['message'] ?? 'Login failed. Please verify your credentials.').toString();
      if (msg.toLowerCase().contains('captcha') || msg.toLowerCase().contains('verification')) {
        throw CaptchaRequiredException(msg);
      }
      throw AuthFailure(msg);
    }

    final token = (data['token'] ??
            data['accessToken'] ??
            data['access_token'] ??
            (data['data'] is Map ? data['data']['token'] : null)) as String?;

    if (token == null || token.isEmpty) {
      final msg = data['message'] ?? 'Login failed. No authentication token received.';
      throw AuthFailure(msg.toString());
    }

    // Save token to secure storage
    await secureStorage.saveToken(token);

    // Save optional refresh token if provided
    final refreshToken = data['refreshToken'] ?? data['refresh_token'];
    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      await secureStorage.saveRefreshToken(refreshToken.toString());
    }

    // Parse user object from response
    final userJson = data['user'] ?? (data['data'] is Map ? data['data']['user'] : null);
    UserModel user;
    if (userJson is Map<String, dynamic>) {
      user = UserModel.fromJson(userJson).copyWith(
        lastLoginAt: DateTime.now(),
      );
    } else {
      user = UserModel(
        id: (data['id'] ?? '1').toString(),
        name: data['name'] ?? email.split('@').first,
        email: email,
        lastLoginAt: DateTime.now(),
      );
    }

    // Persist user data in preferences
    await preferences.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    await secureStorage.clearAuthTokens();
    await preferences.remove(AppConstants.userDataKey);
  }

  Future<List<Map<String, dynamic>>> getCaptchaCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.captchaCategories);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (_) {}
    return [];
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
