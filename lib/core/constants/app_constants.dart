class AppConstants {
  static const String appName = 'VA Data Center';
  static const String appVersion = '1.0.0';
  static const String defaultUserName = 'lohit';
  static const String defaultUserEmail = 'yudeshprasath@gmail.com';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'app_theme_mode';
  static const String dashboardLayoutKey = 'dashboard_has_layout';
  static const String apiBaseUrlKey = 'api_base_url';

  // API defaults
  static const String defaultBaseUrl = 'https://datacenter.jobes24x7.com/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
