import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/data_center_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/status_badge.dart';

class DataCenterDetailsScreen extends StatelessWidget {
  final DataCenterModel dataCenter;

  const DataCenterDetailsScreen({super.key, required this.dataCenter});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: dataCenter.name,
              subtitle: '${dataCenter.city}, ${dataCenter.country}',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: StatusBadge(status: dataCenter.status),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  // Health & Overview Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
                      borderRadius: AppRadius.borderLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dataCenter.code,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Health: ${dataCenter.healthScore}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dataCenter.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dataCenter.address,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Facility Metrics Grid
                  Text(
                    'Infrastructure Specs',
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
                        _buildDetailRow(
                          icon: Icons.storage_rounded,
                          label: 'Server Fleet',
                          value: '${dataCenter.activeServers} Active / ${dataCenter.totalServers} Total',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          icon: Icons.view_column_rounded,
                          label: 'Server Racks',
                          value: '${dataCenter.totalRacks} Racks Deployed',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          icon: Icons.bolt_rounded,
                          label: 'Power Grid Capacity',
                          value: '${dataCenter.powerCapacityKva.toInt()} kVA Redundant',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          icon: Icons.ac_unit_rounded,
                          label: 'Cooling Efficiency (PUE)',
                          value: '${dataCenter.coolingEfficiencyPue} (Industry Top Tier)',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow(
                          icon: Icons.language_rounded,
                          label: 'BGP IP Routing Prefix',
                          value: dataCenter.ipPrefix,
                          isDark: isDark,
                          isMonospace: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  AppButton(
                    text: 'Contact Facility NOC',
                    icon: Icons.phone_in_talk_rounded,
                    onPressed: () {
                      context.showSnackBar('NOC hotline: +1 (800) 555-DATA');
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isMonospace = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.primaryLight : AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Text(
          value,
          style: isMonospace
              ? AppTextStyles.code(isDark).copyWith(fontWeight: FontWeight.w600, fontSize: 12)
              : AppTextStyles.labelSmall(isDark).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
