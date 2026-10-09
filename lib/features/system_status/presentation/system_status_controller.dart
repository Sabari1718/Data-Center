import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/system_status_model.dart';
import '../../../data/repositories/system_status_repository.dart';

final systemStatusControllerProvider =
    NotifierProvider<SystemStatusController, AsyncValue<List<SystemStatusModel>>>(() {
  return SystemStatusController();
});

class SystemStatusController extends Notifier<AsyncValue<List<SystemStatusModel>>> {
  @override
  AsyncValue<List<SystemStatusModel>> build() {
    _loadStatus();
    return const AsyncValue.loading();
  }

  Future<void> _loadStatus() async {
    try {
      final repo = ref.read(systemStatusRepositoryProvider);
      final list = await repo.getSystemStatus();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadStatus();
  }
}
