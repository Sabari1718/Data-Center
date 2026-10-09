import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/data_center_model.dart';
import '../../../data/repositories/data_center_repository.dart';

class DataCenterState {
  final AsyncValue<List<DataCenterModel>> dataCenters;
  final String searchQuery;
  final String selectedRegion;

  const DataCenterState({
    required this.dataCenters,
    this.searchQuery = '',
    this.selectedRegion = 'All',
  });

  DataCenterState copyWith({
    AsyncValue<List<DataCenterModel>>? dataCenters,
    String? searchQuery,
    String? selectedRegion,
  }) {
    return DataCenterState(
      dataCenters: dataCenters ?? this.dataCenters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRegion: selectedRegion ?? this.selectedRegion,
    );
  }
}

final dataCenterControllerProvider =
    NotifierProvider<DataCenterController, DataCenterState>(() {
  return DataCenterController();
});

class DataCenterController extends Notifier<DataCenterState> {
  @override
  DataCenterState build() {
    final repo = ref.watch(dataCenterRepositoryProvider);
    return DataCenterState(
      dataCenters: AsyncValue.data(repo.currentDataCenters),
    );
  }

  Future<void> _loadDataCenters() async {
    try {
      final repo = ref.read(dataCenterRepositoryProvider);
      final list = await repo.getDataCenters(
        searchQuery: state.searchQuery,
        regionFilter: state.selectedRegion,
      );
      state = state.copyWith(dataCenters: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(dataCenters: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadDataCenters();
  }

  void setRegionFilter(String region) {
    state = state.copyWith(selectedRegion: region);
    _loadDataCenters();
  }

  Future<void> addDataCenter(DataCenterModel dc) async {
    final repo = ref.read(dataCenterRepositoryProvider);
    await repo.addDataCenter(dc);
    await _loadDataCenters();
  }

  Future<void> updateDataCenter(DataCenterModel dc) async {
    final repo = ref.read(dataCenterRepositoryProvider);
    await repo.updateDataCenter(dc);
    await _loadDataCenters();
  }

  Future<void> refresh() async {
    await _loadDataCenters();
  }
}
