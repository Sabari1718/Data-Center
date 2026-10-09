import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_text_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricsEnabled = true;
  bool _pushNotifications = true;
  bool _criticalAlertsOnly = false;
  late final TextEditingController _apiUrlController;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesServiceProvider);
    _apiUrlController = TextEditingController(text: prefs.getApiBaseUrl());
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Settings',
              subtitle: 'Preferences, endpoints & system appearance',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  // Appearance Section
                  Text(
                    'Theme & Appearance',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme Mode', style: AppTextStyles.titleSmall(isDark)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildThemeOption(
                              label: 'System',
                              icon: Icons.brightness_auto_rounded,
                              isSelected: currentThemeMode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.system),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              label: 'Light',
                              icon: Icons.light_mode_rounded,
                              isSelected: currentThemeMode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.light),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              label: 'Dark',
                              icon: Icons.dark_mode_rounded,
                              isSelected: currentThemeMode == ThemeMode.dark,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.dark),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // API Connectivity
                  Text(
                    'API & Backend Connection',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Base API Endpoint',
                          hintText: 'https://api.datacenter.cloud/v1',
                          controller: _apiUrlController,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Save Endpoint Configuration',
                          height: 42,
                          onPressed: () async {
                            final prefs = ref.read(preferencesServiceProvider);
                            await prefs.setApiBaseUrl(_apiUrlController.text.trim());
                            if (context.mounted) {
                              context.showSnackBar('API endpoint saved: ${_apiUrlController.text}');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Notifications & Security
                  Text(
                    'Notifications & Security',
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
                        SwitchListTile(
                          title: Text('Push Notifications', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Receive server outage & load alerts', style: AppTextStyles.bodySmall(isDark)),
                          value: _pushNotifications,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                          activeThumbColor: AppColors.primary,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Critical Incidents Only', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Suppress routine informational logs', style: AppTextStyles.bodySmall(isDark)),
                          value: _criticalAlertsOnly,
                          onChanged: (val) => setState(() => _criticalAlertsOnly = val),
                          activeThumbColor: AppColors.primary,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Biometric Authentication', style: AppTextStyles.titleSmall(isDark)),
                          subtitle: Text('Require Face ID / Fingerprint on launch', style: AppTextStyles.bodySmall(isDark)),
                          value: _biometricsEnabled,
                          onChanged: (val) => setState(() => _biometricsEnabled = val),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Info Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${AppConstants.appName} v${AppConstants.appVersion}',
                          style: AppTextStyles.labelSmall(isDark).copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Production Mobile Architecture (Android / iOS)',
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            fontSize: 10.5,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.primaryLight.withValues(alpha: 0.18) : AppColors.primarySubtle)
            : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
        borderRadius: AppRadius.borderMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppColors.primaryLight : AppColors.primary)
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
