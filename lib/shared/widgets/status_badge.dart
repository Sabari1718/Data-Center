import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

enum BadgeSize { small, medium }

class StatusBadge extends StatelessWidget {
  final String status;
  final BadgeSize size;
  final bool showDot;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
    this.showDot = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase().trim();
    Color bg;
    Color fg;

    if (s == 'active' || s == 'running' || s == 'online' || s == 'healthy') {
      bg = AppColors.successSubtle;
      fg = AppColors.successDark;
    } else if (s == 'warning' || s == 'degraded' || s == 'expiring_soon') {
      bg = AppColors.warningSubtle;
      fg = AppColors.warningDark;
    } else if (s == 'stopped' || s == 'offline' || s == 'critical' || s == 'expired' || s == 'suspended') {
      bg = AppColors.errorSubtle;
      fg = AppColors.errorDark;
    } else {
      // Maintenance, pending, etc.
      bg = AppColors.infoSubtle;
      fg = AppColors.infoDark;
    }

    final isSmall = size == BadgeSize.small;
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    final fontSize = isSmall ? 10.0 : 12.0;
    final dotSize = isSmall ? 5.0 : 6.0;

    final displayText = customLabel ??
        (status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
            : 'Unknown');

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            displayText,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
