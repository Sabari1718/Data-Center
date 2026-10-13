import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/domain_model.dart';
import '../../../data/repositories/domain_repository.dart';

class DomainState {
  final AsyncValue<List<DomainModel>> domains;
  final AsyncValue<List<DomainExtensionModel>> extensions;
  final AsyncValue<List<String>> registrars;
  final AsyncValue<List<SubdomainModel>> subdomains;
  final String searchQuery;
  final String statusFilter;
  final bool isLoadingAction;

  const DomainState({
    required this.domains,
    this.extensions = const AsyncValue.data([]),
    this.registrars = const AsyncValue.data([]),
    this.subdomains = const AsyncValue.data([]),
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.isLoadingAction = false,
  });

  DomainState copyWith({
    AsyncValue<List<DomainModel>>? domains,
    AsyncValue<List<DomainExtensionModel>>? extensions,
    AsyncValue<List<String>>? registrars,
    AsyncValue<List<SubdomainModel>>? subdomains,
    String? searchQuery,
    String? statusFilter,
    bool? isLoadingAction,
  }) {
    return DomainState(
      domains: domains ?? this.domains,
      extensions: extensions ?? this.extensions,
      registrars: registrars ?? this.registrars,
      subdomains: subdomains ?? this.subdomains,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
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
    Future.microtask(() => loadAll());
    return const DomainState(domains: AsyncValue.loading());
  }

  Future<void> loadAll() async {
    await Future.wait([
      _loadDomains(),
      _loadExtensions(),
      _loadRegistrars(),
      _loadSubdomains(),
    ]);
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

  Future<void> _loadExtensions() async {
    try {
      final repo = ref.read(domainRepositoryProvider);
      final list = await repo.getExtensions();
      state = state.copyWith(extensions: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(extensions: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadRegistrars() async {
    try {
      final repo = ref.read(domainRepositoryProvider);
      final list = await repo.getDomainRegistrars();
      state = state.copyWith(registrars: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(registrars: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadSubdomains() async {
    try {
      final repo = ref.read(domainRepositoryProvider);
      final list = await repo.getSubdomains();
      state = state.copyWith(subdomains: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(subdomains: AsyncValue.error(e, st));
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

  Future<bool> addDomain(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.addDomain(payload);
      await _loadDomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> updateDomain(String id, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.updateDomain(id, payload);
      await _loadDomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> deleteDomain(String id) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.deleteDomain(id);
      await _loadDomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<DomainModel?> getDomainDetails(String id) async {
    final repo = ref.read(domainRepositoryProvider);
    return await repo.getDomainById(id);
  }

  Future<bool> addSubdomain({
    required dynamic primaryDomainId,
    required String subdomainPrefix,
    required String url,
  }) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.addSubdomain(
        primaryDomainId: primaryDomainId,
        subdomainPrefix: subdomainPrefix,
        url: url,
      );
      await _loadSubdomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> updateSubdomain(
    dynamic id, {
    required dynamic primaryDomainId,
    required String subdomainPrefix,
    required String url,
  }) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.updateSubdomain(
        id,
        primaryDomainId: primaryDomainId,
        subdomainPrefix: subdomainPrefix,
        url: url,
      );
      await _loadSubdomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> deleteSubdomain(dynamic id) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.deleteSubdomain(id);
      await _loadSubdomains();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<DomainExtensionModel?> addExtension(String extension) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      final created = await repo.addExtension(extension);
      await _loadExtensions();
      state = state.copyWith(isLoadingAction: false);
      return created;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return null;
    }
  }

  Future<void> refresh() async {
    await loadAll();
  }
}
