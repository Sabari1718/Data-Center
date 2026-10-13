import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/domain_model.dart';
import '../../../data/models/hosting_model.dart';
import '../../../data/repositories/domain_repository.dart';
import '../../../data/repositories/hosting_repository.dart';

class DynamicFieldState {
  final AsyncValue<List<DomainRegistrarModel>> registrars;
  final AsyncValue<List<HostingTypeModel>> hostingTypes;
  final bool isAdding;
  final int? deletingRegistrarId;
  final int? deletingHostingTypeId;

  const DynamicFieldState({
    this.registrars = const AsyncValue.loading(),
    this.hostingTypes = const AsyncValue.loading(),
    this.isAdding = false,
    this.deletingRegistrarId,
    this.deletingHostingTypeId,
  });

  DynamicFieldState copyWith({
    AsyncValue<List<DomainRegistrarModel>>? registrars,
    AsyncValue<List<HostingTypeModel>>? hostingTypes,
    bool? isAdding,
    int? deletingRegistrarId,
    bool clearDeletingRegistrarId = false,
    int? deletingHostingTypeId,
    bool clearDeletingHostingTypeId = false,
  }) {
    return DynamicFieldState(
      registrars: registrars ?? this.registrars,
      hostingTypes: hostingTypes ?? this.hostingTypes,
      isAdding: isAdding ?? this.isAdding,
      deletingRegistrarId: clearDeletingRegistrarId
          ? null
          : (deletingRegistrarId ?? this.deletingRegistrarId),
      deletingHostingTypeId: clearDeletingHostingTypeId
          ? null
          : (deletingHostingTypeId ?? this.deletingHostingTypeId),
    );
  }
}

final dynamicFieldControllerProvider =
    NotifierProvider<DynamicFieldController, DynamicFieldState>(() {
  return DynamicFieldController();
});

class DynamicFieldController extends Notifier<DynamicFieldState> {
  @override
  DynamicFieldState build() {
    Future.microtask(() => loadAll());
    return const DynamicFieldState();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadRegistrars(),
      loadHostingTypes(),
    ]);
  }

  Future<void> loadRegistrars() async {
    try {
      final repo = ref.read(domainRepositoryProvider);
      final list = await repo.getDomainRegistrarsList();
      state = state.copyWith(registrars: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(registrars: AsyncValue.error(e, st));
    }
  }

  Future<void> loadHostingTypes() async {
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final list = await repo.getHostingTypes();
      state = state.copyWith(hostingTypes: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(hostingTypes: AsyncValue.error(e, st));
    }
  }

  Future<bool> addDomainRegistrar(String name) async {
    if (name.trim().isEmpty) return false;
    state = state.copyWith(isAdding: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      final created = await repo.addDomainRegistrar(name.trim());
      final currentList = state.registrars.asData?.value ?? [];
      state = state.copyWith(
        isAdding: false,
        registrars: AsyncValue.data([
          created,
          ...currentList.where((item) => item.id != created.id),
        ]),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isAdding: false);
      return false;
    }
  }

  Future<bool> deleteDomainRegistrar(int id) async {
    state = state.copyWith(deletingRegistrarId: id);
    try {
      final repo = ref.read(domainRepositoryProvider);
      await repo.deleteDomainRegistrar(id);
      final currentList = state.registrars.asData?.value ?? [];
      state = state.copyWith(
        clearDeletingRegistrarId: true,
        registrars: AsyncValue.data(
          currentList.where((item) => item.id != id).toList(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(clearDeletingRegistrarId: true);
      return false;
    }
  }

  Future<bool> addHostingType(String name) async {
    if (name.trim().isEmpty) return false;
    state = state.copyWith(isAdding: true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final created = await repo.addHostingType(name.trim());
      final currentList = state.hostingTypes.asData?.value ?? [];
      state = state.copyWith(
        isAdding: false,
        hostingTypes: AsyncValue.data([
          created,
          ...currentList.where((item) => item.id != created.id),
        ]),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isAdding: false);
      return false;
    }
  }

  Future<bool> deleteHostingType(int id) async {
    state = state.copyWith(deletingHostingTypeId: id);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.deleteHostingType(id);
      final currentList = state.hostingTypes.asData?.value ?? [];
      state = state.copyWith(
        clearDeletingHostingTypeId: true,
        hostingTypes: AsyncValue.data(
          currentList.where((item) => item.id != id).toList(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(clearDeletingHostingTypeId: true);
      return false;
    }
  }
}
