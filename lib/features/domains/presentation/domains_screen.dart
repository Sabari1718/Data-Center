import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/domain_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_header.dart';
import 'domain_controller.dart';

class DomainsScreen extends ConsumerStatefulWidget {
  const DomainsScreen({super.key});

  @override
  ConsumerState<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends ConsumerState<DomainsScreen> {
  int _selectedTabIndex = 0; // 0 = Add Domain, 1 = Add Subdomain
  String _lastSavedTime = 'Never';

  // --- Add Domain Form State ---
  final _domainNameCtrl = TextEditingController();
  final _customExtCtrl = TextEditingController();
  final _purchaseDateCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  DateTime? _selectedPurchaseDate;
  int? _selectedExtensionId;
  int _selectedDurationYears = 1;
  String? _selectedRegistrar;

  bool _whatsappSelected = false;
  bool _emailSelected = false;
  bool _messageSelected = false;

  // --- Add Subdomain Form State ---
  DomainModel? _selectedPrimaryDomain;
  final _subdomainPrefixCtrl = TextEditingController();
  final _loginUrlCtrl = TextEditingController();

  final List<int> _durationOptions = [1, 2, 3, 5, 10];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _domainNameCtrl.dispose();
    _customExtCtrl.dispose();
    _purchaseDateCtrl.dispose();
    _costCtrl.dispose();
    _subdomainPrefixCtrl.dispose();
    _loginUrlCtrl.dispose();
    super.dispose();
  }

  void _discardDomainForm() {
    setState(() {
      _domainNameCtrl.clear();
      _customExtCtrl.clear();
      _purchaseDateCtrl.clear();
      _selectedPurchaseDate = null;
      _costCtrl.clear();
      _selectedExtensionId = null;
      _selectedRegistrar = null;
      _whatsappSelected = false;
      _emailSelected = false;
      _messageSelected = false;
    });
  }

