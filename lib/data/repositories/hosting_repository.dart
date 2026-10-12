import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/domain_model.dart';
import '../models/hosting_model.dart';
import '../models/server_model.dart';

final hostingRepositoryProvider = Provider<HostingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HostingRepository(apiClient: apiClient);
});

class HostingRepository {
  final ApiClient apiClient;
  final List<HostingModel> _hostingList = List.from(MockDataStore.initialHosting);
  final List<HostingNewModel> _hostingNewList = [];
  final List<ServerHostingModel> _serverHostings = [];
  final List<ServerModel> _servers = [];
  final List<HostingTypeModel> _hostingTypes = [];
  final List<HostingDomainMappingModel> _mappings = [];
  final List<DomainModel> _domains = [];
  final List<String> _registrars = [];

  HostingRepository({required this.apiClient});

  List<HostingNewModel> get currentHostingNew => List.unmodifiable(_hostingNewList);
  List<ServerHostingModel> get currentServerHostings => List.unmodifiable(_serverHostings);
  List<ServerModel> get currentServers => List.unmodifiable(_servers);
  List<HostingTypeModel> get currentHostingTypes => List.unmodifiable(_hostingTypes);
  List<HostingDomainMappingModel> get currentMappings => List.unmodifiable(_mappings);
  List<DomainModel> get currentDomains => List.unmodifiable(_domains);

  Future<List<HostingNewModel>> getHostingNewList() async {
    try {
      final response = await apiClient.get(ApiEndpoints.hostingNew);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => HostingNewModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _hostingNewList.clear();
      _hostingNewList.addAll(items);
      return _hostingNewList;
    } catch (e) {
      log('Failed to fetch hosting-new from API: $e');
      return _hostingNewList;
    }
  }

