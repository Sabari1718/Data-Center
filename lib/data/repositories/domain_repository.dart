import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/domain_model.dart';

final domainRepositoryProvider = Provider<DomainRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DomainRepository(apiClient: apiClient);
});

class DomainRepository {
  final ApiClient apiClient;
  final List<DomainModel> _domains = [];
  final List<DomainExtensionModel> _extensions = [];
  final List<SubdomainModel> _subdomains = [];
  final List<String> _registrars = [];

  DomainRepository({required this.apiClient});

  List<DomainModel> get currentDomains => List.unmodifiable(_domains);
  List<DomainExtensionModel> get currentExtensions => List.unmodifiable(_extensions);
  List<SubdomainModel> get currentSubdomains => List.unmodifiable(_subdomains);
  List<String> get currentRegistrars => List.unmodifiable(_registrars);

  Future<List<DomainModel>> getDomains({
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final response = await apiClient.get(ApiEndpoints.domains);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => DomainModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _domains.clear();
      _domains.addAll(items);
    } catch (e) {
      log('Failed to fetch domains from API: $e');
      if (_domains.isEmpty) {
        _domains.addAll(MockDataStore.initialDomains);
      }
    }

    var results = List<DomainModel>.from(_domains);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((d) =>
              d.displayName.toLowerCase().contains(q) ||
              d.domainName.toLowerCase().contains(q) ||
              d.registrar.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null && statusFilter != 'All') {
      results = results.where((d) => d.status.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    return results;
  }

  Future<DomainModel?> getDomainById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.domains}/$id');
      final body = response.data;
      if (body is Map && body['data'] != null) {
        return DomainModel.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Failed to fetch domain $id from API: $e');
    }
    try {
      return _domains.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DomainExtensionModel>> getExtensions() async {
    try {
      final response = await apiClient.get(ApiEndpoints.domainExtensions);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => DomainExtensionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _extensions.clear();
      _extensions.addAll(items);
      return _extensions;
    } catch (e) {
      log('Failed to fetch domain extensions from API: $e');
      if (_extensions.isEmpty) {
        _extensions.addAll(const [
          DomainExtensionModel(id: 1, extension: '.com'),
          DomainExtensionModel(id: 2, extension: '.in'),
          DomainExtensionModel(id: 4, extension: '.info'),
          DomainExtensionModel(id: 3, extension: '.net'),
        ]);
      }
      return _extensions;
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
        } else if (item is Map && item['name'] != null) {
          _registrars.add(item['name'].toString());
        }
      }
    } catch (e) {
      log('Failed to fetch domain registrars from API: $e');
    }

    if (_registrars.isEmpty) {
      _registrars.addAll(const ['godaddy', 'namecheap', 'cloudflare', 'google domains']);
    }
    return _registrars;
  }

  Future<DomainModel> addDomain(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(ApiEndpoints.domains, data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final created = DomainModel.fromJson(body['data'] as Map<String, dynamic>);
        _domains.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to add domain via API: $e');
    }
    final model = DomainModel.fromJson(payload);
    _domains.insert(0, model);
    return model;
  }

  Future<DomainModel> updateDomain(String id, Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.put('${ApiEndpoints.domains}/$id', data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final updated = DomainModel.fromJson(body['data'] as Map<String, dynamic>);
        final idx = _domains.indexWhere((d) => d.id == id);
        if (idx != -1) {
          _domains[idx] = updated;
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update domain $id via API: $e');
    }
    final idx = _domains.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final current = _domains[idx];
      final updated = current.copyWith(
        domainName: payload['domain_name'] as String? ?? current.domainName,
        registrar: payload['domain_service'] as String? ?? current.registrar,
        domainService: payload['domain_service'] as String? ?? current.domainService,
        cost: double.tryParse(payload['cost']?.toString() ?? '0') ?? current.cost,
      );
      _domains[idx] = updated;
      return updated;
    }
    throw Exception('Domain not found');
  }

  Future<void> deleteDomain(String id) async {
    try {
      await apiClient.delete('${ApiEndpoints.domains}/$id');
      _domains.removeWhere((d) => d.id == id);
    } catch (e) {
      log('Failed to delete domain $id via API: $e');
      _domains.removeWhere((d) => d.id == id);
    }
  }

  Future<List<SubdomainModel>> getSubdomains() async {
    try {
      final response = await apiClient.get(ApiEndpoints.subdomains);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => SubdomainModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _subdomains.clear();
      _subdomains.addAll(items);
      return _subdomains;
    } catch (e) {
      log('Failed to fetch subdomains from API: $e');
      return _subdomains;
    }
  }

  Future<SubdomainModel> addSubdomain({
    required dynamic primaryDomainId,
    required String subdomainPrefix,
    required String url,
  }) async {
    final payload = {
      'primaryDomainId': primaryDomainId.toString(),
      'subdomainPrefix': subdomainPrefix,
      'url': url,
    };
    try {
      final response = await apiClient.post(ApiEndpoints.subdomains, data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final created = SubdomainModel.fromJson(body['data'] as Map<String, dynamic>);
        _subdomains.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to add subdomain via API: $e');
    }
    final fallback = SubdomainModel(
      id: DateTime.now().millisecondsSinceEpoch,
      primaryDomainId: int.tryParse(primaryDomainId.toString()),
      subdomainPrefix: subdomainPrefix,
      targetSubdomain: '$subdomainPrefix.domain.com',
      loginUrl: url,
    );
    _subdomains.insert(0, fallback);
    return fallback;
  }

  Future<SubdomainModel> updateSubdomain(
    dynamic id, {
    required dynamic primaryDomainId,
    required String subdomainPrefix,
    required String url,
  }) async {
    final payload = {
      'primaryDomainId': primaryDomainId is int ? primaryDomainId : (int.tryParse(primaryDomainId.toString()) ?? primaryDomainId),
      'subdomainPrefix': subdomainPrefix,
      'url': url,
    };
    try {
      final response = await apiClient.put('${ApiEndpoints.subdomains}/$id', data: payload);
      final body = response.data;
      if (body is Map && body['data'] != null) {
        final updated = SubdomainModel.fromJson(body['data'] as Map<String, dynamic>);
        final idx = _subdomains.indexWhere((s) => s.id.toString() == id.toString());
        if (idx != -1) {
          _subdomains[idx] = updated;
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update subdomain $id via API: $e');
    }
    final idx = _subdomains.indexWhere((s) => s.id.toString() == id.toString());
    if (idx != -1) {
      final current = _subdomains[idx];
      final updated = current.copyWith(
        primaryDomainId: int.tryParse(primaryDomainId.toString()),
        subdomainPrefix: subdomainPrefix,
        loginUrl: url,
      );
      _subdomains[idx] = updated;
      return updated;
    }
    throw Exception('Subdomain not found');
  }

  Future<void> deleteSubdomain(dynamic id) async {
    try {
      await apiClient.delete('${ApiEndpoints.subdomains}/$id');
      _subdomains.removeWhere((s) => s.id.toString() == id.toString());
    } catch (e) {
      log('Failed to delete subdomain $id via API: $e');
      _subdomains.removeWhere((s) => s.id.toString() == id.toString());
    }
  }

  Future<DomainModel> toggleAutoRenew(String id) async {
    final index = _domains.indexWhere((d) => d.id == id);
    if (index != -1) {
      final current = _domains[index];
      final updated = current.copyWith(autoRenew: !current.autoRenew);
      _domains[index] = updated;
      return updated;
    }
    throw Exception('Domain not found');
  }
}
