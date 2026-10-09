import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/server_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_outlined_button.dart';
import '../../../shared/widgets/status_badge.dart';
import 'server_controller.dart';

class ServerDetailsScreen extends ConsumerStatefulWidget {
  final ServerModel server;

  const ServerDetailsScreen({super.key, required this.server});

  @override
  ConsumerState<ServerDetailsScreen> createState() => _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends ConsumerState<ServerDetailsScreen> {
  late ServerModel _server;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _server = widget.server;
  }

  Future<void> _handleAction(String actionName, Future<void> Function() action) async {
    setState(() => _isActionInProgress = true);
    try {
      await action();
      if (mounted) {
        context.showSnackBar('$actionName completed successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to $actionName: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _server.name,
              subtitle: _server.hostname,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: StatusBadge(status: _server.status),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  // Server ID & OS Banner
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'IPv4 Address',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              _server.ipAddress,
                              style: AppTextStyles.code(isDark).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Data Center',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              '${_server.dataCenterName} (${_server.location})',
                              style: AppTextStyles.bodySmall(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Operating System',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              _server.os,
                              style: AppTextStyles.bodySmall(isDark).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Uptime',
                              style: AppTextStyles.labelSmall(isDark),
                            ),
                            Text(
                              Formatters.formatUptime(Duration(seconds: _server.uptimeSeconds)),
                              style: AppTextStyles.code(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resource Metrics
                  Text(
                    'Resource Consumption',
                    style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  _buildResourceGaugeCard(
                    title: 'CPU Load (${_server.cpuCores} Cores)',
                    subtitle: _server.cpuModel,
                    percent: _server.cpuUsagePercent,
                    details: '${(_server.cpuUsagePercent * 100).toStringAsFixed(1)}% utilized',
                    icon: Icons.memory_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  _buildResourceGaugeCard(
                    title: 'RAM Memory',
                    subtitle: '${_server.ramUsedGb.toStringAsFixed(1)} GB used of ${_server.ramTotalGb.toInt()} GB',
                    percent: _server.ramUsagePercent,
                    details: '${(_server.ramUsagePercent * 100).toStringAsFixed(1)}%',
                    icon: Icons.developer_board_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  _buildResourceGaugeCard(
                    title: 'NVMe Storage',
                    subtitle: '${_server.storageUsedGb.toInt()} GB used of ${_server.storageTotalGb.toInt()} GB',
                    percent: _server.storageUsagePercent,
                    details: '${(_server.storageUsagePercent * 100).toStringAsFixed(1)}%',
                    icon: Icons.storage_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  // Network Throughput Card
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
                        Row(
                          children: [
                            const Icon(Icons.swap_vert_rounded, size: 20, color: AppColors.info),
                            const SizedBox(width: 8),
                            Text(
                              'Network Telemetry',
                              style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              '${_server.networkUsageMbps.toInt()} Mbps',
                              style: AppTextStyles.code(isDark).copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Inbound (RX)', style: AppTextStyles.labelSmall(isDark)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_server.networkInMbps.toInt()} Mbps',
                                      style: AppTextStyles.code(isDark).copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                                  borderRadius: AppRadius.borderMd,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Outbound (TX)', style: AppTextStyles.labelSmall(isDark)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_server.networkOutMbps.toInt()} Mbps',
                                      style: AppTextStyles.code(isDark).copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Server Actions
                  Text(
                    'Node Controls & Power',
                    style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Restart Service',
                          icon: Icons.restart_alt_rounded,
                          isLoading: _isActionInProgress,
                          onPressed: () => _handleAction(
                            'Restart Service',
                            () => ref.read(serverControllerProvider.notifier).restartServer(_server.id),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppOutlinedButton(
                          text: 'Reboot Node',
                          icon: Icons.power_settings_new_rounded,
                          isLoading: _isActionInProgress,
                          onPressed: () => _handleAction(
                            'Reboot Server',
                            () => ref.read(serverControllerProvider.notifier).rebootServer(_server.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppOutlinedButton(
                    text: 'Open SSH Terminal Session',
                    icon: Icons.terminal_rounded,
                    onPressed: () {
                      context.showSnackBar('SSH session initialized: ssh root@${_server.ipAddress}');
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

  Widget _buildResourceGaugeCard({
    required String title,
    required String subtitle,
    required double percent,
    required String details,
    required IconData icon,
    required bool isDark,
  }) {
    Color progressColor;
    if (percent > 0.85) {
      progressColor = AppColors.error;
    } else if (percent > 0.70) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Container(
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
          Row(
            children: [
              Icon(icon, size: 20, color: progressColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                details,
                style: AppTextStyles.titleSmall(isDark).copyWith(
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(isDark).copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
