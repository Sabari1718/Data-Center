import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/data_center_model.dart';

final dataCenterRepositoryProvider = Provider<DataCenterRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DataCenterRepository(apiClient: apiClient);
});

class DataCenterRepository {
  final ApiClient apiClient;
  List<DataCenterModel> _cachedDataCenters = [];

  DataCenterRepository({required this.apiClient});

  List<DataCenterModel> get currentDataCenters => List.unmodifiable(_cachedDataCenters);

  Future<List<DataCenterModel>> getDataCenters({
    String? searchQuery,
    String? regionFilter,
  }) async {
    try {
      final response = await apiClient.get(ApiEndpoints.dataCenters);
      final body = response.data;
      List<dynamic> rawList = [];
      if (body is Map && body['data'] is List) {
        rawList = body['data'] as List;
      } else if (body is List) {
        rawList = body;
      }

      final items = rawList
          .map((item) => DataCenterModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedDataCenters = items;
    } catch (e) {
      log('Failed to fetch data centers from API: $e');
      if (_cachedDataCenters.isEmpty) {
        _cachedDataCenters = List.from(MockDataStore.initialDataCenters);
      }
    }

    var results = List<DataCenterModel>.from(_cachedDataCenters);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((dc) =>
              dc.name.toLowerCase().contains(q) ||
              dc.code.toLowerCase().contains(q) ||
              dc.city.toLowerCase().contains(q) ||
              dc.country.toLowerCase().contains(q) ||
              (dc.pincode != null && dc.pincode!.contains(q)))
          .toList();
    }

    if (regionFilter != null && regionFilter != 'All') {
      results = results.where((dc) => dc.region == regionFilter).toList();
    }

    return results;
  }

  Future<DataCenterModel?> getDataCenterById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.dataCenters}/$id');
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        return DataCenterModel.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Failed to fetch data center by id $id: $e');
    }
    try {
      return _cachedDataCenters.firstWhere((dc) => dc.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DataCenterModel> addDataCenter(DataCenterModel dataCenter) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.dataCenters,
        data: dataCenter.toApiJson(),
      );
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final created = DataCenterModel.fromJson(body['data'] as Map<String, dynamic>);
        _cachedDataCenters.insert(0, created);
        return created;
      }
    } catch (e) {
      log('Failed to create data center on API: $e');
      rethrow;
    }
    _cachedDataCenters.insert(0, dataCenter);
    return dataCenter;
  }

  Future<DataCenterModel> updateDataCenter(DataCenterModel dataCenter) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.dataCenters}/${dataCenter.id}',
        data: dataCenter.toApiJson(),
      );
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final updated = DataCenterModel.fromJson(body['data'] as Map<String, dynamic>);
        final index = _cachedDataCenters.indexWhere((dc) => dc.id == dataCenter.id);
        if (index != -1) {
          _cachedDataCenters[index] = updated;
        } else {
          _cachedDataCenters.insert(0, updated);
        }
        return updated;
      }
    } catch (e) {
      log('Failed to update data center on API: $e');
      rethrow;
    }
    final index = _cachedDataCenters.indexWhere((dc) => dc.id == dataCenter.id);
    if (index != -1) {
      _cachedDataCenters[index] = dataCenter;
    }
    return dataCenter;
  }

  Future<void> deleteDataCenter(String id) async {
    try {
      await apiClient.delete('${ApiEndpoints.dataCenters}/$id');
    } catch (e) {
      log('Failed to delete data center: $e');
    }
    _cachedDataCenters.removeWhere((dc) => dc.id == id);
  }

  Future<ResolvedLocationModel?> lookupPincode(String pincode) async {
    try {
      final response = await apiClient.dio.get(
        'https://localcity.jobes24x7.com/api/pincode/details/${pincode.trim()}',
      );
      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final innerData = body['data']['data'];
        if (innerData is List && innerData.isNotEmpty) {
          return ResolvedLocationModel.fromJson(innerData.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      log('Error looking up pincode: $e');
    }
    return null;
  }
}
