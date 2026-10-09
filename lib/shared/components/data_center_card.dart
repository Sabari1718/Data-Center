import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/data_center_model.dart';
import '../widgets/status_badge.dart';

class DataCenterCard extends StatelessWidget {
  final DataCenterModel dataCenter;
  final VoidCallback? onTap;

  const DataCenterCard({
    super.key,
    required this.dataCenter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: AppRadius.borderLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.12)
                          : AppColors.primarySubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataCenter.name,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.borderLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dataCenter.code,
                                style: AppTextStyles.code(isDark).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${dataCenter.city}, ${dataCenter.country}',
                                style: AppTextStyles.bodySmall(isDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: dataCenter.status, size: BadgeSize.small),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    label: 'Servers',
                    value: '${dataCenter.activeServers}/${dataCenter.totalServers}',
                    icon: Icons.storage_rounded,
                    isDark: isDark,
                  ),
                  _buildStat(
                    label: 'Health',
                    value: '${dataCenter.healthScore}%',
                    icon: Icons.favorite_rounded,
                    isDark: isDark,
                    color: dataCenter.healthScore >= 99 ? AppColors.success : AppColors.warning,
                  ),
                  _buildStat(
                    label: 'PUE Rating',
                    value: '${dataCenter.coolingEfficiencyPue}',
                    icon: Icons.eco_rounded,
                    isDark: isDark,
                    color: AppColors.info,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall(isDark).copyWith(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.titleSmall(isDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
