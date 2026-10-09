import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesService(prefs);
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);

  // Quick helper methods
  String getThemeMode() => _prefs.getString(AppConstants.themeModeKey) ?? 'system';
  Future<bool> setThemeMode(String mode) => _prefs.setString(AppConstants.themeModeKey, mode);

  bool getHasDashboardLayout() => _prefs.getBool(AppConstants.dashboardLayoutKey) ?? false;
  Future<bool> setHasDashboardLayout(bool hasLayout) =>
      _prefs.setBool(AppConstants.dashboardLayoutKey, hasLayout);

  String getApiBaseUrl() =>
      _prefs.getString(AppConstants.apiBaseUrlKey) ?? AppConstants.defaultBaseUrl;
  Future<bool> setApiBaseUrl(String url) =>
      _prefs.setString(AppConstants.apiBaseUrlKey, url);
}
