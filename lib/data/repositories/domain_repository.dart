import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/domain_model.dart';

final domainRepositoryProvider = Provider<DomainRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DomainRepository(apiClient: apiClient);
});

class DomainRepository {
  final ApiClient apiClient;
  final List<DomainModel> _domains = List.from(MockDataStore.initialDomains);

  DomainRepository({required this.apiClient});

  Future<List<DomainModel>> getDomains({
    String? searchQuery,
    String? statusFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    var results = List<DomainModel>.from(_domains);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((d) =>
              d.domainName.toLowerCase().contains(q) ||
              d.registrar.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null && statusFilter != 'All') {
      results = results.where((d) => d.status.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    return results;
  }

  Future<DomainModel> toggleAutoRenew(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _domains.indexWhere((d) => d.id == id);
    if (index != -1) {
      final current = _domains[index];
      final updated = current.copyWith(autoRenew: !current.autoRenew);
      _domains[index] = updated;
      return updated;
    }
    throw Exception('Domain not found');
  }

  Future<DomainModel> addDomain(DomainModel model) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _domains.insert(0, model);
    return model;
  }
}
