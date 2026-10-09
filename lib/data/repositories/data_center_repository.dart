import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../datasources/mock_data_store.dart';
import '../models/data_center_model.dart';

final dataCenterRepositoryProvider = Provider<DataCenterRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DataCenterRepository(apiClient: apiClient);
});

class DataCenterRepository {
  final ApiClient apiClient;
  final List<DataCenterModel> _dataCenters = List.from(MockDataStore.initialDataCenters);

  DataCenterRepository({required this.apiClient});

  List<DataCenterModel> get currentDataCenters => List.unmodifiable(_dataCenters);

  Future<List<DataCenterModel>> getDataCenters({
    String? searchQuery,
    String? regionFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = List<DataCenterModel>.from(_dataCenters);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where((dc) =>
              dc.name.toLowerCase().contains(q) ||
              dc.code.toLowerCase().contains(q) ||
              dc.city.toLowerCase().contains(q) ||
              dc.country.toLowerCase().contains(q))
          .toList();
    }

    if (regionFilter != null && regionFilter != 'All') {
      results = results.where((dc) => dc.region == regionFilter).toList();
    }

    return results;
  }

  Future<DataCenterModel?> getDataCenterById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _dataCenters.firstWhere((dc) => dc.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DataCenterModel> addDataCenter(DataCenterModel dataCenter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dataCenters.insert(0, dataCenter);
    return dataCenter;
  }

  Future<DataCenterModel> updateDataCenter(DataCenterModel dataCenter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _dataCenters.indexWhere((dc) => dc.id == dataCenter.id);
    if (index != -1) {
      _dataCenters[index] = dataCenter;
    } else {
      _dataCenters.insert(0, dataCenter);
    }
    return dataCenter;
  }

  Future<void> deleteDataCenter(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _dataCenters.removeWhere((dc) => dc.id == id);
  }
}
