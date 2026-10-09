import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/domain_model.dart';
import '../../../data/repositories/domain_repository.dart';

class DomainState {
  final AsyncValue<List<DomainModel>> domains;
  final String searchQuery;
  final String statusFilter;

  const DomainState({
    required this.domains,
    this.searchQuery = '',
    this.statusFilter = 'All',
  });

  DomainState copyWith({
    AsyncValue<List<DomainModel>>? domains,
    String? searchQuery,
    String? statusFilter,
  }) {
    return DomainState(
      domains: domains ?? this.domains,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

final domainControllerProvider =
    NotifierProvider<DomainController, DomainState>(() {
  return DomainController();
});

class DomainController extends Notifier<DomainState> {
  @override
  DomainState build() {
    _loadDomains();
    return const DomainState(domains: AsyncValue.loading());
  }

  Future<void> _loadDomains() async {
    try {
      final repo = ref.read(domainRepositoryProvider);
      final list = await repo.getDomains(
        searchQuery: state.searchQuery,
        statusFilter: state.statusFilter,
      );
      state = state.copyWith(domains: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(domains: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadDomains();
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    _loadDomains();
  }

  Future<void> toggleAutoRenew(String domainId) async {
    final repo = ref.read(domainRepositoryProvider);
    await repo.toggleAutoRenew(domainId);
    await _loadDomains();
  }

  Future<void> addDomain(DomainModel domain) async {
    final repo = ref.read(domainRepositoryProvider);
    await repo.addDomain(domain);
    await _loadDomains();
  }

  Future<void> refresh() async {
    await _loadDomains();
  }
}
