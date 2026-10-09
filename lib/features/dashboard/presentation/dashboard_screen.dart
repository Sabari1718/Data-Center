import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../shared/components/dashboard_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Overview',
    'Metrics',
    'Activity Log',
    'System Status',
  ];

  final List<IconData> _tabIcons = [
    Icons.grid_view_rounded,
    Icons.bar_chart_rounded,
    Icons.show_chart_rounded,
    Icons.check_circle_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final authState = ref.watch(authControllerProvider);
    final dashboardState = ref.watch(dashboardControllerProvider);

    final userName = authState.user?.name ?? AppConstants.defaultUserName;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Acme Brand Top Navigation Bar
            _buildTopBar(context, ref, isDark),

            // Top sub-tabs: Overview, Metrics, Activity Log, System Status
            SubTabBar(
              tabs: _tabs,
              icons: _tabIcons,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),

            // Content based on selected sub-tab
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildTabContent(context, dashboardState, userName, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Authentic Acme Brand Top Bar matching the web screenshots
  Widget _buildTopBar(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Acme Brand Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Acme',
            style: AppTextStyles.titleMedium(isDark).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Search Action
          IconButton(
            tooltip: 'Search',
            icon: Icon(
              Icons.search_rounded,
              size: 22,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              context.showSnackBar('Search telemetry & resources');
            },
          ),
          // Dark / Light Theme Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
              color: isDark ? AppColors.warning : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          // Profile Action
          IconButton(
            tooltip: 'Profile & Account',
            icon: Icon(
              Icons.person_outline_rounded,
              size: 22,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              context.push(RouteNames.profile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    DashboardState dashboardState,
    String userName,
    bool isDark,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(context, dashboardState, userName, isDark);
      case 1:
        return _buildMetricsTab(context, isDark);
      case 2:
        return _buildActivityLogTab(context, isDark);
      case 3:
        return _buildSystemStatusTab(context, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ===========================================================================
  // 1. OVERVIEW TAB (Matches Screenshot 1)
  // ===========================================================================
  Widget _buildOverviewTab(
    BuildContext context,
    DashboardState dashboardState,
    String userName,
    bool isDark,
  ) {
    if (!dashboardState.hasLayout) {
      return _buildEmptyWorkspace(context, userName, isDark);
    }

    return dashboardState.data.when(
      loading: () => _buildLoadingState(isDark),
      error: (err, _) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      ),
      data: (data) {
        if (data == null) {
          return _buildEmptyWorkspace(context, userName, isDark);
        }
        return _buildActiveDashboard(context, data, userName, isDark);
      },
    );
  }

  // Workspace Empty Layout with 3 Feature Cards (Matches Screenshot 1)
  Widget _buildEmptyWorkspace(BuildContext context, String userName, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Text(
            'Dashboard',
            style: AppTextStyles.titleLarge(isDark).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
              children: [
                const TextSpan(text: 'Welcome, '),
                TextSpan(
                  text: userName,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '. Setup your workspace modules.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Large Center Empty State Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 34.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Dashed blueprint wireframe illustration matching Screenshot 1
                _DottedBlueprintIllustration(isDark: isDark),
                const SizedBox(height: 22),

                Text(
                  'Your workspace is empty',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "You haven't activated any system modules or overview cards yet.\nStart by generating the default layout template for your account.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(isDark).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // Responsive action buttons (Wraps safely without overflow on narrow screens)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ref.read(dashboardControllerProvider.notifier).loadDefaultLayout();
                        context.showSnackBar('Default workspace layout activated!');
                      },
                      child: const Text(
                        'Load Default Layout',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFF3F4F6),
                        foregroundColor: isDark ? Colors.white : const Color(0xFF374151),
                        side: BorderSide(
                          color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _showConfigureCardsDialog(context, ref, isDark);
                      },
                      child: const Text(
                        'Configure Cards',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3 Feature Cards (Workspace Monitor, API Gateways, Account Controls)
          _buildOverviewFeatureCard(
            icon: Icons.desktop_windows_outlined,
            title: 'Workspace Monitor',
            description: 'Attach system widgets, server logs, and memory performance graphs.',
            isDark: isDark,
            onTap: () {
              setState(() => _selectedTabIndex = 1); // Jump to Metrics
            },
          ),
          const SizedBox(height: 12),

          _buildOverviewFeatureCard(
            icon: Icons.layers_outlined,
            title: 'API Gateways',
            description: 'Connect webhook endpoints, security routes, and manage throttle configurations.',
            isDark: isDark,
            onTap: () {
              setState(() => _selectedTabIndex = 3); // Jump to System Status
            },
          ),
          const SizedBox(height: 12),

          _buildOverviewFeatureCard(
            icon: Icons.settings_outlined,
            title: 'Account Controls',
            description: 'Manage tenant variables, dark theme parameters, and configure active administrators.',
            isDark: isDark,
            onTap: () {
              context.push(RouteNames.settings);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOverviewFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall(isDark).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall(isDark).copyWith(
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. METRICS TAB (Matches Screenshot 2)
  // ===========================================================================
  Widget _buildMetricsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Text(
            'System Metrics',
            style: AppTextStyles.titleLarge(isDark).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time load indicators and resources status.',
            style: AppTextStyles.bodyMedium(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // 4 Metric Cards (Responsive: 2-column on standard mobile, 1-column on narrow screens)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;

              final card1 = _buildSystemMetricCard(
                title: 'CPU Load',
                value: '24%',
                badgeText: 'PULSING',
                badgeColor: const Color(0xFFEA580C),
                badgeBg: const Color(0xFFFFF7ED),
                progress: 0.24,
                progressColor: const Color(0xFFEA580C),
                isDark: isDark,
              );

              final card2 = _buildSystemMetricCard(
                title: 'Memory Usage',
                value: '3.2 GB',
                valueSecondary: ' / 8 GB',
                progress: 0.40,
                progressColor: const Color(0xFF6366F1),
                isDark: isDark,
              );

              final card3 = _buildSystemMetricCard(
                title: 'Active Users',
                value: '1,842',
                badgeText: 'ONLINE',
                badgeColor: const Color(0xFF10B981),
                badgeBg: const Color(0xFFECFDF5),
                progress: 0.60,
                progressColor: const Color(0xFF10B981),
                isDark: isDark,
              );

              final card4 = _buildSystemMetricCard(
                title: 'Latency',
                value: '18 ms',
                badgeText: 'OPTIMAL',
                badgeColor: const Color(0xFF10B981),
                badgeBg: const Color(0xFFECFDF5),
                progress: 0.20,
                progressColor: const Color(0xFF10B981),
                isDark: isDark,
              );

              if (isCompact) {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 12),
                    card2,
                    const SizedBox(height: 12),
                    card3,
                    const SizedBox(height: 12),
                    card4,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 12),
                      Expanded(child: card2),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: card3),
                      const SizedBox(width: 12),
                      Expanded(child: card4),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSystemMetricCard({
    required String title,
    required String value,
    String? valueSecondary,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBg,
    required double progress,
    required Color progressColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleLarge(isDark).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                if (valueSecondary != null) ...[
                  Text(
                    valueSecondary,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (badgeText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? badgeColor!.withValues(alpha: 0.2)
                          : (badgeBg ?? badgeColor!.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. ACTIVITY LOG TAB (Matches Screenshot 3)
  // ===========================================================================
  Widget _buildActivityLogTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Text(
            'Activity Log',
            style: AppTextStyles.titleLarge(isDark).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chronological history of security events and transactions.',
            style: AppTextStyles.bodyMedium(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // 4 Activity Items matching Screenshot 3
          _buildActivityLogCard(
            letter: 'Y',
            avatarBg: const Color(0xFF6366F1),
            email: 'yudeshprasath@gmail.com',
            subtitle: 'Successful login session initialized',
            time: 'Just now',
            isDark: isDark,
          ),
          _buildActivityLogCard(
            letter: 'A',
            avatarBg: const Color(0xFF10B981),
            email: 'admin@acme.com',
            subtitle: "Created API key 'production-secret-v3'",
            time: '18 mins ago',
            isDark: isDark,
          ),
          _buildActivityLogCard(
            letter: 'Y',
            avatarBg: const Color(0xFF6366F1),
            email: 'yudeshprasath@gmail.com',
            subtitle: 'Updated primary display theme settings',
            time: '1 hour ago',
            isDark: isDark,
          ),
          _buildActivityLogCard(
            letter: 'S',
            avatarBg: const Color(0xFF64748B),
            email: 'system@acme.com',
            subtitle: 'Automatic database backup archive created',
            time: '4 hours ago',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActivityLogCard({
    required String letter,
    required Color avatarBg,
    required String email,
    required String subtitle,
    required String time,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        email,
                        style: AppTextStyles.titleSmall(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppTextStyles.bodySmall(isDark).copyWith(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium(isDark).copyWith(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. SYSTEM STATUS TAB (Matches Screenshot 4)
  // ===========================================================================
  Widget _buildSystemStatusTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle
          Text(
            'System Status',
            style: AppTextStyles.titleLarge(isDark).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'State of operational core APIs and databases.',
            style: AppTextStyles.bodyMedium(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // 4 Status Items matching Screenshot 4
          _buildSystemStatusItemCard(
            name: 'API Gateway',
            latency: '8ms latency',
            status: 'Operational',
            isOperational: true,
            isDark: isDark,
          ),
          _buildSystemStatusItemCard(
            name: 'Database Cluster',
            latency: '2ms latency',
            status: 'Operational',
            isOperational: true,
            isDark: isDark,
          ),
          _buildSystemStatusItemCard(
            name: 'Identity Manager',
            latency: '12ms latency',
            status: 'Operational',
            isOperational: true,
            isDark: isDark,
          ),
          _buildSystemStatusItemCard(
            name: 'Cache Layer',
            latency: '45ms latency',
            status: 'Degraded Performance',
            isOperational: false,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSystemStatusItemCard({
    required String name,
    required String latency,
    required String status,
    required bool isOperational,
    required bool isDark,
  }) {
    final statusColor = isOperational ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing status dot
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.22),
            ),
            child: Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.titleSmall(isDark).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Latency and Status (wraps safely without overflow on narrow screens)
          Flexible(
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  latency,
                  style: AppTextStyles.bodySmall(isDark).copyWith(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTIVE TELEMETRY DASHBOARD (When layout is configured/activated)
  // ===========================================================================
  Widget _buildActiveDashboard(
    BuildContext context,
    DashboardModel data,
    String userName,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          // Switch back to empty workspace option
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Workspace View',
                style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(dashboardControllerProvider.notifier).resetToEmptyState();
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Empty Layout'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // System Health Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF13271D), Color(0xFF0F1E17)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                    ),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'System Health: ${data.systemHealthScore}%',
                              style: AppTextStyles.titleSmall(isDark).copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF6EE7B7) : AppColors.successDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const StatusBadge(status: 'healthy', size: BadgeSize.small),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'All primary clusters & data centers operational without major incidents.',
                        style: AppTextStyles.bodySmall(isDark).copyWith(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Overview Metrics 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              DashboardCard(
                title: 'Total Servers',
                value: '${data.totalServers}',
                subtitle: '${data.activeServers} active • ${data.warningServers} warn',
                icon: Icons.dns_rounded,
                iconColor: AppColors.primary,
                onTap: () => context.push(RouteNames.servers),
              ),
              DashboardCard(
                title: 'Data Centers',
                value: '${data.dataCentersCount}',
                subtitle: '4 regions globally',
                icon: Icons.apartment_rounded,
                iconColor: AppColors.secondary,
                onTap: () => context.push(RouteNames.dataCenter),
              ),
              DashboardCard(
                title: 'Hosting Usage',
                value: '${(data.hostingUsagePercent * 100).toInt()}%',
                subtitle: 'Storage & bandwidth',
                icon: Icons.cloud_queue_rounded,
                iconColor: AppColors.info,
                onTap: () => context.push(RouteNames.hosting),
              ),
              DashboardCard(
                title: 'Domains',
                value: '${data.totalDomains}',
                subtitle: '35 auto-renew enabled',
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => context.push(RouteNames.domains),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Server Status Overview
          _buildServerStatusSection(data, isDark, context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildServerStatusSection(DashboardModel data, bool isDark, BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Server Status Overview',
                style: AppTextStyles.titleSmall(isDark).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => context.push(RouteNames.servers),
                child: Row(
                  children: [
                    Text(
                      'Manage Fleet',
                      style: AppTextStyles.labelSmall(isDark).copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatusPill(
                  label: 'Running',
                  count: data.activeServers,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusPill(
                  label: 'Warning',
                  count: data.warningServers,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusPill(
                  label: 'Stopped',
                  count: data.offlineServers,
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextStyles.titleMedium(isDark).copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall(isDark).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        LoadingSkeleton.card(height: 120),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: LoadingSkeleton.card(height: 110)),
            const SizedBox(width: 12),
            Expanded(child: LoadingSkeleton.card(height: 110)),
          ],
        ),
        const SizedBox(height: 16),
        LoadingSkeleton.card(height: 160),
      ],
    );
  }

  void _showConfigureCardsDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Workspace Modules',
                style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Select which metric cards and real-time telemetry modules to activate on your dashboard.',
                style: AppTextStyles.bodyMedium(isDark),
              ),
              const SizedBox(height: 16),
              _buildConfigTile('Server Fleet Telemetry', true, isDark),
              _buildConfigTile('Data Centers & Rack Maps', true, isDark),
              _buildConfigTile('Cloud Hosting & Storage', true, isDark),
              _buildConfigTile('Global DNS & Domain Registrars', true, isDark),
              const SizedBox(height: 20),
              AppButton(
                text: 'Activate Selected Modules',
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(dashboardControllerProvider.notifier).loadDefaultLayout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigTile(String title, bool checked, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.bodyMedium(isDark).copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// =============================================================================
// Custom Dashed Blueprint Wireframe Illustration Widget (Matches Screenshot 1)
// =============================================================================
class _DottedBlueprintIllustration extends StatelessWidget {
  final bool isDark;
  const _DottedBlueprintIllustration({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? const Color(0xFF4338CA) : const Color(0xFFC7D2FE);
    final dotColor = isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5);

    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1B4B).withValues(alpha: 0.4)
            : const Color(0xFFEEF2FF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        painter: _DashedBlueprintPainter(
          borderColor: borderColor,
          dotColor: dotColor,
        ),
      ),
    );
  }
}

class _DashedBlueprintPainter extends CustomPainter {
  final Color borderColor;
  final Color dotColor;

  _DashedBlueprintPainter({required this.borderColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // Outer dashed rounded border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(8),
    );
    _drawDashedRRect(canvas, rrect, paint);

    // Header divider line
    _drawDashedLine(canvas, const Offset(3, 22), Offset(size.width - 3, 22), paint);

    // Circle radio dot in header
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(16, 12), 3, dotPaint);

    final dotRingPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(16, 12), 5.5, dotRingPaint);

    // Header dashed text bar
    _drawDashedLine(canvas, const Offset(26, 12), Offset(size.width - 12, 12), paint);

    // Body layout wireframe bars
    _drawDashedLine(canvas, const Offset(12, 36), Offset(size.width - 12, 36), paint);
    _drawDashedLine(canvas, const Offset(12, 48), Offset(size.width - 24, 48), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    final dx = p2.dx - p1.dx;
    final count = (dx.abs() / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < count; i++) {
      final startX = p1.dx + i * (dashWidth + dashSpace);
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(startX + dashWidth, p1.dy),
        paint,
      );
    }
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashWidth = 4.0;
      const dashSpace = 3.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length) ? dashWidth : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBlueprintPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor || oldDelegate.dotColor != dotColor;
  }
}
