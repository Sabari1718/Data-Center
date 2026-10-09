import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/preferences_service.dart';
import '../datasources/mock_data_store.dart';
import '../models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final preferences = ref.watch(preferencesServiceProvider);
  return DashboardRepository(apiClient: apiClient, preferences: preferences);
});

class DashboardRepository {
  final ApiClient apiClient;
  final PreferencesService preferences;

  DashboardRepository({required this.apiClient, required this.preferences});

  bool hasLayoutConfigured() {
    return preferences.getHasDashboardLayout();
  }

  Future<void> setHasLayoutConfigured(bool value) async {
    await preferences.setHasDashboardLayout(value);
  }

  Future<DashboardModel> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // When backend ready:
    // final response = await apiClient.get(ApiEndpoints.dashboard);
    // return DashboardModel.fromJson(response.data);
    return MockDataStore.buildDashboard();
  }
}
