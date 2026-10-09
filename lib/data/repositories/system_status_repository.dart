import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/system_status_model.dart';

final systemStatusRepositoryProvider = Provider<SystemStatusRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SystemStatusRepository(apiClient: apiClient);
});

class SystemStatusRepository {
  final ApiClient apiClient;

  SystemStatusRepository({required this.apiClient});

  Future<List<SystemStatusModel>> getSystemStatus() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.from(MockDataStore.initialSystemStatus);
  }
}
