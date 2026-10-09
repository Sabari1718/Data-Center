import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/domain_model.dart';
import '../widgets/status_badge.dart';

class DomainCard extends StatelessWidget {
  final DomainModel domain;
  final ValueChanged<bool>? onAutoRenewChanged;
  final VoidCallback? onTap;

  const DomainCard({
    super.key,
    required this.domain,
    this.onAutoRenewChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysRemaining = domain.daysUntilExpiry;

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
                          ? AppColors.info.withValues(alpha: 0.15)
                          : AppColors.infoSubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domain.domainName,
                          style: AppTextStyles.titleSmall(isDark).copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          domain.registrar,
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: domain.status, size: BadgeSize.small),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Bottom details & auto-renew switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expires in $daysRemaining days',
                        style: AppTextStyles.bodySmall(isDark).copyWith(
                          fontWeight: FontWeight.w600,
                          color: daysRemaining < 30
                              ? AppColors.warningDark
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatDate(domain.expiryDate),
                        style: AppTextStyles.bodySmall(isDark).copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Auto-renew',
                        style: AppTextStyles.labelSmall(isDark).copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: domain.autoRenew,
                          onChanged: onAutoRenewChanged,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ],
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
