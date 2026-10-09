import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/domain_model.dart';
import '../../../shared/components/domain_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import 'domain_controller.dart';

class DomainsScreen extends ConsumerStatefulWidget {
  const DomainsScreen({super.key});

  @override
  ConsumerState<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends ConsumerState<DomainsScreen> {
  int _selectedTabIndex = 0;

  // Exact 2 sub-tabs from Photo 4
  final List<String> _tabs = [
    'Add Domain',
    'Add Subdomain',
  ];

  final List<IconData> _tabIcons = [
    Icons.language_rounded,
    Icons.link_rounded,
  ];

  // Add Domain Form
  final _domainNameCtrl = TextEditingController(text: 'cloud-datacenter.io');
  final _registrarCtrl = TextEditingController(text: 'Cloudflare Registrar');

  // Add Subdomain Form
  final _subdomainPrefixCtrl = TextEditingController(text: 'api');
  String _parentDomain = 'datacenter.cloud';
  String _recordType = 'A';
  final _targetDestinationCtrl = TextEditingController(text: '198.51.100.24');
  bool _proxyStatus = true;

  final List<String> _parentDomains = [
    'datacenter.cloud',
    'cloud-datacenter.io',
    'enterprise-cluster.com',
  ];

  final List<String> _recordTypes = ['A', 'CNAME', 'AAAA', 'TXT', 'MX'];

  bool _whatsappSelected = true;
  bool _emailSelected = false;
  bool _messageSelected = false;

  @override
  void dispose() {
    _domainNameCtrl.dispose();
    _registrarCtrl.dispose();
    _subdomainPrefixCtrl.dispose();
    _targetDestinationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _selectedTabIndex == 0 ? 'Add Domain' : 'Add Subdomain',
              subtitle: _selectedTabIndex == 0 ? 'Register and track your domain portfolios and renewal dates.' : 'Create and track subdomains for your existing primary domain portfolio.',
              actions: const [],
            ),

            if (isMobile)
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)))),
                child: Row(
                  children: [
                    Expanded(child: _buildTopMenuItem('Add Domain', Icons.language_rounded, _selectedTabIndex == 0, () => setState(() => _selectedTabIndex = 0), isDark)),
                    Expanded(child: _buildTopMenuItem('Add Subdomain', Icons.link_rounded, _selectedTabIndex == 1, () => setState(() => _selectedTabIndex = 1), isDark)),
                  ],
                ),
              ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar navigation (Desktop only)
                  if (!isMobile)
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Text('DOMAIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                          ),
                          _buildSideMenuItem('Add Domain', Icons.language_rounded, _selectedTabIndex == 0, () => setState(() => _selectedTabIndex = 0), isDark),
                          _buildSideMenuItem('Add Subdomain', Icons.link_rounded, _selectedTabIndex == 1, () => setState(() => _selectedTabIndex = 1), isDark),
                        ],
                      ),
                    ),

                  // Main Content
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            children: [
                              _selectedTabIndex == 0 ? _buildAddDomainTab(context, isDark, isMobile) : _buildAddSubdomainTab(context, isDark, isMobile),
                            ],
                          ),
                        ),
                        // Fixed Footer
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
                            color: isDark ? AppColors.cardDark : Colors.white,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              if (!isMobile)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Last saved: Never', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                    const SizedBox(height: 4),
                                    Text(_selectedTabIndex == 0 ? '24 Domains Configured' : '22 Subdomains Configured', style: TextStyle(fontSize: 12, color: const Color(0xFF64748B))),
                                  ],
                                ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0F172A),
                                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 14),
                                    ),
                                    child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 14),
                                    ),
                                    child: Text(_selectedTabIndex == 0 ? 'Save Domain' : 'Save Subdomain', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMenuItem(String title, IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF4F46E5) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenuItem(String title, IconData icon, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4F46E5) : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            if (isSelected) const Spacer(),
            if (isSelected) const Icon(Icons.circle, size: 6, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, {String? hint, String? value, bool isDark = false, Widget? suffix, double width = double.infinity}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          height: 44,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: value,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              if (suffix != null) Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
            ],
          ),
        ),
      ],
    );
  }

  // 1. Add Domain Tab
  Widget _buildAddDomainTab(BuildContext context, bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Domain Configuration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A)))),
                ],
              ),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildInput('Domain Name', hint: 'e.g. acme-corp', isDark: isDark),
                const SizedBox(height: 16),
                _buildInput('Extension', hint: 'Select Extension', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16)),
                const SizedBox(height: 16),
                _buildInput('Custom Extension', hint: '.xyz', isDark: isDark, suffix: Text('Add', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13))),
                const SizedBox(height: 16),
                _buildInput('Purchase Date', hint: 'mm/dd/yyyy', isDark: isDark, suffix: const Icon(Icons.calendar_today_outlined, size: 16)),
                const SizedBox(height: 16),
                _buildInput('Duration (Years)', hint: '1 Year', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16)),
                const SizedBox(height: 16),
                _buildInput('Domain Service Registrar', hint: 'Select Registrar Provider', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16)),
              ] else ...[
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildInput('Domain Name', hint: 'e.g. acme-corp', isDark: isDark)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildInput('Extension', hint: 'Select Extension', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildInput('Custom Extension', hint: '.xyz', isDark: isDark, suffix: Text('Add', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13)))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInput('Purchase Date', hint: 'mm/dd/yyyy', isDark: isDark, suffix: const Icon(Icons.calendar_today_outlined, size: 16))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Duration (Years)', hint: '1 Year', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Domain Service Registrar', hint: 'Select Registrar Provider', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildInput('Cost', hint: '\$ 0.00', isDark: isDark, width: isMobile ? double.infinity : 200),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              
              Text('Renewal Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildNotificationCheckbox('WhatsApp', const Color(0xFF22C55E), Icons.wechat, isDark, _whatsappSelected, () => setState(() => _whatsappSelected = !_whatsappSelected)),
                  _buildNotificationCheckbox('Email', const Color(0xFFEF4444), Icons.email, isDark, _emailSelected, () => setState(() => _emailSelected = !_emailSelected)),
                  _buildNotificationCheckbox('Message', const Color(0xFF6366F1), Icons.chat_bubble, isDark, _messageSelected, () => setState(() => _messageSelected = !_messageSelected)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                ),
                const SizedBox(width: 12),
                Text('Configured Domains', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(24)),
              child: const Text('24 Domains', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildDomainCard('konguv...', isDark),
            _buildDomainCard('circuitp...', isDark),
            _buildDomainCard('swamyt...', isDark),
            _buildDomainCard('srivagr...', isDark),
            _buildDomainCard('lawyers...', isDark),
            _buildDomainCard('epriceo...', isDark),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildNotificationCheckbox(String title, Color iconColor, IconData icon, bool isDark, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF818CF8) : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFEEF2FF) : (isDark ? AppColors.surfaceDark : Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1), size: 18),
            const SizedBox(width: 8),
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainCard(String name, bool isDark) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.language, color: Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const Text('Registrar: ...', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showDomainDialog(context, isDark, isEdit: false, name: name),
                child: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showDomainDialog(context, isDark, isEdit: true, name: name),
                child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.delete_outline, size: 18, color: Color(0xFF64748B)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Add Subdomain Tab
  Widget _buildAddSubdomainTab(BuildContext context, bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link, color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Subdomain Configuration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A)))),
                ],
              ),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildInput('Primary Domain', hint: 'Select Primary Domain', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16)),
                const SizedBox(height: 16),
                _buildInput('Subdomain Prefix', hint: 'e.g. blog, app', isDark: isDark),
                const SizedBox(height: 16),
                _buildInput('Target Subdomain', hint: 'Target URL preview...', isDark: isDark),
                const SizedBox(height: 16),
                _buildInput('Login URL', hint: 'https://panel.example.com', isDark: isDark),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildInput('Primary Domain', hint: 'Select Primary Domain', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Subdomain Prefix', hint: 'e.g. blog, app', isDark: isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Target Subdomain', hint: 'Target URL preview...', isDark: isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInput('Login URL', hint: 'https://panel.example.com', isDark: isDark)),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox.shrink()),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                ),
                const SizedBox(width: 12),
                Text('Configured Subdomains', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(24)),
              child: const Text('22 Subdomains', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSubdomainCard('electronics...', 'jobes24x7.c...', isDark),
            _buildSubdomainCard('testos.jobe...', 'jobes24x7.c...', isDark),
            _buildSubdomainCard('team.vellia...', 'velliangiriand...', isDark),
            _buildSubdomainCard('velliangiria...', 'sivantemple...', isDark),
            _buildSubdomainCard('paramasiva...', 'sivantemple...', isDark),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSubdomainCard(String name, String primary, bool isDark) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.language, color: Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 10, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(primary, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showSubdomainDialog(context, isDark, isEdit: false),
                child: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showSubdomainDialog(context, isDark, isEdit: true),
                child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubdomainDialog(BuildContext context, bool isDark, {required bool isEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(isEdit ? Icons.edit : Icons.language, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Subdomain' : 'Subdomain Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                if (MediaQuery.of(context).size.width < 500) ...[
                  _buildInput('Primary Domain', value: 'jobes24x7.com', isDark: isDark, suffix: isEdit ? const Icon(Icons.keyboard_arrow_down, size: 16) : null),
                  const SizedBox(height: 16),
                  _buildInput('Subdomain Prefix', value: 'electronics', isDark: isDark),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: _buildInput('Primary Domain', value: 'jobes24x7.com', isDark: isDark, suffix: isEdit ? const Icon(Icons.keyboard_arrow_down, size: 16) : null)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInput('Subdomain Prefix', value: 'electronics', isDark: isDark)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Subdomain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: isEdit ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        color: isEdit ? const Color(0xFFEEF2FF) : (isDark ? AppColors.surfaceDark : Colors.white),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: Text('electronics.jobes24x7.com', style: TextStyle(fontSize: 13.5, color: isEdit ? const Color(0xFF4F46E5) : (isDark ? Colors.white : const Color(0xFF0F172A)))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildInput('Login URL', value: 'https://electronics.jobes24x7.com', isDark: isDark),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isEdit) const Spacer(),
                    if (isEdit)
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? const Color(0xFF6366F1) : Colors.white,
                        foregroundColor: isEdit ? Colors.white : const Color(0xFF0F172A),
                        side: isEdit ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(isEdit ? 'Save Changes' : 'Close'),
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

  void _showDomainDialog(BuildContext context, bool isDark, {required bool isEdit, required String name}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(isEdit ? Icons.edit : Icons.language, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Domain Configuration' : 'Domain Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(child: _buildInput('Domain Name', value: name.replaceAll('...', ''), isDark: isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Registrar', value: isEdit ? null : 'godaddy', hint: isEdit ? 'Select Registrar Provider' : null, isDark: isDark, suffix: isEdit ? const Icon(Icons.keyboard_arrow_down, size: 16) : null)),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildInput('Cost', value: '0.00', isDark: isDark)),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isEdit) const Spacer(),
                    if (isEdit)
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? const Color(0xFF6366F1) : Colors.white,
                        foregroundColor: isEdit ? Colors.white : const Color(0xFF0F172A),
                        side: isEdit ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(isEdit ? 'Save Changes' : 'Close'),
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
}
