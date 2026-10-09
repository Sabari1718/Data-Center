import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/activity_log_model.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ActivityRepository(apiClient: apiClient);
});

class ActivityRepository {
  final ApiClient apiClient;
  final List<ActivityLogModel> _activities = List.from(MockDataStore.initialActivities);

  ActivityRepository({required this.apiClient});

  Future<List<ActivityLogModel>> getActivities({String? categoryFilter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<ActivityLogModel>.from(_activities);
    if (categoryFilter != null && categoryFilter != 'All') {
      results = results
          .where((a) => a.category.toLowerCase() == categoryFilter.toLowerCase())
          .toList();
    }
    return results;
  }

  Future<void> addActivity(ActivityLogModel log) async {
    _activities.insert(0, log);
  }
}
