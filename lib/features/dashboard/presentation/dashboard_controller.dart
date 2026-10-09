import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

class DashboardState {
  final bool hasLayout;
  final AsyncValue<DashboardModel?> data;

  const DashboardState({
    required this.hasLayout,
    required this.data,
  });

  DashboardState copyWith({
    bool? hasLayout,
    AsyncValue<DashboardModel?>? data,
  }) {
    return DashboardState(
      hasLayout: hasLayout ?? this.hasLayout,
      data: data ?? this.data,
    );
  }
}

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(() {
  return DashboardController();
});

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    final repo = ref.read(dashboardRepositoryProvider);
    final hasConfigured = repo.hasLayoutConfigured();

    if (hasConfigured) {
      _loadData();
      return const DashboardState(
        hasLayout: true,
        data: AsyncValue.loading(),
      );
    } else {
      return const DashboardState(
        hasLayout: false,
        data: AsyncValue.data(null),
      );
    }
  }

  Future<void> _loadData() async {
    state = state.copyWith(data: const AsyncValue.loading());
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final result = await repo.getDashboardData();
      state = state.copyWith(hasLayout: true, data: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(data: AsyncValue.error(e, st));
    }
  }

  Future<void> loadDefaultLayout() async {
    final repo = ref.read(dashboardRepositoryProvider);
    await repo.setHasLayoutConfigured(true);
    await _loadData();
  }

  Future<void> refresh() async {
    if (state.hasLayout) {
      await _loadData();
    }
  }

  Future<void> resetToEmptyState() async {
    final repo = ref.read(dashboardRepositoryProvider);
    await repo.setHasLayoutConfigured(false);
    state = const DashboardState(
      hasLayout: false,
      data: AsyncValue.data(null),
    );
  }
}
