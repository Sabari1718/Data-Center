import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/hosting_model.dart';
import '../../../data/repositories/hosting_repository.dart';

class HostingState {
  final AsyncValue<List<HostingModel>> hostings;
  final String searchQuery;
  final String statusFilter;

  const HostingState({
    required this.hostings,
    this.searchQuery = '',
    this.statusFilter = 'All',
  });

  HostingState copyWith({
    AsyncValue<List<HostingModel>>? hostings,
    String? searchQuery,
    String? statusFilter,
  }) {
    return HostingState(
      hostings: hostings ?? this.hostings,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

final hostingControllerProvider =
    NotifierProvider<HostingController, HostingState>(() {
  return HostingController();
});

class HostingController extends Notifier<HostingState> {
  @override
  HostingState build() {
    Future.microtask(_loadHostings);
    return const HostingState(hostings: AsyncValue.loading());
  }

  Future<void> _loadHostings() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getHostings(
        searchQuery: state.searchQuery,
        statusFilter: state.statusFilter,
      );
      state = state.copyWith(hostings: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(hostings: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadHostings();
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    _loadHostings();
  }

  Future<void> addHosting(HostingModel hosting) async {
    final repo = ref.read(hostingRepositoryProvider);
    await repo.addHosting(hosting);
    await _loadHostings();
  }

  Future<void> refresh() async {
    await _loadHostings();
  }
}
