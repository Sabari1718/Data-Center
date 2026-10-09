import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../auth/presentation/auth_controller.dart';

class MoreMenuSheet extends ConsumerWidget {
  const MoreMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = context.isDark;
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const MoreMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'J',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? AppConstants.defaultUserName,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? AppConstants.defaultUserEmail,
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(RouteNames.profile);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Additional Modules',
              style: AppTextStyles.labelSmall(isDark).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Navigation items
            _buildMenuItem(
              context: context,
              icon: Icons.language_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'Domains',
              subtitle: 'DNS, DNSSEC & SSL auto-renewal',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.domains);
              },
              isDark: isDark,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.history_rounded,
              color: AppColors.info,
              title: 'Activity Log',
              subtitle: 'System audit trails & deployment records',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.activity);
              },
              isDark: isDark,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.show_chart_rounded,
              color: AppColors.success,
              title: 'System Status',
              subtitle: 'Real-time telemetry, latency & uptime',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.systemStatus);
              },
              isDark: isDark,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline_rounded,
              color: AppColors.primary,
              title: 'Profile',
              subtitle: 'Account info, roles & credentials',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.profile);
              },
              isDark: isDark,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              color: AppColors.secondary,
              title: 'Settings',
              subtitle: 'Theme mode, API endpoints & alerts',
              onTap: () {
                Navigator.pop(context);
                context.push(RouteNames.settings);
              },
              isDark: isDark,
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Logout
            _buildMenuItem(
              context: context,
              icon: Icons.logout_rounded,
              color: AppColors.error,
              title: 'Logout',
              subtitle: 'End secure workspace session',
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: AppRadius.borderSm,
          ),
          child: Center(child: Icon(icon, color: color, size: 20)),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSmall(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall(isDark).copyWith(
            fontSize: 11,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: onTap,
      ),
    );
  }
}
