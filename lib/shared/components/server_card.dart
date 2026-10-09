import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/server_model.dart';
import '../widgets/status_badge.dart';

class ServerCard extends StatelessWidget {
  final ServerModel server;
  final VoidCallback? onTap;

  const ServerCard({
    super.key,
    required this.server,
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
              // Header: Name & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.12)
                          : AppColors.primarySubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.dns_rounded,
                        size: 20,
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
                          server.name,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              server.ipAddress,
                              style: AppTextStyles.code(isDark).copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                server.location,
                                style: AppTextStyles.bodySmall(isDark).copyWith(
                                  fontSize: 11,
                                ),
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
                  StatusBadge(status: server.status, size: BadgeSize.small),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Metrics: CPU, RAM, Storage
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: 'CPU',
                      value: Formatters.formatPercentage(server.cpuUsagePercent, 0),
                      percentage: server.cpuUsagePercent,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'RAM',
                      value: Formatters.formatPercentage(server.ramUsagePercent, 0),
                      percentage: server.ramUsagePercent,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Disk',
                      value: Formatters.formatPercentage(server.storageUsagePercent, 0),
                      percentage: server.storageUsagePercent,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required double percentage,
    required bool isDark,
  }) {
    Color progressColor;
    if (percentage > 0.85) {
      progressColor = AppColors.error;
    } else if (percentage > 0.70) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall(isDark).copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelSmall(isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
