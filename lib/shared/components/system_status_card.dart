import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/system_status_model.dart';
import '../widgets/status_badge.dart';

class SystemStatusCard extends StatelessWidget {
  final SystemStatusModel status;
  final VoidCallback? onTap;

  const SystemStatusCard({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    switch (status.category.toLowerCase()) {
      case 'api':
        icon = Icons.api_rounded;
        break;
      case 'server':
        icon = Icons.dns_rounded;
        break;
      case 'database':
        icon = Icons.dataset_rounded;
        break;
      case 'hosting':
        icon = Icons.cloud_queue_rounded;
        break;
      case 'network':
      default:
        icon = Icons.hub_rounded;
    }

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
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.12)
                          : AppColors.primarySubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Center(
                      child: Icon(icon, size: 20, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.name,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.category.toUpperCase(),
                          style: AppTextStyles.labelSmall(isDark).copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: status.status, size: BadgeSize.small),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Metrics: Latency and Uptime
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 15,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Latency: ',
                        style: AppTextStyles.bodySmall(isDark).copyWith(fontSize: 12),
                      ),
                      Text(
                        '${status.latencyMs} ms',
                        style: AppTextStyles.code(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: status.latencyMs < 50 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Uptime: ',
                        style: AppTextStyles.bodySmall(isDark).copyWith(fontSize: 12),
                      ),
                      Text(
                        '${status.uptimePercentage}%',
                        style: AppTextStyles.code(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (status.incidentNote != null && status.incidentNote!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    status.incidentNote!,
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
