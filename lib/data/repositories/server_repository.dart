import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/server_model.dart';

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ServerRepository(apiClient: apiClient);
});

class ServerRepository {
  final ApiClient apiClient;
  final List<ServerModel> _servers = [];
  final List<ServerNetworkConnectionModel> _networkConnections = [];

  ServerRepository({required this.apiClient});

  List<ServerModel> get currentServers => List.unmodifiable(_servers);
  List<ServerNetworkConnectionModel> get currentNetworkConnections =>
      List.unmodifiable(_networkConnections);

  Future<List<ServerModel>> getServers({
    String? searchQuery,
    String? statusFilter,
    String? dataCenterFilter,
  }) async {
    try {
      final response = await apiClient.get(ApiEndpoints.serverDetails);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => ServerModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _servers.clear();
      _servers.addAll(items);
    } catch (e) {
      log('Failed to fetch servers from API: $e');
      if (_servers.isEmpty) {
        _servers.addAll(MockDataStore.initialServers);
      }
    }

    var results = List<ServerModel>.from(_servers);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.hostname.toLowerCase().contains(q) ||
              s.ipAddress.contains(q) ||
              s.location.toLowerCase().contains(q) ||
              s.dataCenterName.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null && statusFilter != 'All') {
      results = results
          .where((s) => s.status.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }

    if (dataCenterFilter != null && dataCenterFilter != 'All') {
      results = results.where((s) => s.dataCenterName == dataCenterFilter).toList();
    }

    return results;
  }

  Future<ServerModel?> getServerById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.serverDetails}/$id');
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        return ServerModel.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Failed to fetch server by id from API: $e');
    }
    try {
      return _servers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ServerModel> addServer(ServerModel model) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.serverDetails,
        data: model.toApiJson(),
      );
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final created = ServerModel.fromJson(body['data'] as Map<String, dynamic>);
        _servers.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to save server on API: $e');
      rethrow;
    }
    _servers.insert(0, model);
    return model;
  }

  Future<ServerModel> updateServer(ServerModel model) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.serverDetails}/${model.id}',
        data: model.toApiJson(),
      );
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final updated = ServerModel.fromJson(body['data'] as Map<String, dynamic>);
        final index = _servers.indexWhere((s) => s.id == model.id);
        if (index != -1) {
          _servers[index] = updated;
        } else {
          _servers.add(updated);
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update server on API: $e');
      rethrow;
    }
    final index = _servers.indexWhere((s) => s.id == model.id);
    if (index != -1) {
      _servers[index] = model;
    } else {
      _servers.add(model);
    }
    return model;
  }

  Future<void> deleteServer(String id) async {
    try {
      await apiClient.delete('${ApiEndpoints.serverDetails}/$id');
      _servers.removeWhere((s) => s.id == id);
    } catch (e) {
      log('Failed to delete server from API: $e');
      _servers.removeWhere((s) => s.id == id);
    }
  }

  Future<ServerModel> updateServerStatus(String id, String newStatus) async {
    try {
      await apiClient.put(
        '${ApiEndpoints.serverDetails}/$id',
        data: {'server_status': newStatus},
      );
    } catch (e) {
      log('Failed to update server status on API: $e');
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _servers[index].copyWith(status: newStatus);
      _servers[index] = updated;
      return updated;
    }
    throw Exception('Server not found');
  }

  Future<void> restartServer(String id) async {
    await updateServerStatus(id, 'Active');
  }

  Future<void> stopServer(String id) async {
    await updateServerStatus(id, 'Stopped');
  }

  Future<void> rebootServer(String id) async {
    await updateServerStatus(id, 'Active');
  }

  // Network Connections API
  Future<List<ServerNetworkConnectionModel>> getNetworkConnections() async {
    try {
      final response = await apiClient.get(ApiEndpoints.serverNetworkConnections);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) =>
              ServerNetworkConnectionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _networkConnections.clear();
      _networkConnections.addAll(items);
    } catch (e) {
      log('Failed to fetch network connections from API: $e');
    }
    return List.unmodifiable(_networkConnections);
  }

  Future<void> saveNetworkConnection(ServerNetworkConnectionModel conn) async {
    try {
      await apiClient.post(
        ApiEndpoints.serverNetworkConnections,
        data: conn.toApiJson(),
      );
      _networkConnections.insert(0, conn);
    } catch (e) {
      log('Failed to save network connection to API: $e');
      _networkConnections.insert(0, conn);
      rethrow;
    }
  }
}