  void _discardSubdomainForm() {
    setState(() {
      _subdomainPrefixCtrl.clear();
      _loginUrlCtrl.clear();
    });
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _selectedPurchaseDate = picked;
        _purchaseDateCtrl.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveDomain() async {
    final domainName = _domainNameCtrl.text.trim();
    if (domainName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Domain Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final payload = {
      'domain_name': domainName,
      'extension_id': _selectedExtensionId ?? 1,
      'custom_extension':
          _customExtCtrl.text.trim().isNotEmpty ? _customExtCtrl.text.trim() : null,
      'purchase_date': (_selectedPurchaseDate ?? DateTime.now()).toIso8601String(),
      'duration_years': _selectedDurationYears,
      'domain_service': _selectedRegistrar,
      'cost': double.tryParse(_costCtrl.text.replaceAll('\$', '').trim()) ?? 0,
      'renewal_whatsapp': _whatsappSelected ? 1 : 0,
      'renewal_email': _emailSelected ? 1 : 0,
      'renewal_message': _messageSelected ? 1 : 0,
    };

    final success = await ref
        .read(domainControllerProvider.notifier)
        .addDomain(payload);

    if (mounted) {
      if (success) {
        setState(() {
          _lastSavedTime = 'Just now';
        });
        _discardDomainForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Domain saved successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save domain'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _saveSubdomain(List<DomainModel> domains) async {
    if (_selectedPrimaryDomain == null && domains.isNotEmpty) {
      _selectedPrimaryDomain = domains.first;
    }

    if (_selectedPrimaryDomain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Primary Domain'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefix = _subdomainPrefixCtrl.text.trim();
    if (prefix.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Subdomain Prefix'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final url = _loginUrlCtrl.text.trim();

    final success = await ref
        .read(domainControllerProvider.notifier)
        .addSubdomain(
          primaryDomainId: _selectedPrimaryDomain!.id,
          subdomainPrefix: prefix,
          url: url.isNotEmpty
              ? url
              : 'https://$prefix.${_selectedPrimaryDomain!.displayName}',
        );

    if (mounted) {
      if (success) {
        setState(() {
          _lastSavedTime = 'Just now';
        });
        _discardSubdomainForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subdomain created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create subdomain'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = MediaQuery.of(context).size.width < 800;
    final domainState = ref.watch(domainControllerProvider);

    final domains = domainState.domains.asData?.value ?? [];
    final extensions = domainState.extensions.asData?.value ?? [];
    final subdomains = domainState.subdomains.asData?.value ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _selectedTabIndex == 0 ? 'Add Domain' : 'Add Subdomain',
              subtitle: _selectedTabIndex == 0
                  ? 'Register and track your domain portfolios and renewal dates.'
                  : 'Create and track subdomains for your existing primary domain portfolio.',
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      ref.read(domainControllerProvider.notifier).refresh(),
                ),
              ],
            ),

            if (isMobile)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTopMenuItem(
                        'Add Domain',
                        Icons.language_rounded,
                        _selectedTabIndex == 0,
                        () => setState(() => _selectedTabIndex = 0),
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildTopMenuItem(
                        'Add Subdomain',
                        Icons.link_rounded,
                        _selectedTabIndex == 1,
                        () => setState(() => _selectedTabIndex = 1),
                        isDark,
                      ),
                    ),
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
                        border: Border(
                          right: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Text(
                              'DOMAIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          _buildSideMenuItem(
                            'Add Domain',
                            Icons.language_rounded,
                            _selectedTabIndex == 0,
                            () => setState(() => _selectedTabIndex = 0),
                            isDark,
                          ),
                          _buildSideMenuItem(
                            'Add Subdomain',
                            Icons.link_rounded,
                            _selectedTabIndex == 1,
                            () => setState(() => _selectedTabIndex = 1),
                            isDark,
                          ),
                        ],
                      ),
                    ),

                  // Main Content
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: domainState.domains.isLoading &&
                                  domains.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                  ),
                                )
                              : ListView(
                                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                                  children: [
                                    _selectedTabIndex == 0
                                        ? _buildAddDomainTab(
                                            context,
                                            isDark,
                                            isMobile,
                                            domains,
                                            extensions,
                                            domainState,
                                          )
                                        : _buildAddSubdomainTab(
                                            context,
                                            isDark,
                                            isMobile,
                                            domains,
                                            subdomains,
                                            domainState,
                                          ),
                                  ],
                                ),
                        ),

                        // Fixed Footer
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
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
                                    Text(
                                      'Last saved: $_lastSavedTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedTabIndex == 0
                                          ? '${domains.length} Domains Configured'
                                          : '${subdomains.length} Subdomains Configured',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      if (_selectedTabIndex == 0) {
                                        _discardDomainForm();
                                      } else {
                                        _discardSubdomainForm();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      side: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Discard Changes',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: domainState.isLoadingAction
                                        ? null
                                        : () {
                                            if (_selectedTabIndex == 0) {
                                              _saveDomain();
                                            } else {
                                              _saveSubdomain(domains);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 24,
                                        vertical: 14,
                                      ),
                                    ),
                                    child: domainState.isLoadingAction
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _selectedTabIndex == 0
                                                ? 'Save Domain'
                                                : 'Save Subdomain',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
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

  Widget _buildTopMenuItem(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenuItem(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF))
              : Colors.transparent,
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            if (isSelected) const Spacer(),
            if (isSelected)
              const Icon(Icons.circle, size: 6, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }

  // --- 1. Add Domain Tab ---
  Widget _buildAddDomainTab(
    BuildContext context,
    bool isDark,
    bool isMobile,
    List<DomainModel> domains,
    List<DomainExtensionModel> extensions,
    DomainState domainState,
  ) {
    final registrars = domainState.registrars.asData?.value ??
        ['godaddy', 'namecheap', 'cloudflare', 'google domains'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Card
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Domain Configuration',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Inputs Row 1: Domain Name, Extension, Custom Extension
              if (isMobile) ...[
                _buildTextInput(
                  'Domain Name',
                  controller: _domainNameCtrl,
                  hint: 'e.g. acme-corp',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildExtensionDropdown(extensions, isDark),
                const SizedBox(height: 16),
                _buildCustomExtInput(isDark),
                const SizedBox(height: 16),
                _buildPurchaseDateInput(isDark),
                const SizedBox(height: 16),
                _buildDurationDropdown(isDark),
                const SizedBox(height: 16),
                _buildRegistrarDropdown(registrars, isDark),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextInput(
                        'Domain Name',
                        controller: _domainNameCtrl,
                        hint: 'e.g. acme-corp',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildExtensionDropdown(extensions, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildCustomExtInput(isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildPurchaseDateInput(isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDurationDropdown(isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRegistrarDropdown(registrars, isDark)),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Cost
              _buildTextInput(
                'Cost',
                controller: _costCtrl,
                hint: '\$ 0.00',
                isDark: isDark,
                width: isMobile ? double.infinity : 200,
                prefixText: '\$ ',
              ),

              const SizedBox(height: 32),
              Divider(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 24),

              Text(
                'Renewal Notifications',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildNotificationCheckbox(
                    'WhatsApp',
                    const Color(0xFF22C55E),
                    Icons.phone_android_rounded,
                    isDark,
                    _whatsappSelected,
                    () => setState(() => _whatsappSelected = !_whatsappSelected),
                  ),
                  _buildNotificationCheckbox(
                    'Email',
                    const Color(0xFFEF4444),
                    Icons.email_outlined,
                    isDark,
                    _emailSelected,
                    () => setState(() => _emailSelected = !_emailSelected),
                  ),
                  _buildNotificationCheckbox(
                    'Message',
                    const Color(0xFF6366F1),
                    Icons.chat_bubble_outline_rounded,
                    isDark,
                    _messageSelected,
                    () => setState(() => _messageSelected = !_messageSelected),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Configured Domains Section
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Configured Domains',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${domains.length} Domains',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (domains.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
            child: const Text('No domains configured yet.'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: domains.map((domain) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildDomainCard(domain, isDark),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 48),
      ],
    );
  }

  // --- 2. Add Subdomain Tab ---
  Widget _buildAddSubdomainTab(
    BuildContext context,
    bool isDark,
    bool isMobile,
    List<DomainModel> domains,
    List<SubdomainModel> subdomains,
    DomainState domainState,
  ) {
    // Current target preview calculation
    final currentPrefix = _subdomainPrefixCtrl.text.trim();
    final primaryName = _selectedPrimaryDomain?.displayName ?? '';
    final targetPreview = currentPrefix.isNotEmpty && primaryName.isNotEmpty
        ? '$currentPrefix.$primaryName'
        : (primaryName.isNotEmpty
            ? 'e.g. app.$primaryName'
            : 'Target URL preview...');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Configuration Card
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Subdomain Configuration',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (isMobile) ...[
                _buildPrimaryDomainDropdown(domains, isDark),
                const SizedBox(height: 16),
                _buildTextInput(
                  'Subdomain Prefix',
                  controller: _subdomainPrefixCtrl,
                  hint: 'e.g. blog, app',
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _buildReadOnlyInput(
                  'Target Subdomain',
                  value: targetPreview,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextInput(
                  'Login URL',
                  controller: _loginUrlCtrl,
                  hint: 'https://panel.example.com',
                  isDark: isDark,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildPrimaryDomainDropdown(domains, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextInput(
                        'Subdomain Prefix',
                        controller: _subdomainPrefixCtrl,
                        hint: 'e.g. blog, app',
                        isDark: isDark,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Target Subdomain',
                        value: targetPreview,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextInput(
                        'Login URL',
                        controller: _loginUrlCtrl,
                        hint: 'https://panel.example.com',
                        isDark: isDark,
                      ),
                    ),
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

        // Configured Subdomains Section
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Configured Subdomains',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${subdomains.length} Subdomains',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (subdomains.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
            child: const Text('No subdomains configured yet.'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: subdomains.map((subdomain) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildSubdomainCard(subdomain, domains, isDark),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 48),
      ],
    );
  }

  // --- Domain Card Widget ---
  Widget _buildDomainCard(DomainModel domain, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registrar: ${domain.registrar}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // View Eye Icon
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _viewDomainDetails(domain, isDark),
              ),
              const SizedBox(width: 12),
              // Edit Pencil Icon
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _editDomainDialog(domain, isDark),
              ),
              const SizedBox(width: 12),
              // Delete Trash Icon
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteDomain(domain, isDark),
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
              const Text(
                'STATUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Subdomain Card Widget ---
  Widget _buildSubdomainCard(
    SubdomainModel subdomain,
    List<DomainModel> domains,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subdomain.targetSubdomain,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.link,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            subdomain.primaryDomainName.isNotEmpty
                                ? subdomain.primaryDomainName
                                : '${subdomain.domainName}${subdomain.extension}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
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
              // View Eye Icon
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _viewSubdomainDetails(subdomain, isDark),
              ),
              const SizedBox(width: 12),
              // Edit Pencil Icon
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    _editSubdomainDialog(subdomain, domains, isDark),
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
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Delete Trash Icon (Red)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteSubdomain(subdomain, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Subdomain View Details Modal ---
  void _viewSubdomainDetails(SubdomainModel subdomain, bool isDark) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.language,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Subdomain Details',
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
                          color: isDark
                              ? AppColors.surfaceDark
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildReadOnlyInput(
                  'Primary Domain',
                  value: subdomain.primaryDomainName.isNotEmpty
                      ? subdomain.primaryDomainName
                      : '${subdomain.domainName}${subdomain.extension}',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildReadOnlyInput(
                  'Subdomain Prefix',
                  value: subdomain.subdomainPrefix,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildReadOnlyInput(
                  'Target Subdomain',
                  value: subdomain.targetSubdomain,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildReadOnlyInput(
                  'Login URL',
                  value: subdomain.loginUrl,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Subdomain Edit Modal ---
  void _editSubdomainDialog(
    SubdomainModel subdomain,
    List<DomainModel> domains,
    bool isDark,
  ) {
    dynamic editDomainId = subdomain.primaryDomainId;
    final prefixCtrl =
        TextEditingController(text: subdomain.subdomainPrefix);
    final urlCtrl = TextEditingController(text: subdomain.loginUrl);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentPrefix = prefixCtrl.text.trim();
            final domObj = domains.cast<DomainModel?>().firstWhere(
              (d) => d?.id.toString() == editDomainId?.toString(),
              orElse: () => domains.isNotEmpty ? domains.first : null,
            );
            final targetPreview =
                '$currentPrefix.${domObj?.displayName ?? subdomain.primaryDomainName}';

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
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit Subdomain',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(dialogCtx),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Primary Domain Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Domain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<dynamic>(
                              value: editDomainId,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                              items: domains.map((d) {
                                return DropdownMenuItem<dynamic>(
                                  value: int.tryParse(d.id) ?? d.id,
                                  child: Text(
                                    d.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setModalState(() {
                                  editDomainId = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subdomain Prefix
                    _buildTextInput(
                      'Subdomain Prefix',
                      controller: prefixCtrl,
                      hint: 'e.g. app',
                      isDark: isDark,
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Target Subdomain Preview
                    _buildReadOnlyInput(
                      'Target Subdomain',
                      value: targetPreview,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Login URL
                    _buildTextInput(
                      'Login URL',
                      controller: urlCtrl,
                      hint: 'https://panel.example.com',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : const Color(0xFFE2E8F0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final nav = Navigator.of(dialogCtx);
                            final messenger = ScaffoldMessenger.of(context);
                            final prefix = prefixCtrl.text.trim();
                            final url = urlCtrl.text.trim();
                            final success = await ref
                                .read(domainControllerProvider.notifier)
                                .updateSubdomain(
                                  subdomain.id,
                                  primaryDomainId: editDomainId ?? subdomain.primaryDomainId,
                                  subdomainPrefix: prefix,
                                  url: url,
                                );
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Subdomain updated successfully!'
                                    : 'Failed to update subdomain'),
                                backgroundColor: success
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Subdomain Delete Confirmation ---
  void _confirmDeleteSubdomain(SubdomainModel subdomain, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'Delete Subdomain',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${subdomain.targetSubdomain}?',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await ref
                    .read(domainControllerProvider.notifier)
                    .deleteSubdomain(subdomain.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Subdomain deleted successfully!'
                          : 'Failed to delete subdomain'),
                      backgroundColor: success
                          ? const Color(0xFF10B981)
                          : Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --- Domain View Details Modal ---
  Future<void> _viewDomainDetails(DomainModel domain, bool isDark) async {
    final details = await ref
            .read(domainControllerProvider.notifier)
            .getDomainDetails(domain.id) ??
        domain;

    if (!mounted) return;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.language,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Domain Details',
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
                          color: isDark
                              ? AppColors.surfaceDark
                              : const Color(0xFFF1F5F9),
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
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Domain Name',
                        value: details.displayName,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Registrar',
                        value: details.registrar,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Cost',
                        value: '\$ ${details.cost.toStringAsFixed(2)}',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Duration (Years)',
                        value: '${details.durationYears} Year(s)',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Purchase Date',
                        value: details.purchaseDate != null
                            ? '${details.purchaseDate!.month}/${details.purchaseDate!.day}/${details.purchaseDate!.year}'
                            : 'N/A',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReadOnlyInput(
                        'Status',
                        value: 'Active',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Domain Edit Modal ---
  void _editDomainDialog(DomainModel domain, bool isDark) {
    final nameCtrl = TextEditingController(text: domain.domainName);
    String selectedReg = domain.registrar.isNotEmpty ? domain.registrar : 'godaddy';
    final costCtrl = TextEditingController(text: domain.cost.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit Domain Configuration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(dialogCtx),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF1F5F9),
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
                        Expanded(
                          child: _buildTextInput(
                            'Domain Name',
                            controller: nameCtrl,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registrar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedReg,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        size: 16),
                                    items: [
                                      'godaddy',
                                      'namecheap',
                                      'cloudflare',
                                      'google domains'
                                    ].map((r) {
                                      return DropdownMenuItem<String>(
                                        value: r,
                                        child: Text(
                                          r,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedReg = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            'Cost',
                            controller: costCtrl,
                            isDark: isDark,
                            prefixText: '\$ ',
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : const Color(0xFFE2E8F0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Close'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final nav = Navigator.of(dialogCtx);
                            final messenger = ScaffoldMessenger.of(context);
                            final payload = {
                              'company_name': '',
                              'domain_name': nameCtrl.text.trim(),
                              'domain_service': selectedReg,
                              'cost': double.tryParse(costCtrl.text.trim()) ?? 0,
                            };
                            final success = await ref
                                .read(domainControllerProvider.notifier)
                                .updateDomain(domain.id, payload);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Domain updated successfully!'
                                    : 'Failed to update domain'),
                                backgroundColor: success
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Domain Delete Confirmation ---
  void _confirmDeleteDomain(DomainModel domain, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'Delete Domain',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${domain.displayName}?',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await ref
                    .read(domainControllerProvider.notifier)
                    .deleteDomain(domain.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Domain deleted successfully!'
                          : 'Failed to delete domain'),
                      backgroundColor: success
                          ? const Color(0xFF10B981)
                          : Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --- Custom Input Helpers ---
  Widget _buildTextInput(
    String label, {
    required TextEditingController controller,
    String? hint,
    bool isDark = false,
    double width = double.infinity,
    String? prefixText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              if (prefixText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    prefixText,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textMutedDark
                          : const Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInput(
    String label, {
    required String value,
    bool isDark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExtensionDropdown(
    List<DomainExtensionModel> extensions,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extension',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: extensions.any((e) => e.id == _selectedExtensionId)
                  ? _selectedExtensionId
                  : null,
              hint: Text(
                'Select Extension',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textMutedDark
                      : const Color(0xFF94A3B8),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              items: extensions.map((ext) {
                return DropdownMenuItem<int>(
                  value: ext.id,
                  child: Text(
                    ext.extension,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedExtensionId = val;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomExtInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Extension',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customExtCtrl,
                  decoration: InputDecoration(
                    hintText: '.xyz',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textMutedDark
                          : const Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () async {
                    final txt = _customExtCtrl.text.trim();
                    if (txt.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an extension (e.g. .xyz)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final formatted = txt.startsWith('.') ? txt : '.$txt';
                    final created = await ref
                        .read(domainControllerProvider.notifier)
                        .addExtension(formatted);
                    if (mounted) {
                      if (created != null) {
                        setState(() {
                          _selectedExtensionId = created.id;
                          _customExtCtrl.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Domain extension "${created.extension}" created successfully'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to create domain extension. Please try again.'),
                            backgroundColor: Color(0xFFEF4444),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseDateInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Date',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickPurchaseDate,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _purchaseDateCtrl.text.isNotEmpty
                        ? _purchaseDateCtrl.text
                        : 'mm/dd/yyyy',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _purchaseDateCtrl.text.isNotEmpty
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark
                              ? AppColors.textMutedDark
                              : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (Years)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDurationYears,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              items: _durationOptions.map((years) {
                return DropdownMenuItem<int>(
                  value: years,
                  child: Text(
                    '$years ${years == 1 ? 'Year' : 'Years'}',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDurationYears = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrarDropdown(List<String> registrars, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Domain Service Registrar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: registrars.contains(_selectedRegistrar)
                  ? _selectedRegistrar
                  : null,
              hint: Text(
                'Select Registrar Provider',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textMutedDark
                      : const Color(0xFF94A3B8),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              items: registrars.map((r) {
                return DropdownMenuItem<String>(
                  value: r,
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRegistrar = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryDomainDropdown(List<DomainModel> domains, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Domain',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DomainModel>(
              value: domains.contains(_selectedPrimaryDomain)
                  ? _selectedPrimaryDomain
                  : (domains.isNotEmpty ? domains.first : null),
              hint: Text(
                'Select Primary Domain',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textMutedDark
                      : const Color(0xFF94A3B8),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              items: domains.map((d) {
                return DropdownMenuItem<DomainModel>(
                  value: d,
                  child: Text(
                    d.displayName,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPrimaryDomain = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCheckbox(
    String title,
    Color iconColor,
    IconData icon,
    bool isDark,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xFF818CF8)
                : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? (isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF))
              : (isDark ? AppColors.surfaceDark : Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFCBD5E1),
              size: 18,
            ),
            const SizedBox(width: 8),
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
