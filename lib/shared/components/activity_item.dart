import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/activity_log_model.dart';

class ActivityItem extends StatelessWidget {
  final ActivityLogModel activity;
  final bool isLast;
  final VoidCallback? onTap;

  const ActivityItem({
    super.key,
    required this.activity,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (activity.category.toLowerCase()) {
      case 'server':
        icon = Icons.dns_rounded;
        break;
      case 'security':
        icon = Icons.shield_rounded;
        break;
      case 'domain':
        icon = Icons.language_rounded;
        break;
      case 'hosting':
        icon = Icons.cloud_queue_rounded;
        break;
      case 'datacenter':
        icon = Icons.apartment_rounded;
        break;
      default:
        icon = Icons.notifications_active_rounded;
    }

    switch (activity.severity.toLowerCase()) {
      case 'success':
        iconColor = AppColors.success;
        iconBg = AppColors.successSubtle;
        break;
      case 'warning':
        iconColor = AppColors.warning;
        iconBg = AppColors.warningSubtle;
        break;
      case 'error':
        iconColor = AppColors.error;
        iconBg = AppColors.errorSubtle;
        break;
      case 'info':
      default:
        iconColor = AppColors.primary;
        iconBg = isDark ? AppColors.primaryLight.withValues(alpha: 0.15) : AppColors.primarySubtle;
    }

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline connector + Icon
            Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: AppTextStyles.titleSmall(isDark).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.formatTimeAgo(activity.timestamp),
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: AppTextStyles.bodyMedium(isDark).copyWith(
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.actorName,
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
