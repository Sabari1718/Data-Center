import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/components/activity_item.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'activity_controller.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final state = ref.watch(activityControllerProvider);

    final categories = ['All', 'Server', 'Security', 'DataCenter', 'Domain'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Activity Log',
              subtitle: 'System audit trails, deployments & alerts',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh Log',
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  onPressed: () => ref.read(activityControllerProvider.notifier).refresh(),
                ),
              ],
            ),

            // Category Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = state.selectedCategory.toLowerCase() == cat.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(activityControllerProvider.notifier)
                          .setCategoryFilter(cat),
                      selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Timeline container
            Expanded(
              child: state.activities.when(
                loading: () => ListView.separated(
                  padding: AppSpacing.screenPadding,
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => LoadingSkeleton.card(height: 80),
                ),
                error: (err, _) => ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.read(activityControllerProvider.notifier).refresh(),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No Activity Logs',
                      description: 'No events found for the selected category.',
                      primaryButtonText: 'Reset Filter',
                      onPrimaryPressed: () {
                        ref.read(activityControllerProvider.notifier).setCategoryFilter('All');
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(activityControllerProvider.notifier).refresh(),
                    child: ListView(
                      padding: AppSpacing.screenPadding,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            children: List.generate(list.length, (i) {
                              final item = list[i];
                              return ActivityItem(
                                activity: item,
                                isLast: i == list.length - 1,
                                onTap: () {
                                  context.showSnackBar('Event ID: ${item.id} (${item.title})');
                                },
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
