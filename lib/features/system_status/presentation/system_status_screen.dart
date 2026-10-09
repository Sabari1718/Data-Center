import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/components/system_status_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'system_status_controller.dart';

class SystemStatusScreen extends ConsumerWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final statusState = ref.watch(systemStatusControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'System Status',
              subtitle: 'Global services, latency & infrastructure health',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Live Refresh',
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  onPressed: () => ref.read(systemStatusControllerProvider.notifier).refresh(),
                ),
              ],
            ),
            Expanded(
              child: statusState.when(
                loading: () => ListView.separated(
                  padding: AppSpacing.screenPadding,
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, _) => LoadingSkeleton.card(height: 110),
                ),
                error: (err, _) => ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.read(systemStatusControllerProvider.notifier).refresh(),
                ),
                data: (list) {
                  final allOnline = list.every((s) => s.status == 'online');
                  final warningCount = list.where((s) => s.status == 'warning').length;

                  return RefreshIndicator(
                    onRefresh: () => ref.read(systemStatusControllerProvider.notifier).refresh(),
                    child: ListView(
                      padding: AppSpacing.screenPadding,
                      children: [
                        // Overall System Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: allOnline
                                  ? (isDark
                                      ? [const Color(0xFF13271D), const Color(0xFF0F1E17)]
                                      : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)])
                                  : (isDark
                                      ? [const Color(0xFF33200E), const Color(0xFF26180B)]
                                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]),
                            ),
                            borderRadius: AppRadius.borderLg,
                            border: Border.all(
                              color: allOnline
                                  ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
                                  : (isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                allOnline ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                color: allOnline ? AppColors.success : AppColors.warning,
                                size: 32,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allOnline
                                          ? 'All Systems Operational'
                                          : '$warningCount System(s) Reporting Degraded State',
                                      style: AppTextStyles.titleSmall(isDark).copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: allOnline
                                            ? (isDark ? const Color(0xFF6EE7B7) : AppColors.successDark)
                                            : (isDark ? const Color(0xFFFCD34D) : AppColors.warningDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      allOnline
                                          ? 'Automatic synthetic probes check every 30s.'
                                          : 'Investigating degraded nodes in Tokyo TYO1.',
                                      style: AppTextStyles.bodySmall(isDark).copyWith(
                                        fontSize: 11.5,
                                        color: allOnline
                                            ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))
                                            : (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // System cards
                        ...list.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: SystemStatusCard(
                              status: item,
                              onTap: () {
                                context.showSnackBar(
                                  'Probing ${item.name}... Response: ${item.latencyMs}ms',
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
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
