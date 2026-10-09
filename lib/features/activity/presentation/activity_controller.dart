import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/activity_log_model.dart';
import '../../../data/repositories/activity_repository.dart';

class ActivityState {
  final AsyncValue<List<ActivityLogModel>> activities;
  final String selectedCategory;

  const ActivityState({
    required this.activities,
    this.selectedCategory = 'All',
  });

  ActivityState copyWith({
    AsyncValue<List<ActivityLogModel>>? activities,
    String? selectedCategory,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final activityControllerProvider =
    NotifierProvider<ActivityController, ActivityState>(() {
  return ActivityController();
});

class ActivityController extends Notifier<ActivityState> {
  @override
  ActivityState build() {
    _loadActivities();
    return const ActivityState(activities: AsyncValue.loading());
  }

  Future<void> _loadActivities() async {
    try {
      final repo = ref.read(activityRepositoryProvider);
      final list = await repo.getActivities(
        categoryFilter: state.selectedCategory,
      );
      state = state.copyWith(activities: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(activities: AsyncValue.error(e, st));
    }
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
    _loadActivities();
  }

  Future<void> refresh() async {
    await _loadActivities();
  }
}
