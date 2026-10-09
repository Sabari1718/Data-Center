import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/hosting_model.dart';

final hostingRepositoryProvider = Provider<HostingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HostingRepository(apiClient: apiClient);
});

class HostingRepository {
  final ApiClient apiClient;
  final List<HostingModel> _hostingList = List.from(MockDataStore.initialHosting);

  HostingRepository({required this.apiClient});

  Future<List<HostingModel>> getHostings({
    String? searchQuery,
    String? statusFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    var results = List<HostingModel>.from(_hostingList);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((h) =>
              h.serviceName.toLowerCase().contains(q) ||
              h.domain.toLowerCase().contains(q) ||
              h.planName.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null && statusFilter != 'All') {
      results = results.where((h) => h.status.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    return results;
  }

  Future<HostingModel> addHosting(HostingModel model) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _hostingList.insert(0, model);
    return model;
  }
}
