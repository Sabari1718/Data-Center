import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/hosting_model.dart';
import '../widgets/status_badge.dart';

class HostingCard extends StatelessWidget {
  final HostingModel hosting;
  final VoidCallback? onTap;

  const HostingCard({
    super.key,
    required this.hosting,
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
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.secondaryLight.withValues(alpha: 0.15)
                          : AppColors.secondarySubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cloud_queue_rounded,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hosting.serviceName,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (hosting.sslActive) ...[
                              const Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Expanded(
                              child: Text(
                                hosting.domain,
                                style: AppTextStyles.bodySmall(isDark).copyWith(
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  fontWeight: FontWeight.w500,
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
                  StatusBadge(status: hosting.status, size: BadgeSize.small),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Storage and Bandwidth bars
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Disk: ${hosting.storageUsedGb.toStringAsFixed(1)} GB',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              Formatters.formatPercentage(hosting.storageUsagePercent, 0),
                              style: AppTextStyles.labelSmall(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: hosting.storageUsagePercent.clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hosting.storageUsagePercent > 0.85
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bandwidth: ${hosting.bandwidthUsedGb.toStringAsFixed(0)} GB',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              Formatters.formatPercentage(hosting.bandwidthUsagePercent, 0),
                              style: AppTextStyles.labelSmall(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: hosting.bandwidthUsagePercent.clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryLight),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Footer: Plan name & Expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.borderLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hosting.planName,
                      style: AppTextStyles.bodySmall(isDark).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Expires: ${Formatters.formatDate(hosting.expiryDate)}',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
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
}