  Future<HostingNewModel?> getHostingById(dynamic id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.hostingNew}/$id');
      final body = response.data;
      if (body is Map && body['data'] != null) {
        return HostingNewModel.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Failed to fetch hosting $id from API: $e');
    }
    try {
      return _hostingNewList.firstWhere((h) => h.id.toString() == id.toString());
    } catch (_) {
      return null;
    }
  }

  Future<HostingNewModel> createHostingNew(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(ApiEndpoints.hostingNew, data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final created = HostingNewModel.fromJson(body['data'] as Map<String, dynamic>);
        _hostingNewList.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to create hosting-new via API: $e');
    }
    final fallback = HostingNewModel.fromJson(payload);
    _hostingNewList.insert(0, fallback);
    return fallback;
  }

  Future<HostingNewModel> updateHostingNew(dynamic id, Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.put('${ApiEndpoints.hostingNew}/$id', data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final updated = HostingNewModel.fromJson(body['data'] as Map<String, dynamic>);
        final idx = _hostingNewList.indexWhere((h) => h.id.toString() == id.toString());
        if (idx != -1) {
          _hostingNewList[idx] = updated;
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update hosting-new $id via API: $e');
    }
    final idx = _hostingNewList.indexWhere((h) => h.id.toString() == id.toString());
    if (idx != -1) {
      final updated = HostingNewModel.fromJson({
        ..._hostingNewList[idx].toJson(),
        ...payload,
        'id': id,
      });
      _hostingNewList[idx] = updated;
      return updated;
    }
    throw Exception('Hosting not found');
  }

  Future<void> deleteHostingNew(dynamic id) async {
    try {
      await apiClient.delete('${ApiEndpoints.hostingNew}/$id');
      _hostingNewList.removeWhere((h) => h.id.toString() == id.toString());
    } catch (e) {
      log('Failed to delete hosting-new $id via API: $e');
      _hostingNewList.removeWhere((h) => h.id.toString() == id.toString());
    }
  }

  // --- Server Hostings (/api/hostings) ---
  Future<List<ServerHostingModel>> getServerHostings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.hostings);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => ServerHostingModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _serverHostings.clear();
      _serverHostings.addAll(items);
      return _serverHostings;
    } catch (e) {
      log('Failed to fetch hostings from API: $e');
      return _serverHostings;
    }
  }

  Future<List<ServerModel>> getServers() async {
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
      return _servers;
    } catch (e) {
      log('Failed to fetch servers for hosting: $e');
      return _servers;
    }
  }

  Future<ServerHostingModel> createServerHosting(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(ApiEndpoints.hostings, data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final created = ServerHostingModel.fromJson(body['data'] as Map<String, dynamic>);
        _serverHostings.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to create server hosting via API: $e');
    }
    final fallback = ServerHostingModel.fromJson(payload);
    _serverHostings.insert(0, fallback);
    return fallback;
  }

  Future<ServerHostingModel> updateServerHosting(dynamic id, Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.put('${ApiEndpoints.hostings}/$id', data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final updated = ServerHostingModel.fromJson(body['data'] as Map<String, dynamic>);
        final idx = _serverHostings.indexWhere((h) => h.id.toString() == id.toString());
        if (idx != -1) {
          _serverHostings[idx] = updated;
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update server hosting $id via API: $e');
    }
    final idx = _serverHostings.indexWhere((h) => h.id.toString() == id.toString());
    if (idx != -1) {
      final updated = ServerHostingModel.fromJson({
        ..._serverHostings[idx].toJson(),
        ...payload,
        'id': id,
      });
      _serverHostings[idx] = updated;
      return updated;
    }
    throw Exception('Server hosting not found');
  }

  Future<void> deleteServerHosting(dynamic id) async {
    try {
      await apiClient.delete('${ApiEndpoints.hostings}/$id');
      _serverHostings.removeWhere((h) => h.id.toString() == id.toString());
    } catch (e) {
      log('Failed to delete server hosting $id via API: $e');
      _serverHostings.removeWhere((h) => h.id.toString() == id.toString());
    }
  }

  Future<List<HostingTypeModel>> getHostingTypes() async {
    try {
      final response = await apiClient.get(ApiEndpoints.hostingTypes);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      }

      final items = rawList
          .map((item) => HostingTypeModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _hostingTypes.clear();
      _hostingTypes.addAll(items);
      return _hostingTypes;
    } catch (e) {
      log('Failed to fetch hosting types: $e');
      if (_hostingTypes.isEmpty) {
        _hostingTypes.addAll(const [
          HostingTypeModel(id: 4, hostingTypeName: 'sa'),
          HostingTypeModel(id: 1, hostingTypeName: 'vps'),
          HostingTypeModel(id: 2, hostingTypeName: 'shared'),
          HostingTypeModel(id: 3, hostingTypeName: 'dedicated'),
        ]);
      }
      return _hostingTypes;
    }
  }

  Future<List<String>> getDomainRegistrars() async {
    try {
      final response = await apiClient.get(ApiEndpoints.domainRegistrars);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      }

      _registrars.clear();
      for (final item in rawList) {
        if (item is String) {
          _registrars.add(item);
        } else if (item is Map && item['registrar_name'] != null) {
          _registrars.add(item['registrar_name'].toString());
        } else if (item is Map && item['name'] != null) {
          _registrars.add(item['name'].toString());
        }
      }
    } catch (e) {
      log('Failed to fetch registrars: $e');
    }
    if (_registrars.isEmpty) {
      _registrars.addAll(const ['data', 'godaddy', 'namecheap', 'cloudflare']);
    }
    return _registrars;
  }

  Future<List<DomainModel>> getDomains() async {
    try {
      final response = await apiClient.get(ApiEndpoints.domains);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      }

      final items = rawList
          .map((item) => DomainModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _domains.clear();
      _domains.addAll(items);
      return _domains;
    } catch (e) {
      log('Failed to fetch domains for hosting mapping: $e');
      return _domains;
    }
  }

  Future<List<HostingDomainMappingModel>> getHostingDomainMappings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.hostingDomainMappings);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => HostingDomainMappingModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _mappings.clear();
      _mappings.addAll(items);
      return _mappings;
    } catch (e) {
      log('Failed to fetch domain mappings: $e');
      return _mappings;
    }
  }

  Future<bool> createHostingDomainMapping(Map<String, dynamic> payload) async {
    try {
      final safePayload = {
        'hosting_id': int.tryParse(payload['hosting_id']?.toString() ?? '') ?? payload['hosting_id'],
        'domain_id': int.tryParse(payload['domain_id']?.toString() ?? '') ?? payload['domain_id'],
        if (payload['mapping_status'] != null) 'mapping_status': payload['mapping_status'],
      };
      final response = await apiClient.post(ApiEndpoints.hostingDomainMappings, data: safePayload);
      final body = response.data;
      if (body is Map && (body['success'] == true || body['data'] != null)) {
        await getHostingDomainMappings();
        return true;
      }
    } catch (e) {
      log('Failed to create hosting-domain mapping: $e');
    }
    _mappings.insert(0, HostingDomainMappingModel.fromJson(payload));
    return true;
  }

  Future<bool> updateHostingDomainMapping(dynamic id, Map<String, dynamic> payload) async {
    try {
      final safePayload = {
        'hosting_id': int.tryParse(payload['hosting_id']?.toString() ?? '') ?? payload['hosting_id'],
        'domain_id': int.tryParse(payload['domain_id']?.toString() ?? '') ?? payload['domain_id'],
        if (payload['mapping_status'] != null) 'mapping_status': payload['mapping_status'],
      };
      final response = await apiClient.put('${ApiEndpoints.hostingDomainMappings}/$id', data: safePayload);
      final body = response.data;
      if (body is Map && (body['success'] == true || body['data'] != null)) {
        await getHostingDomainMappings();
        return true;
      }
    } catch (e) {
      log('Failed to update hosting-domain mapping $id: $e');
    }
    final idx = _mappings.indexWhere((m) => m.id.toString() == id.toString());
    if (idx != -1) {
      _mappings[idx] = HostingDomainMappingModel.fromJson({
        ..._mappings[idx].toJson(),
        ...payload,
        'id': id,
      });
      return true;
    }
    return false;
  }

  Future<bool> deleteHostingDomainMapping(dynamic id) async {
    try {
      final response = await apiClient.delete('${ApiEndpoints.hostingDomainMappings}/$id');
      final body = response.data;
      _mappings.removeWhere((m) => m.id.toString() == id.toString());
      if (body is Map && body['success'] == true) {
        return true;
      }
      return true;
    } catch (e) {
      log('Failed to delete hosting-domain mapping $id: $e');
      _mappings.removeWhere((m) => m.id.toString() == id.toString());
      return false;
    }
  }

  Future<List<HostingModel>> getHostings({
    String? searchQuery,
    String? statusFilter,
  }) async {
    final hostNew = await getHostingNewList();
    if (hostNew.isNotEmpty) {
      return hostNew.map((h) {
        return HostingModel(
          id: h.id.toString(),
          serviceName: h.hostingName.isNotEmpty ? h.hostingName : 'Hosting ${h.id}',
          planName: h.hostingType.toUpperCase(),
          domain: h.serviceProvider,
          ipAddress: h.ipAddress,
          status: h.status.toLowerCase(),
          storageUsedGb: 10.0,
          storageTotalGb: 100.0,
          bandwidthUsedGb: 50.0,
          bandwidthTotalGb: 1000.0,
          sslActive: h.sslCertificate.contains('SSL'),
          phpVersion: h.phpVersion.isNotEmpty ? h.phpVersion : '8.2',
          expiryDate: DateTime.tryParse(h.expiryDate) ?? DateTime.now().add(const Duration(days: 365)),
          createdAt: h.createdAt ?? DateTime.now(),
        );
      }).toList();
    }
    return _hostingList;
  }

  Future<HostingModel> addHosting(HostingModel model) async {
    _hostingList.insert(0, model);
    return model;
  }
}
