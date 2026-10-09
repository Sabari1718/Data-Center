import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/server_model.dart';

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ServerRepository(apiClient: apiClient);
});

class ServerRepository {
  final ApiClient apiClient;
  final List<ServerModel> _servers = List.from(MockDataStore.initialServers);

  ServerRepository({required this.apiClient});

  Future<List<ServerModel>> getServers({
    String? searchQuery,
    String? statusFilter,
    String? dataCenterFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = List<ServerModel>.from(_servers);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.hostname.toLowerCase().contains(q) ||
              s.ipAddress.contains(q) ||
              s.location.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null && statusFilter != 'All') {
      results = results.where((s) => s.status.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    if (dataCenterFilter != null && dataCenterFilter != 'All') {
      results = results.where((s) => s.dataCenterName == dataCenterFilter).toList();
    }

    return results;
  }

  Future<ServerModel?> getServerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _servers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ServerModel> updateServerStatus(String id, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _servers.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _servers[index].copyWith(status: newStatus);
      _servers[index] = updated;
      return updated;
    }
    throw Exception('Server not found');
  }

  Future<void> restartServer(String id) async {
    await updateServerStatus(id, 'running');
  }

  Future<void> stopServer(String id) async {
    await updateServerStatus(id, 'stopped');
  }

  Future<void> rebootServer(String id) async {
    await updateServerStatus(id, 'running');
  }

  Future<ServerModel> addServer(ServerModel model) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _servers.insert(0, model);
    return model;
  }
}
