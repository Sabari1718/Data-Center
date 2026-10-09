import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'User Profile',
              subtitle: 'Account details, permissions & credentials',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  onPressed: () => context.push(RouteNames.settings),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'J',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? AppConstants.defaultUserName,
                          style: AppTextStyles.titleMedium(isDark).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? AppConstants.defaultUserEmail,
                          style: AppTextStyles.bodyMedium(isDark),
                        ),
                        const SizedBox(height: 10),
                        const StatusBadge(
                          status: 'active',
                          customLabel: 'Infrastructure Admin',
                          size: BadgeSize.small,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account Information Card
                  Text(
                    'Organization & Account',
                    style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

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
                      children: [
                        _buildInfoRow('Organization', user?.company ?? 'DataCenter Global Corp', isDark),
                        const Divider(height: 20),
                        _buildInfoRow('Department', user?.department ?? 'Cloud Operations', isDark),
                        const Divider(height: 20),
                        _buildInfoRow('Security Role', user?.role ?? 'Infrastructure Admin', isDark),
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Last Login',
                          user?.lastLoginAt != null
                              ? Formatters.formatDateTime(user!.lastLoginAt!)
                              : 'Recent',
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security & Preferences Quick Links
                  Text(
                    'Security & Access',
                    style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.shield_outlined, color: AppColors.success),
                          title: Text('Two-Factor Authentication', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Hardware Key & TOTP enabled', style: AppTextStyles.bodySmall(isDark)),
                          trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.key_outlined, color: AppColors.primary),
                          title: Text('API Access Tokens', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Manage bearer tokens & CLI keys', style: AppTextStyles.bodySmall(isDark)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.showSnackBar('API token management opened'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined, color: AppColors.secondary),
                          title: Text('App Settings', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Theme, network endpoints & notifications', style: AppTextStyles.bodySmall(isDark)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push(RouteNames.settings),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  AppButton(
                    text: 'Sign Out of Account',
                    icon: Icons.logout_rounded,
                    backgroundColor: isDark ? const Color(0xFF3B181E) : AppColors.errorSubtle,
                    textColor: AppColors.error,
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(RouteNames.login);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(isDark).copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(isDark).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
