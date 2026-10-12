import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/server_model.dart';
import '../../../data/repositories/server_repository.dart';

class ServerState {
  final AsyncValue<List<ServerModel>> servers;
  final AsyncValue<List<ServerNetworkConnectionModel>> networkConnections;
  final String searchQuery;
  final String statusFilter;
  final String dataCenterFilter;

  const ServerState({
    required this.servers,
    this.networkConnections = const AsyncValue.data([]),
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.dataCenterFilter = 'All',
  });

  ServerState copyWith({
    AsyncValue<List<ServerModel>>? servers,
    AsyncValue<List<ServerNetworkConnectionModel>>? networkConnections,
    String? searchQuery,
    String? statusFilter,
    String? dataCenterFilter,
  }) {
    return ServerState(
      servers: servers ?? this.servers,
      networkConnections: networkConnections ?? this.networkConnections,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      dataCenterFilter: dataCenterFilter ?? this.dataCenterFilter,
    );
  }
}

final serverControllerProvider =
    NotifierProvider<ServerController, ServerState>(() {
  return ServerController();
});

class ServerController extends Notifier<ServerState> {
  @override
  ServerState build() {
    Future.microtask(() {
      _loadServers();
      _loadNetworkConnections();
    });
    return const ServerState(servers: AsyncValue.loading());
  }

  Future<void> _loadServers() async {
    try {
      final repo = ref.read(serverRepositoryProvider);
      final list = await repo.getServers(
        searchQuery: state.searchQuery,
        statusFilter: state.statusFilter,
        dataCenterFilter: state.dataCenterFilter,
      );
      state = state.copyWith(servers: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(servers: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadNetworkConnections() async {
    try {
      final repo = ref.read(serverRepositoryProvider);
      final list = await repo.getNetworkConnections();
      state = state.copyWith(networkConnections: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(networkConnections: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _loadServers();
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    _loadServers();
  }

  Future<void> restartServer(String id) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.restartServer(id);
    await _loadServers();
  }

  Future<void> stopServer(String id) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.stopServer(id);
    await _loadServers();
  }

  Future<void> rebootServer(String id) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.rebootServer(id);
    await _loadServers();
  }

  Future<void> addServer(ServerModel model) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.addServer(model);
    await _loadServers();
  }

  Future<void> updateServer(ServerModel model) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.updateServer(model);
    await _loadServers();
  }

  Future<void> deleteServer(String id) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.deleteServer(id);
    await _loadServers();
  }

  Future<void> saveNetworkConnection(ServerNetworkConnectionModel conn) async {
    final repo = ref.read(serverRepositoryProvider);
    await repo.saveNetworkConnection(conn);
    await _loadNetworkConnections();
  }

  Future<void> refresh() async {
    await _loadServers();
    await _loadNetworkConnections();
  }
}
