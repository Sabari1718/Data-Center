import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/domain_model.dart';
import '../../../data/models/hosting_model.dart';
import '../../../data/models/server_model.dart';
import '../../../data/repositories/hosting_repository.dart';

class HostingState {
  final AsyncValue<List<HostingModel>> hostings;
  final AsyncValue<List<HostingNewModel>> hostingNewList;
  final AsyncValue<List<ServerHostingModel>> serverHostings;
  final AsyncValue<List<ServerModel>> servers;
  final AsyncValue<List<HostingTypeModel>> hostingTypes;
  final AsyncValue<List<DomainModel>> domains;
  final AsyncValue<List<String>> registrars;
  final AsyncValue<List<HostingDomainMappingModel>> mappings;
  final String searchQuery;
  final String statusFilter;
  final bool isLoadingAction;

  const HostingState({
    required this.hostings,
    this.hostingNewList = const AsyncValue.data([]),
    this.serverHostings = const AsyncValue.data([]),
    this.servers = const AsyncValue.data([]),
    this.hostingTypes = const AsyncValue.data([]),
    this.domains = const AsyncValue.data([]),
    this.registrars = const AsyncValue.data([]),
    this.mappings = const AsyncValue.data([]),
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.isLoadingAction = false,
  });

  HostingState copyWith({
    AsyncValue<List<HostingModel>>? hostings,
    AsyncValue<List<HostingNewModel>>? hostingNewList,
    AsyncValue<List<ServerHostingModel>>? serverHostings,
    AsyncValue<List<ServerModel>>? servers,
    AsyncValue<List<HostingTypeModel>>? hostingTypes,
    AsyncValue<List<DomainModel>>? domains,
    AsyncValue<List<String>>? registrars,
    AsyncValue<List<HostingDomainMappingModel>>? mappings,
    String? searchQuery,
    String? statusFilter,
    bool? isLoadingAction,
  }) {
    return HostingState(
      hostings: hostings ?? this.hostings,
      hostingNewList: hostingNewList ?? this.hostingNewList,
      serverHostings: serverHostings ?? this.serverHostings,
      servers: servers ?? this.servers,
      hostingTypes: hostingTypes ?? this.hostingTypes,
      domains: domains ?? this.domains,
      registrars: registrars ?? this.registrars,
      mappings: mappings ?? this.mappings,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
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
    Future.microtask(loadAll);
    return const HostingState(hostings: AsyncValue.loading());
  }

  Future<void> loadAll() async {
    await Future.wait([
      _loadServerHostings(),
      _loadServers(),
      _loadHostingNew(),
      _loadHostingTypes(),
      _loadDomains(),
      _loadRegistrars(),
      _loadMappings(),
      _loadHostings(),
    ]);
  }

  Future<void> _loadServerHostings() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getServerHostings();
      state = state.copyWith(serverHostings: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(serverHostings: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadServers() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getServers();
      state = state.copyWith(servers: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(servers: AsyncValue.error(e, st));
    }
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

  Future<void> _loadHostingNew() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getHostingNewList();
      state = state.copyWith(hostingNewList: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(hostingNewList: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadHostingTypes() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getHostingTypes();
      state = state.copyWith(hostingTypes: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(hostingTypes: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadDomains() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getDomains();
      state = state.copyWith(domains: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(domains: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadRegistrars() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getDomainRegistrars();
      state = state.copyWith(registrars: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(registrars: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadMappings() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getHostingDomainMappings();
      state = state.copyWith(mappings: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(mappings: AsyncValue.error(e, st));
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

  // --- Server Hostings CRUD (/api/hostings) ---
  Future<bool> createServerHosting(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.createServerHosting(payload);
      await _loadServerHostings();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> updateServerHosting(dynamic id, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.updateServerHosting(id, payload);
      await _loadServerHostings();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> deleteServerHosting(dynamic id) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.deleteServerHosting(id);
      await _loadServerHostings();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  // --- Standalone Hosting CRUD (/api/hosting-new) ---
  Future<bool> createHostingNew(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.createHostingNew(payload);
      await _loadHostingNew();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> updateHostingNew(dynamic id, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.updateHostingNew(id, payload);
      await _loadHostingNew();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> deleteHostingNew(dynamic id) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.deleteHostingNew(id);
      await _loadHostingNew();
      state = state.copyWith(isLoadingAction: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<HostingNewModel?> getHostingDetails(dynamic id) async {
    final repo = ref.read(hostingRepositoryProvider);
    return await repo.getHostingById(id);
  }

  // --- Mappings CRUD (/api/hosting-domain-mappings) ---
  Future<bool> createMapping(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final success = await repo.createHostingDomainMapping(payload);
      await _loadMappings();
      state = state.copyWith(isLoadingAction: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> updateMapping(dynamic id, Map<String, dynamic> payload) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final success = await repo.updateHostingDomainMapping(id, payload);
      await _loadMappings();
      state = state.copyWith(isLoadingAction: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<bool> deleteMapping(dynamic id) async {
    state = state.copyWith(isLoadingAction: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final success = await repo.deleteHostingDomainMapping(id);
      await _loadMappings();
      state = state.copyWith(isLoadingAction: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoadingAction: false);
      return false;
    }
  }

  Future<void> addHosting(HostingModel hosting) async {
    final repo = ref.read(hostingRepositoryProvider);
    await repo.addHosting(hosting);
    await _loadHostings();
  }

  Future<void> refresh() async {
    await loadAll();
  }
}
