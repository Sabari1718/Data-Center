import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/domain_model.dart';
import '../../../data/models/hosting_model.dart';
import '../../../data/models/server_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import 'hosting_controller.dart';

class UnifiedHostingItem {
  final dynamic id;
  final String name;
  final String controlPanel;
  final String ipAddress;
  final String status;
  final bool isServerHosting;
  final dynamic raw;

  const UnifiedHostingItem({
    required this.id,
    required this.name,
    required this.controlPanel,
    required this.ipAddress,
    required this.status,
    required this.isServerHosting,
    required this.raw,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnifiedHostingItem &&
          runtimeType == other.runtimeType &&
          id.toString() == other.id.toString() &&
          isServerHosting == other.isServerHosting;

  @override
  int get hashCode => Object.hash(id.toString(), isServerHosting);
}

class HostingScreen extends ConsumerStatefulWidget {
  const HostingScreen({super.key});

  @override
  ConsumerState<HostingScreen> createState() => _HostingScreenState();
}

class _HostingScreenState extends ConsumerState<HostingScreen> {
  int _selectedTabIndex = 0;
  // 0: Option selection cards, 1: Add New Hosting (standalone), 2: Add Hosting with Server
  int _hostingFormType = 0;

  final List<String> _tabs = [
    'Add Hosting',
    'Domain to Hosting Mapping',
  ];

  final List<IconData> _tabIcons = [
    Icons.language_rounded,
    Icons.link_rounded,
  ];

  // --- Add New Hosting (Standalone) Form Controllers & State ---
  String _serviceProvider = 'data';
  String _hostingType = 'sa';
  final _ipCtrl = TextEditingController(text: '77899');
  String _status = 'Pending';
  String _controlPanel = 'Plesk';

  final _hostingNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _customerIdCtrl = TextEditingController();
  final _ns1Ctrl = TextEditingController();
  final _ns2Ctrl = TextEditingController();

  final _storageCtrl = TextEditingController(text: '100 gb');
  final _bandwidthCtrl = TextEditingController(text: '1 tp');
  final _addonLimitCtrl = TextEditingController(text: '0');
  final _subdomainLimitCtrl = TextEditingController(text: '0');
  final _emailLimitCtrl = TextEditingController(text: '0');
  final _ftpLimitCtrl = TextEditingController(text: '0');
  final _mysqlLimitCtrl = TextEditingController(text: '0');
  final _inodeLimitCtrl = TextEditingController(text: '0');

  String _webServer = 'Nginx';
  String _phpVersion = '8.2';
  String _databaseType = 'MariaDB';
  String _sslCertificate = 'Custom SSL';
  int _sshAccess = 1;
  int _backupEnabled = 0;

  DateTime? _createdDate;
  DateTime? _renewalDate;
  DateTime? _expiryDate;
  final String _extension = '.com';

  // --- Add Hosting with Server Form Controllers & State ---
  dynamic _serverHostingSelectedServerId;
  String _serverHostingType = 'sa';
  final _serverHostingNameCtrl = TextEditingController(text: 'gfg');
  final _serverIpCtrl = TextEditingController(text: 'dg');
  String _serverStatus = 'Suspended';
  String _serverControlPanel = 'Plesk';

  final _serverUsernameCtrl = TextEditingController(text: 'jjjjkjsseeett');
  final _serverPasswordCtrl = TextEditingController(text: '89999999');
  final _serverCustomerIdCtrl = TextEditingController(text: 'hgf');
  final _serverNs1Ctrl = TextEditingController(text: 'hgf');
  final _serverNs2Ctrl = TextEditingController(text: 'ghf');

  final _serverStorageCtrl = TextEditingController(text: 'g');
  final _serverBandwidthCtrl = TextEditingController(text: 'hgf');
  final _serverAddonLimitCtrl = TextEditingController(text: '0');
  final _serverSubdomainLimitCtrl = TextEditingController(text: '0');
  final _serverEmailLimitCtrl = TextEditingController(text: '0');
  final _serverFtpLimitCtrl = TextEditingController(text: '0');
  final _serverMysqlLimitCtrl = TextEditingController(text: '0');
  final _serverInodeLimitCtrl = TextEditingController(text: '0');

  String _serverWebServer = 'Nginx';
  String _serverPhpVersion = '8.1';
  String _serverDatabaseType = 'MariaDB';
  String _serverSslCertificate = "Let's Encrypt";
  bool _serverSshAccess = true;
  bool _serverBackupEnabled = true;

  DateTime? _serverCreatedDate;
  DateTime? _serverRenewalDate;
  DateTime? _serverExpiryDate;
  final List<dynamic> _serverDomainIds = [];

  // --- Domain to Hosting Mapping State ---
  UnifiedHostingItem? _mappingUnifiedHosting;
  DomainModel? _mappingSelectedDomain;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _createdDate = now;
    _renewalDate = now.add(const Duration(days: 365));
    _expiryDate = now.add(const Duration(days: 365));

    _serverCreatedDate = now;
    _serverRenewalDate = now.add(const Duration(days: 365));
    _serverExpiryDate = now.add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _hostingNameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _customerIdCtrl.dispose();
    _ns1Ctrl.dispose();
    _ns2Ctrl.dispose();
    _storageCtrl.dispose();
    _bandwidthCtrl.dispose();
    _addonLimitCtrl.dispose();
    _subdomainLimitCtrl.dispose();
    _emailLimitCtrl.dispose();
    _ftpLimitCtrl.dispose();
    _mysqlLimitCtrl.dispose();
    _inodeLimitCtrl.dispose();

    _serverHostingNameCtrl.dispose();
    _serverIpCtrl.dispose();
    _serverUsernameCtrl.dispose();
    _serverPasswordCtrl.dispose();
    _serverCustomerIdCtrl.dispose();
    _serverNs1Ctrl.dispose();
    _serverNs2Ctrl.dispose();
    _serverStorageCtrl.dispose();
    _serverBandwidthCtrl.dispose();
    _serverAddonLimitCtrl.dispose();
    _serverSubdomainLimitCtrl.dispose();
    _serverEmailLimitCtrl.dispose();
    _serverFtpLimitCtrl.dispose();
    _serverMysqlLimitCtrl.dispose();
    _serverInodeLimitCtrl.dispose();
    super.dispose();
  }

  void _discardForm() {
    setState(() {
      _hostingNameCtrl.clear();
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      _customerIdCtrl.clear();
      _ns1Ctrl.clear();
      _ns2Ctrl.clear();
      _storageCtrl.text = '100 gb';
      _bandwidthCtrl.text = '1 tp';
      _addonLimitCtrl.text = '0';
      _subdomainLimitCtrl.text = '0';
      _emailLimitCtrl.text = '0';
      _ftpLimitCtrl.text = '0';
      _mysqlLimitCtrl.text = '0';
      _inodeLimitCtrl.text = '0';
    });
  }

  void _discardServerForm() {
    setState(() {
      _serverHostingNameCtrl.text = 'gfg';
      _serverIpCtrl.text = 'dg';
      _serverUsernameCtrl.text = 'jjjjkjsseeett';
      _serverPasswordCtrl.text = '89999999';
      _serverCustomerIdCtrl.text = 'hgf';
      _serverNs1Ctrl.text = 'hgf';
      _serverNs2Ctrl.text = 'ghf';
      _serverStorageCtrl.text = 'g';
      _serverBandwidthCtrl.text = 'hgf';
      _serverAddonLimitCtrl.text = '0';
      _serverSubdomainLimitCtrl.text = '0';
      _serverEmailLimitCtrl.text = '0';
      _serverFtpLimitCtrl.text = '0';
      _serverMysqlLimitCtrl.text = '0';
      _serverInodeLimitCtrl.text = '0';
    });
  }

  String _formatDateYMD(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _saveServerHostingConfiguration() async {
    final name = _serverHostingNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Hosting Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_serverHostingSelectedServerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Server'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final payload = {
      'server_id': _serverHostingSelectedServerId is int
          ? _serverHostingSelectedServerId
          : int.tryParse(_serverHostingSelectedServerId.toString()) ?? _serverHostingSelectedServerId,
      'hosting_type': _serverHostingType,
      'hosting_name': name,
      'domain_id': _serverDomainIds,
      'username': _serverUsernameCtrl.text.trim(),
      'password': _serverPasswordCtrl.text.trim(),
      'customer_id': _serverCustomerIdCtrl.text.trim(),
      'nameserver_1': _serverNs1Ctrl.text.trim(),
      'nameserver_2': _serverNs2Ctrl.text.trim(),
      'storage_harddisk': _serverStorageCtrl.text.trim(),
      'bandwidth_limit': _serverBandwidthCtrl.text.trim(),
      'addon_domain_limit': int.tryParse(_serverAddonLimitCtrl.text.trim()) ?? 0,
      'subdomain_limit': int.tryParse(_serverSubdomainLimitCtrl.text.trim()) ?? 0,
      'email_accounts_limit': int.tryParse(_serverEmailLimitCtrl.text.trim()) ?? 0,
      'ftp_accounts_limit': int.tryParse(_serverFtpLimitCtrl.text.trim()) ?? 0,
      'mysql_database_limit': int.tryParse(_serverMysqlLimitCtrl.text.trim()) ?? 0,
      'inode_limit': int.tryParse(_serverInodeLimitCtrl.text.trim()) ?? 0,
      'web_server': _serverWebServer,
      'php_version': _serverPhpVersion,
      'database_type': _serverDatabaseType,
      'ssl_certificate': _serverSslCertificate,
      'ssh_access': _serverSshAccess,
      'backup_enabled': _serverBackupEnabled,
      'created_date': _formatDateYMD(_serverCreatedDate),
      'expiry_date': _formatDateYMD(_serverExpiryDate),
      'renewal_date': _formatDateYMD(_serverRenewalDate),
      'ip_address': _serverIpCtrl.text.trim(),
      'status': _serverStatus,
      'control_panel': _serverControlPanel,
    };

    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(hostingControllerProvider.notifier)
        .createServerHosting(payload);

    if (mounted) {
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Hosting created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to create hosting'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _saveHostingConfiguration() async {
    final name = _hostingNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Hosting Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final payload = {
      'service_provider': _serviceProvider,
      'hosting_type': _hostingType,
      'ip_address': _ipCtrl.text.trim(),
      'status': _status,
      'control_panel': _controlPanel,
      'hosting_name': name,
      'username': _usernameCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      'customer_id': _customerIdCtrl.text.trim(),
      'nameserver_1': _ns1Ctrl.text.trim(),
      'nameserver_2': _ns2Ctrl.text.trim(),
      'storage_harddisk': _storageCtrl.text.trim(),
      'bandwidth_limit': _bandwidthCtrl.text.trim(),
      'addon_domain_limit': int.tryParse(_addonLimitCtrl.text.trim()) ?? 0,
      'subdomain_limit': int.tryParse(_subdomainLimitCtrl.text.trim()) ?? 0,
      'email_accounts_limit': int.tryParse(_emailLimitCtrl.text.trim()) ?? 0,
      'ftp_accounts_limit': int.tryParse(_ftpLimitCtrl.text.trim()) ?? 0,
      'mysql_database_limit': int.tryParse(_mysqlLimitCtrl.text.trim()) ?? 0,
      'inode_limit': int.tryParse(_inodeLimitCtrl.text.trim()) ?? 0,
      'web_server': _webServer,
      'php_version': _phpVersion,
      'database_type': _databaseType,
      'ssl_certificate': _sslCertificate,
      'ssh_access': _sshAccess,
      'backup_enabled': _backupEnabled,
      'created_date': _formatDateYMD(_createdDate),
      'expiry_date': _formatDateYMD(_expiryDate),
      'renewal_date': _formatDateYMD(_renewalDate),
      'extension': _extension,
    };

    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(hostingControllerProvider.notifier)
        .createHostingNew(payload);

    if (mounted) {
      if (success) {
        setState(() => _hostingFormType = 0);
        _discardForm();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Hosting created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to create hosting'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(hostingControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (isDesktop) _buildAcmeTopBar(context, isDark),
            AppHeader(
              title: _selectedTabIndex == 0 ? 'Add Hosting' : 'Domain to Hosting Mapping',
              subtitle: _selectedTabIndex == 0
                  ? 'Provision and manage web hosting accounts across your server infrastructure.'
                  : 'Select a hosting account and a domain to map them together.',
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      ref.read(hostingControllerProvider.notifier).refresh(),
                ),
              ],
            ),

            SubTabBar(
              tabs: _tabs,
              icons: _tabIcons,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _selectedTabIndex == 0
                    ? _buildAddHostingTab(context, state, isDark)
                    : _buildDomainMappingTab(context, state, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Add Hosting Tab ---
  Widget _buildAddHostingTab(
    BuildContext context,
    HostingState state,
    bool isDark,
  ) {
    if (_hostingFormType == 1) {
      return _buildHostingForm(context, state, isDark);
    } else if (_hostingFormType == 2) {
      return _buildHostingWithServerForm(context, state, isDark);
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
                description:
                    'Create and configure a standalone web hosting account.',
                buttonText: 'Continue →',
                icon: Icons.language_rounded,
                iconBgColor: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                isDark: isDark,
                onTap: () => setState(() => _hostingFormType = 1),
              ),
            ),
            SizedBox(
              width: 320,
              child: _buildHostingOptionCard(
                title: 'Add Hosting with Server',
                description:
                    'Provision a new server and configure its hosting.',
                buttonText: 'Continue →',
                icon: Icons.dns_rounded,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                isDark: isDark,
                onTap: () => setState(() => _hostingFormType = 2),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.16) : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 40, color: iconColor),
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
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Add Hosting Form ---
  Widget _buildHostingForm(
    BuildContext context,
    HostingState state,
    bool isDark,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final hostingNewList = state.hostingNewList.asData?.value ?? [];
    final hostingTypes = state.hostingTypes.asData?.value ?? [];
    final registrars = state.registrars.asData?.value ?? [];

    // Ensure defaults from fetched data
    if (registrars.isNotEmpty && !registrars.contains(_serviceProvider)) {
      _serviceProvider = registrars.first;
    }
    if (hostingTypes.isNotEmpty &&
        !hostingTypes.any((t) => t.hostingTypeName == _hostingType)) {
      _hostingType = hostingTypes.first.hostingTypeName;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _hostingFormType = 0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Hosting',
                    style: AppTextStyles.titleMedium(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  'Provision and manage web hosting accounts across your server infrastructure.',
                  style: AppTextStyles.bodySmall(isDark),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language,
                            color: Color(0xFF4F46E5), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Hosting Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),

                    // SECTION 1: INFRASTRUCTURE SELECTION
                    _buildSectionTitle('INFRASTRUCTURE SELECTION', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDropdownInput<String>(
                          'Service Provider *',
                          value: _serviceProvider,
                          items: (registrars.isNotEmpty
                                  ? registrars
                                  : ['data', 'godaddy', 'namecheap'])
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serviceProvider = v);
                          },
                          prefixIcon: Icons.language,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Hosting Type',
                          value: _hostingType,
                          items: (hostingTypes.isNotEmpty
                                  ? hostingTypes.map((t) => t.hostingTypeName).toList()
                                  : ['sa', 'vps', 'shared', 'dedicated'])
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _hostingType = v);
                          },
                          prefixIcon: Icons.hexagon_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'IP Address',
                          controller: _ipCtrl,
                          hint: 'e.g. 192.168.1.1',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Status',
                          value: _status,
                          items: ['Active', 'Pending', 'Suspended']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                          prefixIcon: Icons.show_chart,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Control Panel',
                          value: _controlPanel,
                          items: ['Plesk', 'cPanel', 'DirectAdmin', 'CyberPanel']
                              .map((cp) => DropdownMenuItem(value: cp, child: Text(cp)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _controlPanel = v);
                          },
                          prefixIcon: Icons.hexagon_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),

                    // SECTION 2: DOMAIN & ACCOUNT DETAILS
                    _buildSectionTitle('DOMAIN & ACCOUNT DETAILS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextInput(
                          'Hosting Name *',
                          controller: _hostingNameCtrl,
                          hint: 'e.g. Acme Web Hosting',
                          prefixIcon: Icons.language,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Username',
                          controller: _usernameCtrl,
                          hint: 'e.g. root, webadmin',
                          prefixIcon: Icons.person_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Password',
                          controller: _passwordCtrl,
                          hint: 'Enter password',
                          prefixIcon: Icons.lock_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                          isPassword: true,
                        ),
                        _buildTextInput(
                          'Customer ID',
                          controller: _customerIdCtrl,
                          hint: 'e.g. CUST-10293',
                          prefixIcon: Icons.person_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Nameserver 1',
                          controller: _ns1Ctrl,
                          hint: 'e.g. ns1.example.com',
                          prefixIcon: Icons.language,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Nameserver 2',
                          controller: _ns2Ctrl,
                          hint: 'e.g. ns2.example.com',
                          prefixIcon: Icons.language,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),

                    // SECTION 3: RESOURCE ALLOCATION
                    _buildSectionTitle('RESOURCE ALLOCATION', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextInput(
                          'Storage / Harddisk',
                          controller: _storageCtrl,
                          hint: 'e.g. 100 GB NVMe',
                          prefixIcon: Icons.sd_storage_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Bandwidth Limit',
                          controller: _bandwidthCtrl,
                          hint: 'e.g. 1 TB',
                          prefixIcon: Icons.show_chart,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Addon Domain Limit',
                          controller: _addonLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.link,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Subdomain Limit',
                          controller: _subdomainLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.link,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Email Accounts Limit',
                          controller: _emailLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.person_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'FTP Accounts Limit',
                          controller: _ftpLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.hexagon_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'MySQL Database Limit',
                          controller: _mysqlLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.storage,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Inode Limit',
                          controller: _inodeLimitCtrl,
                          hint: '0',
                          prefixIcon: Icons.sd_storage_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),

                    // SECTION 4: TECHNICAL SPECIFICATIONS
                    _buildSectionTitle('TECHNICAL SPECIFICATIONS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDropdownInput<String>(
                          'Web Server',
                          value: _webServer,
                          items: ['Nginx', 'Apache', 'LiteSpeed']
                              .map((ws) => DropdownMenuItem(value: ws, child: Text(ws)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _webServer = v);
                          },
                          prefixIcon: Icons.dns_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'PHP Version',
                          value: _phpVersion,
                          items: ['8.2', '8.3', '8.1', '7.4', '']
                              .map((php) => DropdownMenuItem(value: php, child: Text(php.isEmpty ? 'None' : php)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _phpVersion = v);
                          },
                          prefixIcon: Icons.code,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Database Type',
                          value: _databaseType,
                          items: ['MariaDB', 'MySQL', 'PostgreSQL']
                              .map((db) => DropdownMenuItem(value: db, child: Text(db)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _databaseType = v);
                          },
                          prefixIcon: Icons.storage,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'SSL Certificate',
                          value: _sslCertificate,
                          items: ['Custom SSL', 'Let\'s Encrypt (Free)', 'None']
                              .map((ssl) => DropdownMenuItem(value: ssl, child: Text(ssl)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _sslCertificate = v);
                          },
                          prefixIcon: Icons.verified_user_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<int>(
                          'SSH Access',
                          value: _sshAccess,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Yes')),
                            DropdownMenuItem(value: 0, child: Text('No')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _sshAccess = v);
                          },
                          prefixIcon: Icons.terminal,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<int>(
                          'Backup Enabled',
                          value: _backupEnabled,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Yes')),
                            DropdownMenuItem(value: 0, child: Text('No')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _backupEnabled = v);
                          },
                          prefixIcon: Icons.sd_storage_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDateClickableInput(
                          'Created Date',
                          value: _formatDateYMD(_createdDate),
                          onTap: () => _pickDate(
                              (d) => _createdDate = d, _createdDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDateClickableInput(
                          'Renewal Date',
                          value: _formatDateYMD(_renewalDate),
                          onTap: () => _pickDate(
                              (d) => _renewalDate = d, _renewalDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDateClickableInput(
                          'Expiry Date',
                          value: _formatDateYMD(_expiryDate),
                          onTap: () => _pickDate(
                              (d) => _expiryDate = d, _expiryDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ACTIVE HOSTINGS LIST
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
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
                          child: const Icon(Icons.language,
                              color: Color(0xFF4F46E5), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active Hostings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '${hostingNewList.length} Total',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    if (hostingNewList.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No active hostings yet.'),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: hostingNewList.map((h) {
                          return SizedBox(
                            width: isMobile ? double.infinity : 300,
                            child: _buildActiveHostingCard(h, isDark),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),

        // Footer Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last deployed: Recently',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hostingNewList.length} Hostings Configured',
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
                      _discardForm();
                      setState(() => _hostingFormType = 0);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Discard Changes',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoadingAction
                        ? null
                        : _saveHostingConfiguration,
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
                    child: state.isLoadingAction
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Configuration',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Active Hosting Card (Matches Photo 2) ---
  Widget _buildActiveHostingCard(HostingNewModel h, bool isDark) {
    final isPending = h.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language,
                    color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.hostingName.isNotEmpty ? h.hostingName : 'Unnamed Hosting',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.link, size: 12, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'No domain',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Icons: Eye, Pencil, Trash
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showFullHostingDetailsModal(h, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showEditHostingModal(h, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _confirmDeleteHosting(h, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                h.username.isNotEmpty ? h.username : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IP Address:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                h.ipAddress.isNotEmpty ? h.ipAddress : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hosting Type Hexagon Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hexagon_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  h.hostingType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPending ? 'PENDING' : 'ACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isPending
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Add Hosting with Server Form (Matches Photo 1 & 2) ---
  Widget _buildHostingWithServerForm(
    BuildContext context,
    HostingState state,
    bool isDark,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final serverHostings = state.serverHostings.asData?.value ?? [];
    final servers = state.servers.asData?.value ?? [];
    final hostingTypes = state.hostingTypes.asData?.value ?? [];

    if (hostingTypes.isNotEmpty &&
        !hostingTypes.any((t) => t.hostingTypeName == _serverHostingType)) {
      _serverHostingType = hostingTypes.first.hostingTypeName;
    }
    if (_serverHostingSelectedServerId == null && servers.isNotEmpty) {
      _serverHostingSelectedServerId = servers.first.id;
      if (_serverIpCtrl.text.isEmpty || _serverIpCtrl.text == 'dg') {
        _serverIpCtrl.text = servers.first.ipAddress;
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _hostingFormType = 0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Hosting with Server',
                    style: AppTextStyles.titleMedium(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  'Provision a new server and configure its hosting.',
                  style: AppTextStyles.bodySmall(isDark),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.dns,
                            color: Color(0xFF9333EA), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Hosting with Server Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),

                    // SECTION 1: SERVER & INFRASTRUCTURE
                    _buildSectionTitle('SERVER SELECTION', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDropdownInput<dynamic>(
                          'Select Server *',
                          value: _serverHostingSelectedServerId,
                          hintText: '-- Choose Server --',
                          items: servers.map((srv) {
                            return DropdownMenuItem(
                              value: srv.id,
                              child: Text(
                                '${srv.name} (ID: ${srv.id}${srv.ipAddress.isNotEmpty ? ' - ${srv.ipAddress}' : ''})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _serverHostingSelectedServerId = v;
                                final srv = servers.cast<ServerModel?>().firstWhere(
                                  (s) => s?.id.toString() == v.toString(),
                                  orElse: () => null,
                                );
                                if (srv != null && srv.ipAddress.isNotEmpty) {
                                  _serverIpCtrl.text = srv.ipAddress;
                                }
                              });
                            }
                          },
                          prefixIcon: Icons.dns_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 320,
                        ),
                        _buildDropdownInput<String>(
                          'Hosting Type',
                          value: _serverHostingType,
                          items: (hostingTypes.isNotEmpty
                                  ? hostingTypes.map((t) => t.hostingTypeName).toList()
                                  : ['sa', 'vps', 'shared', 'dedicated'])
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverHostingType = v);
                          },
                          prefixIcon: Icons.hexagon_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Hosting Name *',
                          controller: _serverHostingNameCtrl,
                          hint: 'e.g. gfg',
                          prefixIcon: Icons.badge_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'IP Address',
                          controller: _serverIpCtrl,
                          hint: 'e.g. 192.168.1.1',
                          prefixIcon: Icons.router_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Status',
                          value: _serverStatus,
                          items: ['Active', 'Pending', 'Suspended']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverStatus = v);
                          },
                          prefixIcon: Icons.circle_notifications_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Control Panel',
                          value: _serverControlPanel,
                          items: ['Plesk', 'cPanel', 'DirectAdmin', 'CyberPanel']
                              .map((cp) => DropdownMenuItem(value: cp, child: Text(cp)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverControlPanel = v);
                          },
                          prefixIcon: Icons.dashboard_customize_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),

                    // SECTION 2: ACCOUNT CREDENTIALS & NAMESERVERS
                    _buildSectionTitle('ACCOUNT CREDENTIALS & NAMESERVERS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextInput(
                          'Username',
                          controller: _serverUsernameCtrl,
                          hint: 'e.g. admin',
                          prefixIcon: Icons.person_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Password',
                          controller: _serverPasswordCtrl,
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Customer ID',
                          controller: _serverCustomerIdCtrl,
                          hint: 'e.g. cust-100',
                          prefixIcon: Icons.badge_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Nameserver 1',
                          controller: _serverNs1Ctrl,
                          hint: 'e.g. ns1.example.com',
                          prefixIcon: Icons.dns_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Nameserver 2',
                          controller: _serverNs2Ctrl,
                          hint: 'e.g. ns2.example.com',
                          prefixIcon: Icons.dns_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),

                    // SECTION 3: RESOURCE LIMITS
                    _buildSectionTitle('RESOURCE LIMITS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextInput(
                          'Storage Harddisk',
                          controller: _serverStorageCtrl,
                          hint: 'e.g. 100 gb or g',
                          prefixIcon: Icons.sd_storage_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Bandwidth Limit',
                          controller: _serverBandwidthCtrl,
                          hint: 'e.g. 1 tp or hgf',
                          prefixIcon: Icons.speed_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildTextInput(
                          'Addon Domain Limit',
                          controller: _serverAddonLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildTextInput(
                          'Subdomain Limit',
                          controller: _serverSubdomainLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildTextInput(
                          'Email Accounts Limit',
                          controller: _serverEmailLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildTextInput(
                          'FTP Accounts Limit',
                          controller: _serverFtpLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildTextInput(
                          'MySQL Database Limit',
                          controller: _serverMysqlLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildTextInput(
                          'Inode Limit',
                          controller: _serverInodeLimitCtrl,
                          hint: '0',
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                      ],
                    ),

                    // SECTION 4: TECHNICAL SPECIFICATIONS
                    _buildSectionTitle('TECHNICAL SPECIFICATIONS', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDropdownInput<String>(
                          'Web Server',
                          value: _serverWebServer,
                          items: ['Nginx', 'Apache', 'LiteSpeed']
                              .map((ws) => DropdownMenuItem(value: ws, child: Text(ws)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverWebServer = v);
                          },
                          prefixIcon: Icons.public,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'PHP Version',
                          value: _serverPhpVersion,
                          items: ['8.1', '8.2', '8.0', '7.4', '']
                              .map((pv) => DropdownMenuItem(value: pv, child: Text(pv.isEmpty ? 'None' : pv)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverPhpVersion = v);
                          },
                          prefixIcon: Icons.code,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'Database Type',
                          value: _serverDatabaseType,
                          items: ['MariaDB', 'MySQL', 'PostgreSQL']
                              .map((db) => DropdownMenuItem(value: db, child: Text(db)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverDatabaseType = v);
                          },
                          prefixIcon: Icons.dataset_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<String>(
                          'SSL Certificate',
                          value: _serverSslCertificate,
                          items: ["Let's Encrypt", "Let's Encrypt (Free)", "Custom SSL", "None"]
                              .map((ssl) => DropdownMenuItem(value: ssl, child: Text(ssl)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _serverSslCertificate = v);
                          },
                          prefixIcon: Icons.lock_outline,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDropdownInput<bool>(
                          'SSH Access',
                          value: _serverSshAccess,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Yes')),
                            DropdownMenuItem(value: false, child: Text('No')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _serverSshAccess = v);
                          },
                          prefixIcon: Icons.terminal_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                        _buildDropdownInput<bool>(
                          'Backup Enabled',
                          value: _serverBackupEnabled,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Yes')),
                            DropdownMenuItem(value: false, child: Text('No')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _serverBackupEnabled = v);
                          },
                          prefixIcon: Icons.backup_outlined,
                          isDark: isDark,
                          width: isMobile ? double.infinity : 190,
                        ),
                      ],
                    ),

                    // SECTION 5: LIFECYCLE DATES
                    _buildSectionTitle('LIFECYCLE DATES', isDark),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDateClickableInput(
                          'Created Date',
                          value: _formatDateYMD(_serverCreatedDate),
                          onTap: () => _pickDate(
                              (d) => _serverCreatedDate = d, _serverCreatedDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDateClickableInput(
                          'Renewal Date',
                          value: _formatDateYMD(_serverRenewalDate),
                          onTap: () => _pickDate(
                              (d) => _serverRenewalDate = d, _serverRenewalDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                        _buildDateClickableInput(
                          'Expiry Date',
                          value: _formatDateYMD(_serverExpiryDate),
                          onTap: () => _pickDate(
                              (d) => _serverExpiryDate = d, _serverExpiryDate ?? DateTime.now()),
                          isDark: isDark,
                          width: isMobile ? double.infinity : 300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ACTIVE HOSTINGS LIST FOR SERVER HOSTINGS (Matches Photo 2)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF4F46E5), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Active Hostings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${serverHostings.length} Total',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 24),

                    if (serverHostings.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No active hostings yet.'),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: serverHostings.map((sh) {
                          return SizedBox(
                            width: isMobile ? double.infinity : 300,
                            child: _buildActiveServerHostingCard(sh, isDark),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),

        // Footer Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last deployed: Recently',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${serverHostings.length} Hostings Configured',
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
                      _discardServerForm();
                      setState(() => _hostingFormType = 0);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Discard Changes',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoadingAction
                        ? null
                        : _saveServerHostingConfiguration,
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
                    child: state.isLoadingAction
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Configuration',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Active Server Hosting Card (Matches Photo 2) ---
  Widget _buildActiveServerHostingCard(ServerHostingModel sh, bool isDark) {
    final isSuspended = sh.status.toLowerCase() == 'suspended';
    final isPending = sh.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language,
                    color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sh.hostingName.isNotEmpty ? sh.hostingName : 'Unnamed Hosting',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.link, size: 12, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'No domain',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Icons: Eye, Pencil, Trash
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showFullServerHostingDetailsModal(sh, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.visibility_outlined,
                          size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showEditServerHostingModal(sh, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _confirmDeleteServerHosting(sh, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 16, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Server ID:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                sh.serverId != null ? '${sh.serverId}' : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                sh.username.isNotEmpty ? sh.username : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IP Address:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                sh.ipAddress.isNotEmpty ? sh.ipAddress : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hosting Type Hexagon Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hexagon_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  sh.hostingType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuspended || isPending
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sh.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSuspended || isPending
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers for resolving mapping labels ---
  String _resolveDomainName(dynamic domainId, List<DomainModel> domains) {
    final d = domains.cast<DomainModel?>().firstWhere(
      (item) => item?.id.toString() == domainId.toString(),
      orElse: () => null,
    );
    return d != null ? d.displayName : 'Unknown Domain';
  }

  String _resolveHostingName(
    dynamic hostingId,
    List<ServerHostingModel> serverHostings,
    List<HostingNewModel> hostingNewList,
  ) {
    final sh = serverHostings.cast<ServerHostingModel?>().firstWhere(
      (item) => item?.id.toString() == hostingId.toString(),
      orElse: () => null,
    );
    if (sh != null && sh.hostingName.isNotEmpty) return sh.hostingName;

    final hn = hostingNewList.cast<HostingNewModel?>().firstWhere(
      (item) => item?.id.toString() == hostingId.toString(),
      orElse: () => null,
    );
    if (hn != null && hn.hostingName.isNotEmpty) return hn.hostingName;

    return 'Hosting #$hostingId';
  }

  // --- 2. Domain to Hosting Mapping Tab (Matches Photo 3 & 4) ---
  Widget _buildDomainMappingTab(
    BuildContext context,
    HostingState state,
    bool isDark,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final serverHostings = state.serverHostings.asData?.value ?? [];
    final hostingNewList = state.hostingNewList.asData?.value ?? [];
    final domains = state.domains.asData?.value ?? [];
    final mappings = state.mappings.asData?.value ?? [];

    // Unified hosting items for dropdown
    final unifiedHostings = <UnifiedHostingItem>[
      ...serverHostings.map((sh) => UnifiedHostingItem(
        id: sh.id,
        name: sh.hostingName.isNotEmpty ? sh.hostingName : 'Hosting ${sh.id}',
        controlPanel: sh.controlPanel.isNotEmpty ? sh.controlPanel : 'Plesk',
        ipAddress: sh.ipAddress,
        status: sh.status,
        isServerHosting: true,
        raw: sh,
      )),
      ...hostingNewList.map((hn) => UnifiedHostingItem(
        id: hn.id,
        name: hn.hostingName.isNotEmpty ? hn.hostingName : 'Hosting ${hn.id}',
        controlPanel: hn.controlPanel.isNotEmpty ? hn.controlPanel : 'cPanel',
        ipAddress: hn.ipAddress,
        status: hn.status,
        isServerHosting: false,
        raw: hn,
      )),
    ];

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
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top dropdown row with link icon in the middle
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildDropdownInput<UnifiedHostingItem>(
                    'Select Hosting Account *',
                    value: _mappingUnifiedHosting,
                    hintText: '-- Choose Hosting --',
                    items: unifiedHostings.map((h) {
                      return DropdownMenuItem(
                        value: h,
                        child: Text(
                          h.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _mappingUnifiedHosting = val);
                    },
                    prefixIcon: Icons.storage,
                    isDark: isDark,
                    width: isMobile ? double.infinity : 300,
                  ),
                  if (!isMobile)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Icon(Icons.link,
                            color: Color(0xFF94A3B8), size: 20),
                      ),
                    ),
                  _buildDropdownInput<DomainModel>(
                    'Select Domains *',
                    value: _mappingSelectedDomain,
                    hintText: 'Select Domains...',
                    items: domains.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _mappingSelectedDomain = val);
                    },
                    prefixIcon: Icons.language,
                    isDark: isDark,
                    width: isMobile ? double.infinity : 300,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Detail Preview Boxes Row
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Left: Hosting Details Box
                  Container(
                    width: isMobile ? double.infinity : 320,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: _mappingUnifiedHosting == null
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.storage,
                                      size: 18, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hosting Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Select a hosting account to view details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : const Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storage,
                                      size: 18, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hosting Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Eye Icon in Header -> opens Full Details Modal!
                                  InkWell(
                                    onTap: () {
                                      if (_mappingUnifiedHosting!.raw is ServerHostingModel) {
                                        _showFullServerHostingDetailsModal(
                                          _mappingUnifiedHosting!.raw as ServerHostingModel,
                                          isDark,
                                        );
                                      } else if (_mappingUnifiedHosting!.raw is HostingNewModel) {
                                        _showFullHostingDetailsModal(
                                          _mappingUnifiedHosting!.raw as HostingNewModel,
                                          isDark,
                                        );
                                      }
                                    },
                                    child: const Icon(
                                      Icons.visibility_outlined,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                'Name:',
                                _mappingUnifiedHosting!.name,
                                isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Control Panel:',
                                _mappingUnifiedHosting!.controlPanel,
                                isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'IP Address:',
                                _mappingUnifiedHosting!.ipAddress,
                                isDark,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _mappingUnifiedHosting!.status.toLowerCase() == 'suspended'
                                          ? const Color(0xFFFEF2F2)
                                          : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _mappingUnifiedHosting!.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _mappingUnifiedHosting!.status.toLowerCase() == 'suspended'
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  // Right: Domain Details Box
                  Container(
                    width: isMobile ? double.infinity : 340,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: _mappingSelectedDomain == null
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.language,
                                      size: 18, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Domain Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Select domains to view details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : const Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.language,
                                      size: 18, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Domain Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Domains Selected:',
                                      style: TextStyle(
                                          fontSize: 12, color: Color(0xFF64748B))),
                                  const Text('1',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Inner Domain Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Domain 1',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.visibility_outlined,
                                            size: 16, color: Color(0xFF64748B)),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(),
                                    ),
                                    _buildInfoRow(
                                      'Name:',
                                      '🌐 ${_mappingSelectedDomain!.displayName}',
                                      isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      'Provider:',
                                      _mappingSelectedDomain!.registrar,
                                      isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      'Cost:',
                                      '\$${_mappingSelectedDomain!.cost.toStringAsFixed(2)}',
                                      isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Status:',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Active',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF10B981),
                                            ),
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
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: (_mappingUnifiedHosting != null &&
                          _mappingSelectedDomain != null)
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final payload = {
                            'hosting_id': _mappingUnifiedHosting!.id,
                            'domain_id': _mappingSelectedDomain!.id,
                            'mapping_status': 'active',
                          };
                          final success = await ref
                              .read(hostingControllerProvider.notifier)
                              .createMapping(payload);
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Domain mapped to hosting successfully!'
                                    : 'Mapping saved'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Save Mapping',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Configured Mappings Section (Matches Photo 5)
        Text(
          'Configured Mappings',
          style: AppTextStyles.titleMedium(isDark)
              .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'View and manage your active domain to hosting connections.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 16),

        if (mappings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
              ),
            ),
            child: Center(
              child: Text(
                'No mappings configured yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          )
        else
          Column(
            children: mappings.map((m) {
              final resolvedDomain = _resolveDomainName(m.domainId, domains);
              final resolvedHosting = _resolveHostingName(m.hostingId, serverHostings, hostingNewList);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Connection indicator + Actions
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ACTIVE CONNECTION #${m.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _showMappingDetailsModal(m, resolvedDomain, resolvedHosting, isDark),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _showEditMappingModal(m, isDark),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _confirmDeleteMapping(m, isDark),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Main Mapping Row (Responsive - stacks on compact screens to prevent overflow!)
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isCompact = constraints.maxWidth < 500;
                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.language, size: 18, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('DOMAIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                        const SizedBox(height: 2),
                                        Text(resolvedDomain, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
                                    child: const Icon(Icons.link, size: 14, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.storage, size: 18, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('HOSTING ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                        const SizedBox(height: 2),
                                        Text(resolvedHosting, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            // Domain Item
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.language, size: 18, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('DOMAIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                        const SizedBox(height: 2),
                                        Text(resolvedDomain, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Middle Link Graphic
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(height: 1, width: 24, color: const Color(0xFFE2E8F0)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Icon(Icons.link, size: 16, color: Color(0xFF94A3B8)),
                                  ),
                                  Container(height: 1, width: 24, color: const Color(0xFFE2E8F0)),
                                ],
                              ),
                            ),

                            // Hosting Account Item
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.storage, size: 18, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('HOSTING ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                        const SizedBox(height: 2),
                                        Text(resolvedHosting, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 48),
      ],
    );
  }

  // --- Modal: Mapping Details ---
  void _showMappingDetailsModal(
    HostingDomainMappingModel m,
    String resolvedDomain,
    String resolvedHosting,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
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
                      child: const Icon(Icons.link, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Domain Mapping Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoRow('Connection ID:', '#${m.id}', isDark),
                const SizedBox(height: 12),
                _buildInfoRow('Status:', m.mappingStatus.toUpperCase(), isDark),
                const SizedBox(height: 12),
                _buildInfoRow('Domain Name:', resolvedDomain, isDark),
                const SizedBox(height: 12),
                _buildInfoRow('Domain ID:', '${m.domainId}', isDark),
                const SizedBox(height: 12),
                _buildInfoRow('Hosting Account:', resolvedHosting, isDark),
                const SizedBox(height: 12),
                _buildInfoRow('Hosting ID:', '${m.hostingId}', isDark),
                if (m.mappedAt != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Mapped At:', _formatDateYMD(m.mappedAt), isDark),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
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

  // --- Modal: Edit Mapping ---
  void _showEditMappingModal(HostingDomainMappingModel m, bool isDark) {
    final state = ref.read(hostingControllerProvider);
    final serverHostings = state.serverHostings.asData?.value ?? [];
    final hostingNewList = state.hostingNewList.asData?.value ?? [];
    final domains = state.domains.asData?.value ?? [];

    final unifiedHostings = <UnifiedHostingItem>[
      ...serverHostings.map((sh) => UnifiedHostingItem(
        id: sh.id,
        name: sh.hostingName.isNotEmpty ? sh.hostingName : 'Hosting ${sh.id}',
        controlPanel: sh.controlPanel.isNotEmpty ? sh.controlPanel : 'Plesk',
        ipAddress: sh.ipAddress,
        status: sh.status,
        isServerHosting: true,
        raw: sh,
      )),
      ...hostingNewList.map((hn) => UnifiedHostingItem(
        id: hn.id,
        name: hn.hostingName.isNotEmpty ? hn.hostingName : 'Hosting ${hn.id}',
        controlPanel: hn.controlPanel.isNotEmpty ? hn.controlPanel : 'cPanel',
        ipAddress: hn.ipAddress,
        status: hn.status,
        isServerHosting: false,
        raw: hn,
      )),
    ];

    UnifiedHostingItem? selectedHost = unifiedHostings.cast<UnifiedHostingItem?>().firstWhere(
      (h) => h?.id.toString() == m.hostingId.toString(),
      orElse: () => unifiedHostings.isNotEmpty ? unifiedHostings.first : null,
    );
    DomainModel? selectedDom = domains.cast<DomainModel?>().firstWhere(
      (d) => d?.id.toString() == m.domainId.toString(),
      orElse: () => domains.isNotEmpty ? domains.first : null,
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
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
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Mapping #${m.id}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownInput<UnifiedHostingItem>(
                      'Hosting Account',
                      value: selectedHost,
                      items: unifiedHostings.map((h) {
                        return DropdownMenuItem(value: h, child: Text(h.name));
                      }).toList(),
                      onChanged: (v) => setModalState(() => selectedHost = v),
                      prefixIcon: Icons.storage,
                      isDark: isDark,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownInput<DomainModel>(
                      'Domain',
                      value: selectedDom,
                      items: domains.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d.displayName));
                      }).toList(),
                      onChanged: (v) => setModalState(() => selectedDom = v),
                      prefixIcon: Icons.language,
                      isDark: isDark,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: (selectedHost != null && selectedDom != null)
                              ? () async {
                                  final nav = Navigator.of(dialogCtx);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final payload = {
                                    'hosting_id': selectedHost!.id,
                                    'domain_id': selectedDom!.id,
                                    'mapping_status': 'active',
                                  };
                                  final success = await ref
                                      .read(hostingControllerProvider.notifier)
                                      .updateMapping(m.id, payload);
                                  nav.pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Mapping updated successfully!'
                                          : 'Failed to update mapping'),
                                      backgroundColor: success
                                          ? const Color(0xFF10B981)
                                          : Colors.redAccent,
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Update Mapping'),
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

  // --- Modal: Delete Mapping Confirmation ---
  void _confirmDeleteMapping(HostingDomainMappingModel m, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'Delete Mapping',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to remove connection #${m.id}?',
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
                final nav = Navigator.of(dialogCtx);
                final messenger = ScaffoldMessenger.of(context);
                nav.pop();
                final success = await ref
                    .read(hostingControllerProvider.notifier)
                    .deleteMapping(m.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Mapping deleted successfully!'
                        : 'Failed to delete mapping'),
                    backgroundColor: success
                        ? const Color(0xFF10B981)
                        : Colors.redAccent,
                  ),
                );
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

  // --- Modal: Full Server Hosting Details ---
  void _showFullServerHostingDetailsModal(ServerHostingModel sh, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 650,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(28),
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
                      child: const Icon(Icons.dns, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Full Server Hosting Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildDetailFieldBox('HOSTING NAME', sh.hostingName, isDark),
                          _buildDetailFieldBox('SERVER ID', '${sh.serverId ?? '-'}', isDark),
                          if (sh.serverName != null && sh.serverName!.isNotEmpty)
                            _buildDetailFieldBox('SERVER NAME', sh.serverName!, isDark),
                          _buildDetailFieldBox('HOSTING TYPE', sh.hostingType, isDark),
                          _buildDetailFieldBox('IP ADDRESS', sh.ipAddress, isDark),
                          _buildDetailFieldBox('STATUS', sh.status, isDark),
                          _buildDetailFieldBox('CONTROL PANEL', sh.controlPanel, isDark),
                          _buildDetailFieldBox('USERNAME', sh.username, isDark),
                          _buildDetailFieldBox('PASSWORD', sh.password, isDark),
                          _buildDetailFieldBox('CUSTOMER ID', sh.customerId, isDark),
                          _buildDetailFieldBox('NAMESERVER 1', sh.nameserver1, isDark),
                          _buildDetailFieldBox('NAMESERVER 2', sh.nameserver2, isDark),
                          _buildDetailFieldBox('STORAGE HARDDISK', sh.storageHarddisk, isDark),
                          _buildDetailFieldBox('BANDWIDTH LIMIT', sh.bandwidthLimit, isDark),
                          _buildDetailFieldBox('ADDON DOMAIN LIMIT', '${sh.addonDomainLimit}', isDark),
                          _buildDetailFieldBox('SUBDOMAIN LIMIT', '${sh.subdomainLimit}', isDark),
                          _buildDetailFieldBox('WEB SERVER', sh.webServer, isDark),
                          _buildDetailFieldBox('PHP VERSION', sh.phpVersion, isDark),
                          _buildDetailFieldBox('DATABASE TYPE', sh.databaseType, isDark),
                          _buildDetailFieldBox('SSL CERTIFICATE', sh.sslCertificate, isDark),
                          _buildDetailFieldBox('SSH ACCESS', sh.sshAccess ? 'Enabled' : 'Disabled', isDark),
                          _buildDetailFieldBox('BACKUP ENABLED', sh.backupEnabled ? 'Enabled' : 'Disabled', isDark),
                          _buildDetailFieldBox('CREATED DATE', sh.createdDate, isDark),
                          _buildDetailFieldBox('EXPIRY DATE', sh.expiryDate, isDark),
                          _buildDetailFieldBox('RENEWAL DATE', sh.renewalDate, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
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

  // --- Modal: Edit Server Hosting ---
  void _showEditServerHostingModal(ServerHostingModel sh, bool isDark) {
    final nameCtrl = TextEditingController(text: sh.hostingName);
    String status = sh.status;
    final ipCtrl = TextEditingController(text: sh.ipAddress);
    String controlPanel = sh.controlPanel.isNotEmpty ? sh.controlPanel : 'Plesk';
    String webServer = sh.webServer.isNotEmpty ? sh.webServer : 'Nginx';
    final passwordCtrl = TextEditingController(text: sh.password);

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
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edit Hosting with Server',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      'Hosting Name',
                      controller: nameCtrl,
                      prefixIcon: Icons.badge_outlined,
                      isDark: isDark,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            'IP Address',
                            controller: ipCtrl,
                            prefixIcon: Icons.router_outlined,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Status',
                            value: status,
                            items: ['Active', 'Pending', 'Suspended']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => status = v);
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Control Panel',
                            value: controlPanel,
                            items: ['Plesk', 'cPanel', 'DirectAdmin', 'CyberPanel']
                                .map((cp) => DropdownMenuItem(value: cp, child: Text(cp)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => controlPanel = v);
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Web Server',
                            value: webServer,
                            items: ['Nginx', 'Apache', 'LiteSpeed']
                                .map((ws) => DropdownMenuItem(value: ws, child: Text(ws)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => webServer = v);
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextInput(
                      'Password',
                      controller: passwordCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isDark: isDark,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final nav = Navigator.of(dialogCtx);
                            final messenger = ScaffoldMessenger.of(context);
                            final payload = {
                              ...sh.toJson(),
                              'hosting_name': nameCtrl.text.trim(),
                              'status': status,
                              'ip_address': ipCtrl.text.trim(),
                              'control_panel': controlPanel,
                              'web_server': webServer,
                              'password': passwordCtrl.text.trim(),
                            };
                            final success = await ref
                                .read(hostingControllerProvider.notifier)
                                .updateServerHosting(sh.id, payload);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Hosting updated successfully!'
                                    : 'Failed to update hosting'),
                                backgroundColor: success
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
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

  // --- Modal: Delete Server Hosting Confirmation ---
  void _confirmDeleteServerHosting(ServerHostingModel sh, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'Delete Hosting',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${sh.hostingName}?',
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
                final nav = Navigator.of(dialogCtx);
                final messenger = ScaffoldMessenger.of(context);
                nav.pop();
                final success = await ref
                    .read(hostingControllerProvider.notifier)
                    .deleteServerHosting(sh.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Hosting deleted successfully!'
                        : 'Failed to delete hosting'),
                    backgroundColor: success
                        ? const Color(0xFF10B981)
                        : Colors.redAccent,
                  ),
                );
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

  // --- Modal: Full Hosting Details (Matches Photo 5) ---
  void _showFullHostingDetailsModal(HostingNewModel h, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 650,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(28),
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
                      child: const Icon(Icons.storage,
                          color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Full Hosting Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close,
                          size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildDetailFieldBox(
                              'SERVICE PROVIDER', h.serviceProvider, isDark),
                          _buildDetailFieldBox(
                              'HOSTING TYPE', h.hostingType, isDark),
                          _buildDetailFieldBox(
                              'IP ADDRESS', h.ipAddress, isDark),
                          _buildDetailFieldBox('STATUS', h.status, isDark),
                          _buildDetailFieldBox(
                              'CONTROL PANEL', h.controlPanel, isDark),
                          _buildDetailFieldBox(
                              'HOSTING NAME', h.hostingName, isDark),
                          _buildDetailFieldBox('USERNAME', h.username, isDark),
                          _buildDetailFieldBox('PASSWORD', h.password, isDark),
                          _buildDetailFieldBox(
                              'CUSTOMER ID', h.customerId, isDark),
                          _buildDetailFieldBox(
                              'NAMESERVER 1', h.nameserver1, isDark),
                          _buildDetailFieldBox(
                              'NAMESERVER 2', h.nameserver2, isDark),
                          _buildDetailFieldBox(
                              'STORAGE HARDDISK', h.storageHarddisk, isDark),
                          _buildDetailFieldBox(
                              'BANDWIDTH LIMIT', h.bandwidthLimit, isDark),
                          _buildDetailFieldBox('ADDON DOMAIN LIMIT',
                              '${h.addonDomainLimit}', isDark),
                          _buildDetailFieldBox(
                              'SUBDOMAIN LIMIT', '${h.subdomainLimit}', isDark),
                          _buildDetailFieldBox(
                              'WEB SERVER', h.webServer, isDark),
                          _buildDetailFieldBox(
                              'DATABASE TYPE', h.databaseType, isDark),
                          _buildDetailFieldBox(
                              'SSL CERTIFICATE', h.sslCertificate, isDark),
                          _buildDetailFieldBox(
                              'CREATED DATE', h.createdDate, isDark),
                          _buildDetailFieldBox(
                              'EXPIRY DATE', h.expiryDate, isDark),
                          _buildDetailFieldBox(
                              'RENEWAL DATE', h.renewalDate, isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
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

  Widget _buildDetailFieldBox(String label, String value, bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : '-',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Modal: Edit Hosting ---
  void _showEditHostingModal(HostingNewModel h, bool isDark) {
    final nameCtrl = TextEditingController(text: h.hostingName);
    String status = h.status;
    final ipCtrl = TextEditingController(text: h.ipAddress);
    String controlPanel = h.controlPanel.isNotEmpty ? h.controlPanel : 'Plesk';
    String webServer = h.webServer.isNotEmpty ? h.webServer : 'Nginx';

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
                            'Edit Hosting',
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
                          child: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildTextInput(
                      'Hosting Name *',
                      controller: nameCtrl,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextInput(
                            'IP Address',
                            controller: ipCtrl,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Status',
                            value: status,
                            items: ['Active', 'Pending', 'Suspended']
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setModalState(() => status = v);
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Control Panel',
                            value: controlPanel,
                            items: ['Plesk', 'cPanel', 'DirectAdmin', 'CyberPanel']
                                .map((cp) => DropdownMenuItem(
                                    value: cp, child: Text(cp)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => controlPanel = v);
                              }
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownInput<String>(
                            'Web Server',
                            value: webServer,
                            items: ['Nginx', 'Apache', 'LiteSpeed']
                                .map((ws) => DropdownMenuItem(
                                    value: ws, child: Text(ws)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => webServer = v);
                              }
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final nav = Navigator.of(dialogCtx);
                            final messenger = ScaffoldMessenger.of(context);
                            final payload = {
                              ...h.toJson(),
                              'hosting_name': nameCtrl.text.trim(),
                              'status': status,
                              'ip_address': ipCtrl.text.trim(),
                              'control_panel': controlPanel,
                              'web_server': webServer,
                            };
                            final success = await ref
                                .read(hostingControllerProvider.notifier)
                                .updateHostingNew(h.id, payload);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Hosting updated successfully!'
                                    : 'Failed to update hosting'),
                                backgroundColor: success
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
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

  // --- Modal: Delete Confirmation ---
  void _confirmDeleteHosting(HostingNewModel h, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: Text(
            'Delete Hosting',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${h.hostingName}?',
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
                final nav = Navigator.of(dialogCtx);
                final messenger = ScaffoldMessenger.of(context);
                nav.pop();
                final success = await ref
                    .read(hostingControllerProvider.notifier)
                    .deleteHostingNew(h.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Hosting deleted successfully!'
                        : 'Failed to delete hosting'),
                    backgroundColor: success
                        ? const Color(0xFF10B981)
                        : Colors.redAccent,
                  ),
                );
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

  // --- UI Helpers ---
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: isDark ? Colors.white : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(
    String label, {
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    bool isDark = false,
    double? width,
    bool isPassword = false,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.replaceAll(' *', ''),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ),
              ),
              if (label.contains('*'))
                const Text(' *',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444))),
            ],
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
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textMutedDark
                            : const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildDropdownInput<T>(
    String label, {
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
    IconData? prefixIcon,
    bool isDark = false,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.replaceAll(' *', ''),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF64748B),
                ),
              ),
              if (label.contains('*'))
                const Text(' *',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444))),
            ],
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
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: items.any((i) => i.value == value) ? value : null,
                      hint: Text(
                        hintText ?? 'Select Option',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textMutedDark
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      items: items,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateClickableInput(
    String label, {
    required String value,
    required VoidCallback onTap,
    bool isDark = false,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
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
          InkWell(
            onTap: onTap,
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
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value.isNotEmpty ? value : 'Select Date',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: value.isNotEmpty
                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Acme Top Nav Bar ---
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
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
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
          Expanded(
            child: Row(
              children: [
                _buildTopNavLink(
                    title: 'Dashboard',
                    route: RouteNames.dashboard,
                    isDark: isDark,
                    context: context),
                _buildTopNavLink(
                    title: 'Data Center',
                    route: RouteNames.dataCenter,
                    isDark: isDark,
                    context: context),
                _buildTopNavLink(
                    title: 'Server',
                    route: RouteNames.servers,
                    isDark: isDark,
                    context: context),
                _buildTopNavLink(
                    title: 'Domain',
                    route: RouteNames.domains,
                    isDark: isDark,
                    context: context),
                _buildTopNavLink(
                    title: 'Hosting',
                    route: RouteNames.hosting,
                    isActive: true,
                    isDark: isDark,
                    context: context),
                _buildTopNavLink(
                    title: 'Dynamic Field',
                    route: RouteNames.dynamicField,
                    isDark: isDark,
                    context: context),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.search,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundColor:
                isDark ? AppColors.primaryDark : AppColors.primaryLight,
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
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF6366F1), width: 2))
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
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.circle, size: 4, color: Color(0xFF6366F1)),
            ]
          ],
        ),
      ),
    );
  }
}
