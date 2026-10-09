import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/hosting_model.dart';
import '../../../shared/components/hosting_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import 'hosting_controller.dart';

class HostingScreen extends ConsumerStatefulWidget {
  const HostingScreen({super.key});

  @override
  ConsumerState<HostingScreen> createState() => _HostingScreenState();
}

class _HostingScreenState extends ConsumerState<HostingScreen> {
  int _selectedTabIndex = 0;
  bool _showForm = false;

  // Exact 2 sub-tabs from Photo 5
  final List<String> _tabs = [
    'Add Hosting',
    'Add Mapping',
  ];

  final List<IconData> _tabIcons = [
    Icons.language_rounded,
    Icons.link_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(hostingControllerProvider);

    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (isDesktop) _buildAcmeTopBar(context, isDark),
            AppHeader(
              title: 'Hosting',
              subtitle: 'Web servers, managed environments & bandwidth',
              actions: [
                IconButton(
                  tooltip: 'Deploy New Plan',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                  onPressed: () => _showAddHostingSheet(context, ref, isDark, false),
                ),
              ],
            ),

            // Sub Tab Bar (Matches Photo 5: Add Hosting & Add Mapping)
            SubTabBar(
              tabs: _tabs,
              icons: _tabIcons,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),

            // Tab Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedTabIndex == 0
                    ? _buildAddHostingTab(context, state, isDark)
                    : _buildAddMappingTab(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Add Hosting Tab (Matches Photo 5)
  Widget _buildAddHostingTab(
    BuildContext context,
    HostingState state,
    bool isDark,
  ) {
    if (_showForm) {
      return _buildHostingForm(context, isDark);
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Add Hosting',
          style: AppTextStyles.titleMedium(isDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the type of configuration you want to perform.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 320,
              child: _buildHostingOptionCard(
                title: 'Add New Hosting',
                description: 'Create and configure a standalone web hosting account.',
                buttonText: 'Continue →',
                icon: Icons.language_rounded,
                iconBgColor: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                isDark: isDark,
                onTap: () => setState(() => _showForm = true),
              ),
            ),
            SizedBox(
              width: 320,
              child: _buildHostingOptionCard(
                title: 'Add Hosting with Server',
                description: 'Provision a new server and configure its hosting.',
                buttonText: 'Continue →',
                icon: Icons.dns_rounded,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                isDark: isDark,
                onTap: () => setState(() => _showForm = true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostingOptionCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Illustration / Icon container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.16) : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            title,
            style: AppTextStyles.titleMedium(isDark).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            description,
            style: AppTextStyles.bodySmall(isDark).copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, {String? hint, String? value, required bool isDark, Widget? suffix, double? width, IconData? prefixIcon, bool isActive = false}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.replaceAll(' *', ''), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
              if (label.contains('*')) const Text(' *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: isActive ? const Color(0xFF818CF8) : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 16, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value ?? hint ?? '',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: value != null ? (isActive ? const Color(0xFF4F46E5) : (isDark ? Colors.white : const Color(0xFF0F172A))) : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffix != null) suffix,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: isDark ? Colors.white : const Color(0xFF334155)),
      ),
    );
  }

  Widget _buildHostingForm(BuildContext context, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _showForm = false),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Add Hosting', style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text('Provision and manage web hosting accounts across your server infrastructure.', style: AppTextStyles.bodySmall(isDark)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                        const SizedBox(width: 12),
                        Text('Hosting Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    _buildSectionTitle('INFRASTRUCTURE SELECTION', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInput('Service Provider *', value: 'Select Service Provider', prefixIcon: Icons.language, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Hosting Type', value: 'Select Hosting Type', prefixIcon: Icons.hexagon_outlined, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('IP Address', hint: '# e.g. 192.168.1.1', isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Status', value: 'Active', prefixIcon: Icons.show_chart, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Control Panel', value: 'cPanel', prefixIcon: Icons.hexagon_outlined, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                      ],
                    ),
                    
                    _buildSectionTitle('DOMAIN & ACCOUNT DETAILS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInput('Hosting Name *', hint: 'e.g. Acme Web Hosting', prefixIcon: Icons.language, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Username', hint: 'lovelylohit003@gmail.com', prefixIcon: Icons.person_outline, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Password', value: '********', prefixIcon: Icons.lock_outline, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Customer ID', hint: 'e.g. CUST-10293', prefixIcon: Icons.person_outline, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Nameserver 1', hint: 'e.g. ns1.example.com', prefixIcon: Icons.language, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Nameserver 2', hint: 'e.g. ns2.example.com', prefixIcon: Icons.language, isDark: isDark, width: isMobile ? double.infinity : 300),
                      ],
                    ),
                    
                    _buildSectionTitle('RESOURCE ALLOCATION', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInput('Storage / Harddisk', hint: 'e.g. 100 GB NVMe', prefixIcon: Icons.sd_storage_outlined, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Bandwidth Limit', hint: 'e.g. 1 TB / Unmetered', prefixIcon: Icons.show_chart, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Addon Domain Limit', hint: 'e.g. 5', prefixIcon: Icons.link, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Subdomain Limit', hint: 'e.g. 10', prefixIcon: Icons.link, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Email Accounts Limit', hint: 'e.g. 20', prefixIcon: Icons.person_outline, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('FTP Accounts Limit', hint: 'e.g. 5', prefixIcon: Icons.hexagon_outlined, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('MySQL Database Limit', hint: 'e.g. 5', prefixIcon: Icons.storage, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Inode Limit', hint: 'e.g. 250000', prefixIcon: Icons.sd_storage_outlined, isDark: isDark, width: isMobile ? double.infinity : 300),
                      ],
                    ),
                    
                    _buildSectionTitle('TECHNICAL SPECIFICATIONS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInput('Web Server', value: 'Apache', prefixIcon: Icons.dns_outlined, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('PHP Version', value: 'PHP 8.2', prefixIcon: Icons.code, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Database Type', value: 'MySQL', prefixIcon: Icons.storage, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('SSL Certificate', value: 'Let\'s Encrypt (Free)', prefixIcon: Icons.verified_user_outlined, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('SSH Port', value: '>_ 22', prefixIcon: Icons.terminal, isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Expiry Date', hint: 'mm/dd/yyyy', prefixIcon: Icons.calendar_today, suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('SSH Access', value: 'No', prefixIcon: Icons.terminal, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Backup Enabled', value: 'No', prefixIcon: Icons.sd_storage_outlined, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Created Date', hint: 'mm/dd/yyyy', prefixIcon: Icons.calendar_today, suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                        _buildInput('Renewal Date', hint: 'mm/dd/yyyy', prefixIcon: Icons.calendar_today, suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Active Hostings
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                        const SizedBox(width: 12),
                        Text('Active Hostings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(24)),
                          child: const Text('1 Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildActiveHostingCard(context, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
        
        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last deployed: Recently', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      const Text('1 Hostings Configured', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _showForm = false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 14),
                    ),
                    child: const Text('Discard Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _showForm = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 14),
                    ),
                    child: const Text('Save Configuration', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHostingCard(BuildContext context, bool isDark) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('demonewhosting', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.link, size: 12, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text('No do...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showHostingDialog(context, isDark, isEdit: false),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showHostingDialog(context, isDark, isEdit: true),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text('root', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IP Address:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text('122.178.13.18', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.hexagon_outlined, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text('vps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const Text('ACTIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF22C55E))),
            ],
          ),
        ],
      ),
    );
  }

  void _showHostingDialog(BuildContext context, bool isDark, {required bool isEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        final inputWidth2Col = isMobile ? double.infinity : 250.0;
        final inputWidth3Col = isMobile ? double.infinity : 160.0;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 600,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isEdit 
                        ? const Icon(Icons.edit, color: Color(0xFF4F46E5), size: 20)
                        : const Icon(Icons.visibility, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Edit Hosting Details' : 'View Hosting Details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          ),
                          const Text('demonewhosting', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildSectionTitle('General Details', isDark),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInput('Hosting Name', value: 'demonewhosting', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Hosting Type', value: 'vps', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Status', value: 'Active', isDark: isDark, width: inputWidth2Col),
                          _buildInput('IP Address', value: '122.178.13.18', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Service Provider', value: 'godaddy', isDark: isDark, width: inputWidth2Col),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      _buildSectionTitle('Account & Domain Details', isDark),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInput('Username', value: 'root', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Password', value: '******', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Control Panel', value: 'cPanel', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Customer ID', value: 'cust-0001', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Nameserver 1', value: 'ns1.com', isDark: isDark, width: inputWidth2Col),
                          _buildInput('Nameserver 2', value: 'ns2.com', isDark: isDark, width: inputWidth2Col),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      _buildSectionTitle('Resource Limits', isDark),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInput('Storage', value: '100 gb', isDark: isDark, width: inputWidth3Col),
                          _buildInput('Bandwidth', value: '1 tp', isDark: isDark, width: inputWidth3Col),
                          _buildInput('Subdomains', value: '10', isDark: isDark, width: inputWidth3Col),
                          _buildInput('Email Accounts', value: '20', isDark: isDark, width: inputWidth3Col),
                          _buildInput('FTP Accounts', value: '8', isDark: isDark, width: inputWidth3Col),
                          _buildInput('MySQL DBs', value: '8', isDark: isDark, width: inputWidth3Col),
                          _buildInput('Addon Domains', value: '5', isDark: isDark, width: inputWidth3Col),
                          _buildInput('Inode Limit', value: '50000', isDark: isDark, width: inputWidth3Col),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      _buildSectionTitle('Technical Specifications', isDark),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInput('Web Server', value: 'Apache', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('PHP Version', value: 'PHP 8.3', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('Database', value: 'MySQL', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('SSL Certificate', value: 'Let\'s Encrypt (Free)', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('SSH Access', value: 'No', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('Backup Enabled', value: 'No', suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('Created Date', value: '07/07/2026', suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('Renewal Date', value: '06/07/2027', suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: inputWidth2Col),
                          _buildInput('Expiry Date', value: '06/07/2027', suffix: const Icon(Icons.calendar_today, size: 16), isDark: isDark, width: inputWidth2Col),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(isEdit ? 'Save Changes' : 'Edit Hosting', style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ),
                      if (isEdit) const SizedBox(height: 12),
                      if (isEdit)
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      if (isEdit) const SizedBox(height: 12),
                      if (isEdit)
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                          label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                    ],
                  )
                else
                  Row(
                    children: [
                      if (isEdit)
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                          label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      const Spacer(),
                      if (isEdit)
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      if (isEdit) const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(isEdit ? 'Save Changes' : 'Edit Hosting', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Add Mapping Tab (Matches Photo 5)
  Widget _buildAddMappingTab(BuildContext context, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Domain to Hosting Mapping',
          style: AppTextStyles.titleMedium(isDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a hosting account and a domain to map them together.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 24),

        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildInput('Select Hosting Account *', value: '-- Choose Hosting --', prefixIcon: Icons.storage, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                  if (!isMobile)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.link, color: Color(0xFF94A3B8), size: 20),
                      ),
                    ),
                  _buildInput('Select Domains *', value: 'Select Domains...', prefixIcon: Icons.language, suffix: const Icon(Icons.keyboard_arrow_down, size: 16), isDark: isDark, width: isMobile ? double.infinity : 300),
                ],
              ),
              const SizedBox(height: 32),
              
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Container(
                    width: isMobile ? double.infinity : 300,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storage, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Hosting Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Select a hosting account to view details', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  Container(
                    width: isMobile ? double.infinity : 300,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.language, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Domain Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Select domains to view details', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: null, // Disabled state
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD5E1), // Gray for disabled
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save Mapping', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        Text(
          'Configured Mappings',
          style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'View and manage your active domain to hosting connections.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
          ),
          child: Center(
            child: Text('No mappings configured yet.', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8))),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  void _showAddHostingSheet(BuildContext context, WidgetRef ref, bool isDark, bool includeServer) {
    final formKey = GlobalKey<FormState>();
    final serviceNameCtrl = TextEditingController(text: includeServer ? 'Dedicated VPS Node' : 'Managed App Engine');
    final domainCtrl = TextEditingController(text: 'app.datacenter.cloud');
    final planNameCtrl = TextEditingController(text: includeServer ? 'Bare Metal Hypervisor' : 'Standard Web Hosting');
    final ipCtrl = TextEditingController(text: '198.51.100.${30 + (DateTime.now().millisecond % 50)}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    includeServer ? 'Deploy Hosting with Server' : 'Deploy New Standalone Hosting',
                    style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    includeServer
                        ? 'Provisions compute server instance and sets up containerized environment.'
                        : 'Sets up isolated web workspace on current shared compute pool.',
                    style: AppTextStyles.bodySmall(isDark),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Service Name',
                    hintText: 'e.g. Staging API Microservice',
                    controller: serviceNameCtrl,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Primary Domain / Host',
                    hintText: 'staging.datacenter.cloud',
                    controller: domainCtrl,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Tier / Plan',
                    hintText: 'Standard Dedicated VPS',
                    controller: planNameCtrl,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Assigned Static IP',
                    hintText: '198.51.100.99',
                    controller: ipCtrl,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: includeServer ? 'Provision Server & Hosting' : 'Provision Environment',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newHost = HostingModel(
                          id: 'host-${DateTime.now().millisecondsSinceEpoch}',
                          serviceName: serviceNameCtrl.text.trim(),
                          planName: planNameCtrl.text.trim(),
                          domain: domainCtrl.text.trim(),
                          ipAddress: ipCtrl.text.trim(),
                          status: 'active',
                          storageUsedGb: 2.4,
                          storageTotalGb: includeServer ? 250.0 : 50.0,
                          bandwidthUsedGb: 15.0,
                          bandwidthTotalGb: includeServer ? 2000.0 : 500.0,
                          sslActive: true,
                          phpVersion: '8.3',
                          expiryDate: DateTime.now().add(const Duration(days: 365)),
                          createdAt: DateTime.now(),
                        );
                        ref.read(hostingControllerProvider.notifier).addHosting(newHost);
                        Navigator.pop(ctx);
                        context.showSnackBar('Hosting plan provisioned successfully');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Authentic Acme Brand Top Bar
  Widget _buildAcmeTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          // Acme Logo Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Acme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 32),
          
          // Navigation Links
          Expanded(
            child: Row(
              children: [
                _buildTopNavLink(title: 'Dashboard', route: RouteNames.dashboard, isDark: isDark, context: context),
                _buildTopNavLink(title: 'Data Center', route: RouteNames.dataCenter, isDark: isDark, context: context),
                _buildTopNavLink(title: 'Server', route: RouteNames.servers, isDark: isDark, context: context),
                _buildTopNavLink(title: 'Domain', route: RouteNames.domains, isDark: isDark, context: context),
                _buildTopNavLink(title: 'Hosting', route: RouteNames.hosting, isActive: true, isDark: isDark, context: context),
                _buildTopNavLink(title: 'Dynamic Field', route: RouteNames.dynamicField, isDark: isDark, context: context),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: Icon(Icons.search, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavLink({
    required String title,
    required String route,
    bool isActive = false,
    required bool isDark,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(bottom: BorderSide(color: Color(0xFF6366F1), width: 2))
              : null,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(Icons.circle, size: 4, color: const Color(0xFF6366F1)),
            ]
          ],
        ),
      ),
    );
  }
}
