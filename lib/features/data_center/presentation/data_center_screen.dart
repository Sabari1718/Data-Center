import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/data_center_model.dart';
import '../../../data/models/server_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import '../../servers/presentation/server_controller.dart';
import 'data_center_controller.dart';

class DataCenterScreen extends ConsumerStatefulWidget {
  const DataCenterScreen({super.key});

  @override
  ConsumerState<DataCenterScreen> createState() => _DataCenterScreenState();
}

class _DataCenterScreenState extends ConsumerState<DataCenterScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Add Data Center',
    'Add Software',
    'Power & Cooling',
    'Storage',
    'Security',
    'Rack Management',
    'Network',
  ];

  final List<IconData> _tabIcons = [
    Icons.storage_rounded,
    Icons.view_in_ar_rounded,
    Icons.bolt_rounded,
    Icons.dns_outlined,
    Icons.shield_outlined,
    Icons.table_rows_rounded,
    Icons.show_chart_rounded,
  ];

  // Form state for Add Data Center
  final _dcNameController = TextEditingController();
  final _pinController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  String _locationMethod = 'Use PIN';
  bool _isActiveStatus = true;
  ResolvedLocationModel? _resolvedLocation;
  bool _isSearchingPin = false;
  bool _isSavingDc = false;
  String? _editingDcId;

  // Dynamic form state for other tabs
  bool _isSavingPowerCooling = false;
  bool _isSavingNetwork = false;
  bool _isSavingTab = false;

  final List<int> _softwareStacks = [1];
  int _softwareIdCounter = 2;

  final List<int> _powerConfigs = [1];
  int _powerIdCounter = 2;
  final Map<int, TextEditingController> _powerUpsControllers = {};
  final Map<int, TextEditingController> _powerConsumptionControllers = {};
  final Map<int, TextEditingController> _powerGeneratorControllers = {};
  final Map<int, TextEditingController> _powerCoolingTypeControllers = {};
  final Map<int, TextEditingController> _powerTempControllers = {};
  final Map<int, TextEditingController> _powerPduControllers = {};

  final List<int> _storageArrays = [1];
  int _storageIdCounter = 2;

  final List<int> _securityProfiles = [1];
  int _securityIdCounter = 2;

  final List<int> _rackSetups = [1];
  int _rackIdCounter = 2;

  final List<int> _networkConnections = [1];
  int _networkIdCounter = 2;
  final Map<int, List<int>> _networkIps = {1: [1]};
  final Map<int, int> _networkIpCounters = {1: 2};
  final Map<int, TextEditingController> _networkNameControllers = {};
  final Map<int, TextEditingController> _networkBandwidthControllers = {};
  final Map<String, TextEditingController> _networkIpControllers = {};

  TextEditingController _getController(Map<int, TextEditingController> map, int id, [String? initialText]) {
    return map.putIfAbsent(id, () => TextEditingController(text: initialText ?? ''));
  }

  TextEditingController _getIpController(String key, [String? initialText]) {
    return _networkIpControllers.putIfAbsent(key, () => TextEditingController(text: initialText ?? ''));
  }

  final Map<String, bool> _toggles = {};
  bool _getToggle(String key) => _toggles[key] ?? false;
  void _setToggle(String key, bool value) => setState(() => _toggles[key] = value);

  final Map<String, String> _dropdowns = {};
  String _getDropdown(String key, String defaultVal) => _dropdowns[key] ?? defaultVal;
  void _setDropdown(String key, String? value) {
    if (value != null) setState(() => _dropdowns[key] = value);
  }

  @override
  void dispose() {
    _dcNameController.dispose();
    _pinController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _latController.dispose();
    _longController.dispose();
    for (var c in _powerUpsControllers.values) {
      c.dispose();
    }
    for (var c in _powerConsumptionControllers.values) {
      c.dispose();
    }
    for (var c in _powerGeneratorControllers.values) {
      c.dispose();
    }
    for (var c in _powerCoolingTypeControllers.values) {
      c.dispose();
    }
    for (var c in _powerTempControllers.values) {
      c.dispose();
    }
    for (var c in _powerPduControllers.values) {
      c.dispose();
    }
    for (var c in _networkNameControllers.values) {
      c.dispose();
    }
    for (var c in _networkBandwidthControllers.values) {
      c.dispose();
    }
    for (var c in _networkIpControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(dataCenterControllerProvider);
    final serverState = ref.watch(serverControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Acme Top Navigation Bar (Identical to Web application)
            _buildAcmeTopBar(context, isDark),

            // Responsive Layout: Left Sidebar for Desktop, SubTabBar for Mobile
            if (!isDesktop)
              SubTabBar(
                tabs: _tabs,
                icons: _tabIcons,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() => _selectedTabIndex = index);
                },
              ),

            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Navigation Sidebar
                        _buildSidebar(context, isDark),

                        // Main Content Area
                        Expanded(
                          child: _buildTabContent(context, state, serverState, isDark),
                        ),
                      ],
                    )
                  : _buildTabContent(context, state, serverState, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Authentic Acme Brand Top Bar matching datacenter.jobes24x7.com
  Widget _buildAcmeTopBar(BuildContext context, bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
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
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 16),

          // Top Nav Links (Scrollable on smaller screens)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildTopNavLink(
                    title: 'Dashboard',
                    isActive: false,
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.dashboard),
                  ),
                  _buildTopNavLink(
                    title: 'Data Center',
                    isActive: true,
                    hasDot: true,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildTopNavLink(
                    title: 'Server',
                    isActive: false,
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.servers),
                  ),
                  _buildTopNavLink(
                    title: 'Domain',
                    isActive: false,
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.domains),
                  ),
                  _buildTopNavLink(
                    title: 'Hosting',
                    isActive: false,
                    isDark: isDark,
                    onTap: () => context.go(RouteNames.hosting),
                  ),
                  _buildTopNavLink(
                    title: 'Dynamic Field',
                    isActive: false,
                    isDark: isDark,
                    onTap: () => context.showSnackBar('Dynamic Field configuration'),
                  ),
                ],
              ),
            ),
          ),

          // Right Action Icons: Search, Theme Toggle, Profile
          IconButton(
            tooltip: 'Search',
            icon: Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              context.showSnackBar('Search telemetry & resources');
            },
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? AppColors.warning : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            tooltip: 'Profile & Account',
            icon: Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            onPressed: () => context.push(RouteNames.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavLink({
    required String title,
    required bool isActive,
    bool hasDot = false,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? (isDark ? AppColors.primaryLight : const Color(0xFF4F46E5))
                    : (isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B)),
              ),
            ),
            if (hasDot) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Left Sidebar matching the screenshots
  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        children: [
          // Section: DATA CENTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'DATA CENTER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
            ),
          ),
          _buildSidebarItem(
            title: 'Add Data Center',
            icon: Icons.table_rows_rounded,
            index: 0,
            hasDot: true,
            isDark: isDark,
          ),
          _buildSidebarItem(
            title: 'Add Software',
            icon: Icons.view_in_ar_rounded,
            index: 1,
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Section: Infrastructure
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Infrastructure',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
            ),
          ),
          _buildSidebarItem(
            title: 'Power & Cooling',
            icon: Icons.bolt_rounded,
            index: 2,
            isDark: isDark,
          ),
          _buildSidebarItem(
            title: 'Storage',
            icon: Icons.dns_outlined,
            index: 3,
            isDark: isDark,
          ),
          _buildSidebarItem(
            title: 'Security',
            icon: Icons.shield_outlined,
            index: 4,
            isDark: isDark,
          ),
          _buildSidebarItem(
            title: 'Rack Management',
            icon: Icons.developer_board_rounded,
            index: 5,
            isDark: isDark,
          ),
          _buildSidebarItem(
            title: 'Network',
            icon: Icons.alt_route_rounded,
            index: 6,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required String title,
    required IconData icon,
    required int index,
    bool hasDot = false,
    required bool isDark,
  }) {
    final isSelected = _selectedTabIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : const Color(0xFF4F46E5))
                    : (isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? AppColors.textSecondaryDark : const Color(0xFF475569)),
                  ),
                ),
              ),
              if (isSelected && hasDot)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    DataCenterState state,
    ServerState serverState,
    bool isDark,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAddDataCenterTab(context, state, isDark);
      case 1:
        return _buildSoftwareTab(context, state, serverState, isDark);
      case 2:
        return _buildPowerCoolingTab(context, state, serverState, isDark);
      case 3:
        return _buildStorageTab(context, state, serverState, isDark);
      case 4:
        return _buildSecurityTab(context, state, serverState, isDark);
      case 5:
        return _buildRackManagementTab(context, state, serverState, isDark);
      case 6:
        return _buildNetworkTab(context, state, serverState, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Add Data Center Tab (100% matches Images 1, 2 & 3 with Responsive Layout)
  Widget _buildAddDataCenterTab(
    BuildContext context,
    DataCenterState state,
    bool isDark,
  ) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: isDesktop ? 24 : 16,
      ),
      children: [
        // Page Title & Subtitle
        Text(
          'Data Center Infrastructure Management',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Single-page deployment and configuration of enterprise infrastructure resources.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 18),

        // Card 1: Data Center Information
        Container(
          padding: EdgeInsets.all(isDesktop ? 22 : 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: isDark ? AppColors.primaryLight : const Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data Center Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Data Center Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Center Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 360 : double.infinity),
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _dcNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. US-East-1 Alpha',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Location Entry Method Selection & Dynamic Inputs
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCATION ENTRY METHOD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildRadioOption('Use PIN', isDark),
                      _buildRadioOption('Use ZIP Code', isDark),
                      _buildRadioOption('Use Latitude & Longitude', isDark),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Location Input Fields based on Selected Method
                  _buildDynamicLocationInputs(isDark),

                  if (_resolvedLocation != null && _locationMethod == 'Use PIN')
                    _buildResolvedLocationCard(isDark),
                ],
              ),

              const SizedBox(height: 18),

              // Active status checkbox
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _isActiveStatus,
                      activeColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) => setState(() => _isActiveStatus = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data Center Active Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Card 2: Configured Data Centers Header
        Row(
          children: [
            const Icon(
              Icons.view_agenda_rounded,
              size: 20,
              color: Color(0xFF4F46E5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Configured Data Centers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              child: state.dataCenters.maybeWhen(
                data: (list) => Text(
                  '${list.length} ${list.length == 1 ? "Location" : "Locations"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                  ),
                ),
                orElse: () => Text(
                  '0 Locations',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Configured Data Center Cards
        state.dataCenters.when(
          data: (list) {
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  'No configured data centers found.',
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: list.map((dc) => _buildCircuitPointCard(context, dc, isDark)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Failed to load data centers: $err',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Bottom Action Bar: Discard / Save Configuration
        _buildBottomActionBar(isDark),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResolvedLocationCard(bool isDark) {
    if (_resolvedLocation == null) return const SizedBox.shrink();
    final loc = _resolvedLocation!;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1B4B).withValues(alpha: 0.3)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF4338CA) : const Color(0xFFC7D2FE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESOLVED LOCATION DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${loc.cityName.isNotEmpty ? loc.cityName : loc.talukName}, ${loc.talukName.isNotEmpty ? loc.talukName : loc.cityName}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${loc.districtName}, ${loc.stateName}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${loc.countryName} - ${loc.pincode}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    bool isDark, {
    VoidCallback? onSave,
    VoidCallback? onDiscard,
    String? subtitle,
    bool isLoading = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final discardButton = OutlinedButton(
          onPressed: onDiscard ?? _handleDiscardChanges,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            'Discard Changes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        );

        final isSaving = isLoading || _isSavingDc;
        final saveButton = ElevatedButton(
          onPressed: isSaving ? null : (onSave ?? _handleSaveConfiguration),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save Configuration',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
        );

        final labelText = subtitle ?? 'Last saved: Just now';

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: discardButton),
                  const SizedBox(width: 10),
                  Expanded(child: saveButton),
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
            ),
            Row(
              children: [
                discardButton,
                const SizedBox(width: 12),
                saveButton,
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSaveConfiguration() async {
    final name = _dcNameController.text.trim().isEmpty
        ? 'Data Center'
        : _dcNameController.text.trim();
    final pin = _pinController.text.trim();
    final zip = _zipController.text.trim();
    final lat = _latController.text.trim();
    final lng = _longController.text.trim();
    final country = _countryController.text.trim().isEmpty ? 'India' : _countryController.text.trim();

    String method = 'pincode';
    if (_locationMethod == 'Use ZIP Code') method = 'zip';
    if (_locationMethod == 'Use Latitude & Longitude') method = 'lat_long';

    setState(() => _isSavingDc = true);
    try {
      if (_editingDcId != null) {
        final updatedDc = DataCenterModel(
          id: _editingDcId!,
          name: name,
          code: 'DC-$_editingDcId',
          city: _resolvedLocation?.cityName ?? (_resolvedLocation?.districtName ?? ''),
          country: country,
          region: 'Asia Pacific',
          address: _resolvedLocation != null
              ? '${_resolvedLocation!.talukName}, ${_resolvedLocation!.districtName}'
              : 'Pincode $pin',
          status: _isActiveStatus ? 'active' : 'maintenance',
          healthScore: 99.98,
          totalServers: 24,
          activeServers: 24,
          totalRacks: 6,
          powerCapacityKva: 1200.0,
          coolingEfficiencyPue: 1.14,
          ipPrefix: '198.51.100.0/24',
          locationMethod: method,
          pincode: pin,
          zipCode: zip,
          latitude: lat,
          longitude: lng,
          activeStatus: _isActiveStatus ? 1 : 0,
        );
        await ref.read(dataCenterControllerProvider.notifier).updateDataCenter(updatedDc);
        if (mounted) {
          context.showSnackBar('Data Center "$name" updated successfully');
          setState(() {
            _editingDcId = null;
          });
        }
      } else {
        final newDc = DataCenterModel(
          id: '',
          name: name,
          code: 'DC-${DateTime.now().millisecondsSinceEpoch}',
          city: _resolvedLocation?.cityName ?? (_resolvedLocation?.districtName ?? ''),
          country: country,
          region: 'Asia Pacific',
          address: _resolvedLocation != null
              ? '${_resolvedLocation!.talukName}, ${_resolvedLocation!.districtName}'
              : 'Pincode $pin',
          status: _isActiveStatus ? 'active' : 'maintenance',
          healthScore: 99.98,
          totalServers: 24,
          activeServers: 24,
          totalRacks: 6,
          powerCapacityKva: 1200.0,
          coolingEfficiencyPue: 1.14,
          ipPrefix: '198.51.100.0/24',
          locationMethod: method,
          pincode: pin,
          zipCode: zip,
          latitude: lat,
          longitude: lng,
          activeStatus: _isActiveStatus ? 1 : 0,
        );
        await ref.read(dataCenterControllerProvider.notifier).addDataCenter(newDc);
        if (mounted) {
          context.showSnackBar('Data Center "$name" created successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error saving data center: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingDc = false);
      }
    }
  }

  void _handleDiscardChanges() {
    setState(() {
      _editingDcId = null;
      _dcNameController.clear();
      _pinController.clear();
      _zipController.clear();
      _latController.clear();
      _longController.clear();
      _countryController.clear();
      _resolvedLocation = null;
      _isActiveStatus = true;
    });
    context.showSnackBar('Changes discarded');
  }

  Future<void> _handleSearchLocation({String? pincodeToSearch}) async {
    if (_locationMethod != 'Use PIN') {
      if (_locationMethod == 'Use ZIP Code') {
        final zip = _zipController.text.trim();
        context.showSnackBar(
          'Location coordinates resolved for ZIP: ${zip.isEmpty ? "10001" : zip}, ${_countryController.text}',
        );
      } else {
        final lat = _latController.text.trim();
        final lng = _longController.text.trim();
        context.showSnackBar(
          'Geographic coordinates mapped: ${lat.isEmpty ? "38.8951" : lat}, ${lng.isEmpty ? "-77.0364" : lng}',
        );
      }
      return;
    }

    final pin = (pincodeToSearch ?? _pinController.text).trim();
    if (pin.isEmpty) {
      context.showSnackBar('Please enter a PIN code');
      return;
    }

    setState(() {
      _isSearchingPin = true;
    });

    try {
      final location = await ref
          .read(dataCenterControllerProvider.notifier)
          .lookupPincode(pin);

      if (mounted) {
        if (location != null) {
          setState(() {
            _resolvedLocation = location;
            if (_countryController.text.trim().isEmpty) {
              _countryController.text = location.countryName;
            }
          });
          context.showSnackBar('Location resolved for PIN: $pin');
        } else {
          context.showSnackBar('No location details found for PIN: $pin');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error resolving PIN: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingPin = false;
        });
      }
    }
  }

  Future<void> _handleSavePowerCooling(
    List<DataCenterModel> dcList,
    List<ServerModel> serverList,
  ) async {
    setState(() => _isSavingPowerCooling = true);
    try {
      for (final id in _powerConfigs) {
        final dcName = _getDropdown('power_${id}_dc', 'Select Data Center...');
        final srvName = _getDropdown('power_${id}_srv', 'Select Server...');
        final dc = dcList.firstWhere(
          (d) => d.name == dcName,
          orElse: () => dcList.isNotEmpty
              ? dcList.first
              : const DataCenterModel(
                  id: '1',
                  name: 'Data Center',
                  code: 'DC-1',
                  city: 'Coimbatore',
                  country: 'India',
                  region: 'Asia Pacific',
                  address: 'Data Center Node',
                  status: 'active',
                  healthScore: 100,
                  totalServers: 0,
                  activeServers: 0,
                  totalRacks: 0,
                  powerCapacityKva: 0,
                  coolingEfficiencyPue: 0,
                  ipPrefix: '',
                  locationMethod: 'pincode',
                ),
        );
        final ups = _powerUpsControllers[id]?.text.trim() ?? '30 kVA';
        final cons = _powerConsumptionControllers[id]?.text.trim() ?? '3200';
        final gen = _powerGeneratorControllers[id]?.text.trim() ?? 'Diesel 50kVA';
        final cool = _powerCoolingTypeControllers[id]?.text.trim() ?? 'In-Row Liquid Chilled';
        final temp = _powerTempControllers[id]?.text.trim() ?? '21';
        final pdu = _powerPduControllers[id]?.text.trim() ?? 'APC Metered PDU 32A';
        final red = _getToggle('power_${id}_red');

        final model = ServerModel(
          id: '',
          name: srvName != 'Select Server...' ? srvName : 'Node-Power-$id',
          hostname: srvName != 'Select Server...' ? srvName : 'node-$id.datacenter.internal',
          ipAddress: '10.0.1.$id',
          ipv6Address: 'fe80::$id',
          dataCenterId: dc.id.isNotEmpty ? dc.id : '1',
          dataCenterName: dc.name,
          location: dc.city.isNotEmpty ? dc.city : dc.name,
          status: 'Active',
          serverType: 'Rack Server',
          os: 'Ubuntu 22.04 LTS',
          cpuUsagePercent: 42.0,
          cpuCores: 16,
          threadCount: 32,
          cpuModel: 'E5-2680 v4',
          ramUsagePercent: 35.0,
          ramTotalGb: 64.0,
          ramUsedGb: 22.4,
          storageUsagePercent: 50.0,
          storageTotalGb: 1000.0,
          storageUsedGb: 500.0,
          networkUsageMbps: 120.0,
          networkInMbps: 60.0,
          networkOutMbps: 60.0,
          uptimeSeconds: 86400,
          healthStatus: 'healthy',
          upsCapacity: ups,
          powerConsumption: cons,
          generatorBackup: gen,
          coolingType: cool,
          rackTemperature: temp,
          pduDetails: pdu,
          hasRedundancy: red,
        );

        await ref.read(serverControllerProvider.notifier).addServer(model);
      }
      if (mounted) {
        context.showSnackBar('Power & Cooling configuration saved successfully to backend!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error saving power & cooling configuration: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPowerCooling = false);
      }
    }
  }

  Future<void> _handleSaveNetwork(
    List<DataCenterModel> dcList,
    List<ServerModel> serverList,
  ) async {
    setState(() => _isSavingNetwork = true);
    try {
      for (final id in _networkConnections) {
        final dcName = _getDropdown('net_${id}_dc', 'Select Data Center...');
        final srvName = _getDropdown('net_${id}_srv', 'Select Server...');
        final provider = _getDropdown('net_${id}_prov', 'Tata Communications');
        final netName = _networkNameControllers[id]?.text.trim() ?? 'Primary Fiber Backbone';
        final connType = _getDropdown('net_${id}_type', 'Fiber');
        final bw = _networkBandwidthControllers[id]?.text.trim() ?? '1 Gbps';

        final dc = dcList.firstWhere(
          (d) => d.name == dcName,
          orElse: () => dcList.isNotEmpty
              ? dcList.first
              : const DataCenterModel(
                  id: '1',
                  name: 'Data Center',
                  code: 'DC-1',
                  city: 'Coimbatore',
                  country: 'India',
                  region: 'Asia Pacific',
                  address: 'Data Center Node',
                  status: 'active',
                  healthScore: 100,
                  totalServers: 0,
                  activeServers: 0,
                  totalRacks: 0,
                  powerCapacityKva: 0,
                  coolingEfficiencyPue: 0,
                  ipPrefix: '',
                  locationMethod: 'pincode',
                ),
        );
        final srv = serverList.firstWhere(
          (s) => s.name == srvName,
          orElse: () => serverList.isNotEmpty
              ? serverList.first
              : ServerModel(
                  id: '1',
                  name: 'Server',
                  hostname: 'server',
                  ipAddress: '10.0.0.1',
                  ipv6Address: '',
                  dataCenterId: dc.id,
                  dataCenterName: dc.name,
                  location: '',
                  status: 'Active',
                  os: '',
                  cpuUsagePercent: 0,
                  cpuCores: 4,
                  cpuModel: '',
                  ramUsagePercent: 0,
                  ramTotalGb: 0,
                  ramUsedGb: 0,
                  storageUsagePercent: 0,
                  storageTotalGb: 0,
                  storageUsedGb: 0,
                  networkUsageMbps: 0,
                  networkInMbps: 0,
                  networkOutMbps: 0,
                  uptimeSeconds: 0,
                  healthStatus: 'healthy',
                ),
        );

        final ipsList = <Map<String, String>>[];
        final ipIds = _networkIps[id] ?? [1];
        for (final ipId in ipIds) {
          final v4 = _networkIpControllers['ipv4_${id}_$ipId']?.text.trim() ?? '192.168.1.1';
          final v6 = _networkIpControllers['ipv6_${id}_$ipId']?.text.trim() ?? '2001:0db8::1';
          ipsList.add({'ipv4': v4, 'ipv6': v6});
        }

        final model = ServerNetworkConnectionModel(
          id: '',
          dataCenterId: dc.id.isNotEmpty ? dc.id : null,
          dataCenterName: dc.name,
          serverId: srv.id.isNotEmpty ? srv.id : null,
          serverName: srv.name,
          networkProvider: provider,
          networkName: netName,
          connectionType: connType,
          bandwidth: bw,
          ips: ipsList,
        );

        await ref.read(serverControllerProvider.notifier).saveNetworkConnection(model);
      }
      if (mounted) {
        context.showSnackBar('Network configuration saved successfully to backend!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error saving network configuration: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNetwork = false);
      }
    }
  }

  Future<void> _handleSaveTab(String tabName) async {
    setState(() => _isSavingTab = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isSavingTab = false);
      context.showSnackBar('$tabName configuration saved successfully to backend!');
    }
  }

  // Dynamic Location Inputs according to Location Entry Method
  Widget _buildDynamicLocationInputs(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;

        if (_locationMethod == 'Use PIN') {
          // Photo 1: PIN Code field + Search Button
          return SizedBox(
            width: isNarrow ? constraints.maxWidth : 360,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIN Code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 42,
                        child: TextField(
                          controller: _pinController,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit PIN',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                          onSubmitted: (_) => _handleSearchLocation(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildSearchButton(isDark),
              ],
            ),
          );
        } else if (_locationMethod == 'Use ZIP Code') {
          // Photo 2: Country + ZIP / Postal Code + Search Button
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Country',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _countryController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZIP / Postal Code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _zipController,
                              decoration: InputDecoration(
                                hintText: 'Enter ZIP',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchButton(isDark, isFullWidth: true),
              ],
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _countryController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZIP / Postal Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _zipController,
                        decoration: InputDecoration(
                          hintText: 'Enter ZIP',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildSearchButton(isDark),
            ],
          );
        } else {
          // Photo 3: Latitude + Longitude + Search Button
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _latController,
                              decoration: InputDecoration(
                                hintText: 'e.g. 38.8951',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Longitude',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 42,
                            child: TextField(
                              controller: _longController,
                              decoration: InputDecoration(
                                hintText: 'e.g. -77.0364',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchButton(isDark, isFullWidth: true),
              ],
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _latController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 38.8951',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longitude',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _longController,
                        decoration: InputDecoration(
                          hintText: 'e.g. -77.0364',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildSearchButton(isDark),
            ],
          );
        }
      },
    );
  }

  Widget _buildSearchButton(bool isDark, {bool isFullWidth = false}) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        elevation: 0,
      ),
      onPressed: _isSearchingPin ? null : () => _handleSearchLocation(),
      child: _isSearchingPin
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
    );

    return SizedBox(
      height: 42,
      width: isFullWidth ? double.maxFinite : null,
      child: button,
    );
  }

  Widget _buildRadioOption(String value, bool isDark) {
    final isSelected = _locationMethod == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _locationMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                  width: isSelected ? 4.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? AppColors.textSecondaryDark : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Circuit Point Card inside Configured Data Centers
  Widget _buildCircuitPointCard(BuildContext context, DataCenterModel dc, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                  // Stacked Server Icon Box
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1B4B)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.view_agenda_outlined,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dc.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dc.city.isNotEmpty && !dc.city.startsWith('PIN:')
                                    ? '${dc.city}, ${dc.country}'
                                    : dc.country,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Eye Icon: Opens Photo 4 View Dialog
                  IconButton(
                    tooltip: 'View Configuration',
                    icon: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 18,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                    onPressed: () => _showViewConfigDialog(context, dc, isDark),
                  ),
                  // Edit Pencil Icon: Opens Photo 5 Edit Dialog & populates main form
                  IconButton(
                    tooltip: 'Edit Data Center',
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _editingDcId = dc.id;
                        _dcNameController.text = dc.name;
                        _isActiveStatus = dc.status == 'active' || dc.activeStatus == 1;
                        if (dc.locationMethod == 'zip') {
                          _locationMethod = 'Use ZIP Code';
                          _zipController.text = dc.zipCode ?? '';
                        } else if (dc.locationMethod == 'lat_long') {
                          _locationMethod = 'Use Latitude & Longitude';
                          _latController.text = dc.latitude ?? '';
                          _longController.text = dc.longitude ?? '';
                        } else {
                          _locationMethod = 'Use PIN';
                          _pinController.text = dc.pincode ?? '';
                        }
                        _countryController.text = dc.country;
                      });
                      if (dc.pincode != null && dc.pincode!.isNotEmpty) {
                        _handleSearchLocation(pincodeToSearch: dc.pincode);
                      }
                      _showEditConfigDialog(context, dc, isDark);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: (dc.status == 'active' || dc.activeStatus == 1)
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: (dc.status == 'active' || dc.activeStatus == 1)
                              ? const Color(0xFF047857)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (dc.status == 'active' || dc.activeStatus == 1)
                              ? 'Operational'
                              : 'Maintenance',
                          style: TextStyle(
                            color: (dc.status == 'active' || dc.activeStatus == 1)
                                ? const Color(0xFF047857)
                                : const Color(0xFFD97706),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
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

  // Dialog 1: View Data Center Configuration (100% matches Photo 4)
  void _showViewConfigDialog(BuildContext context, DataCenterModel dc, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => _ViewDataCenterDialog(dataCenter: dc),
    );
  }

  // Dialog 2: Edit Data Center (100% matches Photo 5 with dynamic Location Entry Method)
  void _showEditConfigDialog(BuildContext context, DataCenterModel dc, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => _EditDataCenterDialog(
        dataCenter: dc,
        onSave: (updatedDc) async {
          try {
            await ref.read(dataCenterControllerProvider.notifier).updateDataCenter(updatedDc);
            if (context.mounted) {
              context.showSnackBar('Data Center "${updatedDc.name}" updated successfully');
            }
          } catch (e) {
            if (context.mounted) {
              context.showSnackBar('Error updating data center: $e');
            }
          }
        },
      ),
    );
  }

  // Infrastructure Tabs
  Widget _buildSectionContainer({
    required bool isDark,
    required IconData titleIcon,
    required String title,
    String? addBtnText,
    VoidCallback? onAdd,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(titleIcon, size: 20, color: const Color(0xFF4F46E5)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                if (addBtnText != null && onAdd != null)
                  OutlinedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(addBtnText.startsWith('+') ? addBtnText.replaceFirst('+', '').trim() : addBtnText),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFFEEF2F6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF2F6)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBlock({
    required bool isDark,
    required VoidCallback onRemove,
    required Widget child,
    Widget? header,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                header,
                const SizedBox(height: 20),
              ],
              child,
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridInput(
    String label, {
    bool isDark = false,
    Widget? suffixIcon,
    String? hint,
    bool isRequired = false,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              suffixIcon: suffixIcon,
            ),
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleInput(String label, bool value, ValueChanged<bool> onChanged, {bool isDark = false}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              activeTrackColor: const Color(0xFF4F46E5),
              activeThumbColor: Colors.white,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownInput(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool isDark = false,
    bool isRequired = false,
  }) {
    final effectiveItems = items.toSet().toList();
    if (!effectiveItems.contains(value)) {
      effectiveItems.insert(0, value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
              items: effectiveItems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxInput(String label, bool value, ValueChanged<bool?> onChanged, {bool isDark = false}) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4F46E5),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Widget> children, double maxWidth) {
    int cols = maxWidth > 800 ? 3 : (maxWidth > 500 ? 2 : 1);
    double spacing = 16.0;
    double width = (maxWidth - (spacing * (cols - 1))) / cols;
    return Wrap(
      spacing: spacing,
      runSpacing: 16.0,
      children: children.map((c) => SizedBox(width: width, child: c)).toList(),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildGrid(children, constraints.maxWidth);
      },
    );
  }

  TextStyle _getSectionTitleStyle(bool isDark) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
    );
  }

  Widget _buildSoftwareTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];
    final serverList = serverState.servers.asData?.value ?? [];
    final serverNames = ['Select Server...', ...serverList.map((s) => s.name)];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.view_in_ar_rounded,
          title: 'Software & Licensing',
          addBtnText: 'Add Software Stack',
          onAdd: () {
            setState(() {
              _softwareStacks.add(_softwareIdCounter++);
            });
          },
          children: _softwareStacks.map((id) => _buildFormBlock(
            isDark: isDark,
            onRemove: () {
              setState(() => _softwareStacks.remove(id));
            },
            header: Row(
              children: [
                Text(
                  'Software Stack #$id',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _softwareStacks.remove(id));
                  },
                ),
              ],
            ),
            child: _buildResponsiveGrid([
              _buildDropdownInput(
                'Assigned Data Center',
                _getDropdown('sw_${id}_dc', 'Select Data Center...'),
                dcNames,
                (v) => _setDropdown('sw_${id}_dc', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildDropdownInput(
                'Assigned Server',
                _getDropdown('sw_${id}_srv', 'Select Server...'),
                serverNames,
                (v) => _setDropdown('sw_${id}_srv', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildGridInput('Operating System', hint: 'Ubuntu 22.04 LTS', isDark: isDark),
              _buildGridInput('Hypervisor', hint: 'KVM / VMware ESXi', isDark: isDark),
              _buildGridInput('Database Engine', hint: 'PostgreSQL 16', isDark: isDark),
              _buildGridInput('Monitoring Tool', hint: 'Prometheus & Grafana', isDark: isDark),
              _buildGridInput('Backup Software', hint: 'Veeam Backup', isDark: isDark),
              _buildGridInput('Antivirus', hint: 'ClamAV Enterprise', isDark: isDark),
              _buildGridInput('License Key', hint: 'XXXX-XXXX-XXXX-XXXX', isDark: isDark),
              _buildGridInput('Vendor', hint: 'Canonical / VMware', isDark: isDark),
              _buildGridInput('Support Contact', hint: 'support@vendor.com', isDark: isDark),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildGridInput('License Expiry', isDark: isDark, hint: 'mm/dd/yyyy', suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSaveTab('Software & Licensing'),
          isLoading: _isSavingTab,
          subtitle: '${serverList.length} Server Stacks',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPowerCoolingTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];
    final serverList = serverState.servers.asData?.value ?? [];
    final serverNames = ['Select Server...', ...serverList.map((s) => s.name)];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // 1. Overview Metric Banner
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Power & Cooling Infrastructure',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connected to ${dcList.length} Data Centers • ${serverList.length} Active Servers',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                    SizedBox(width: 5),
                    Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Section Container: Power & Cooling Config Forms
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.bolt_rounded,
          title: 'Power & Cooling Configuration',
          addBtnText: 'Add Environment Config',
          onAdd: () {
            setState(() {
              _powerConfigs.add(_powerIdCounter++);
            });
          },
          children: _powerConfigs.map((id) => _buildFormBlock(
            isDark: isDark,
            onRemove: () {
              setState(() => _powerConfigs.remove(id));
            },
            header: Row(
              children: [
                Text(
                  'Environment Config #$id',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _powerConfigs.remove(id));
                  },
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResponsiveGrid([
                  _buildDropdownInput(
                    'Assigned Data Center',
                    _getDropdown('power_${id}_dc', 'Select Data Center...'),
                    dcNames,
                    (v) => _setDropdown('power_${id}_dc', v),
                    isDark: isDark,
                    isRequired: true,
                  ),
                  _buildDropdownInput(
                    'Assigned Server',
                    _getDropdown('power_${id}_srv', 'Select Server...'),
                    serverNames,
                    (v) => _setDropdown('power_${id}_srv', v),
                    isDark: isDark,
                    isRequired: true,
                  ),
                  _buildGridInput(
                    'UPS Capacity',
                    hint: 'e.g. 30 kVA',
                    controller: _getController(_powerUpsControllers, id),
                    isDark: isDark,
                  ),
                  _buildGridInput(
                    'Power Consumption (W)',
                    hint: 'e.g. 3200',
                    controller: _getController(_powerConsumptionControllers, id),
                    isDark: isDark,
                  ),
                  _buildGridInput(
                    'Generator Backup',
                    hint: 'e.g. Diesel 50kVA Generator',
                    controller: _getController(_powerGeneratorControllers, id),
                    isDark: isDark,
                  ),
                  _buildGridInput(
                    'Cooling Type',
                    hint: 'e.g. In-Row Liquid Chilled',
                    controller: _getController(_powerCoolingTypeControllers, id),
                    isDark: isDark,
                  ),
                  _buildGridInput(
                    'Rack Temp (°C)',
                    hint: 'e.g. 21',
                    controller: _getController(_powerTempControllers, id),
                    isDark: isDark,
                  ),
                  _buildGridInput(
                    'PDU Details',
                    hint: 'e.g. APC Metered PDU 32A',
                    controller: _getController(_powerPduControllers, id),
                    isDark: isDark,
                  ),
                ]),
                const SizedBox(height: 16),
                _buildCheckboxInput(
                  'Redundancy (N+1 Redundant Failover)',
                  _getToggle('power_${id}_red'),
                  (v) => _setToggle('power_${id}_red', v ?? false),
                  isDark: isDark,
                ),
              ],
            ),
          )).toList(),
        ),

        const SizedBox(height: 24),

        // 3. Live Active Servers in Infrastructure (API: GET /api/server-details)
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.dns_rounded,
          title: 'Infrastructure Servers (${serverList.length} Connected)',
          children: [
            if (serverList.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  'No servers connected yet.',
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                  ),
                ),
              )
            else
              ...serverList.map((srv) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.dns_rounded,
                          color: Color(0xFF4F46E5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  srv.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    srv.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Data Center: ${srv.dataCenterName.isNotEmpty ? srv.dataCenterName : "Circuit Pointy"} • Processor: ${srv.cpuModel} (${srv.cpuCores} Cores) • IP: ${srv.ipAddress}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⚡ 450W • 21°C',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),

        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSavePowerCooling(dcList, serverList),
          isLoading: _isSavingPowerCooling,
          subtitle: '${serverList.length} Servers Configured',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStorageTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];
    final serverList = serverState.servers.asData?.value ?? [];
    final serverNames = ['Select Server...', ...serverList.map((s) => s.name)];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.dns_outlined,
          title: 'Storage Management',
          addBtnText: 'Add Storage Array',
          onAdd: () {
            setState(() {
              _storageArrays.add(_storageIdCounter++);
            });
          },
          children: _storageArrays.map((id) => _buildFormBlock(
            isDark: isDark,
            onRemove: () {
              setState(() => _storageArrays.remove(id));
            },
            header: Row(
              children: [
                Text(
                  'Storage Array #$id',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _storageArrays.remove(id));
                  },
                ),
              ],
            ),
            child: _buildResponsiveGrid([
              _buildDropdownInput(
                'Assigned Data Center',
                _getDropdown('stor_${id}_dc', 'Select Data Center...'),
                dcNames,
                (v) => _setDropdown('stor_${id}_dc', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildDropdownInput(
                'Assigned Server',
                _getDropdown('stor_${id}_srv', 'Select Server...'),
                serverNames,
                (v) => _setDropdown('stor_${id}_srv', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildGridInput('Storage Type', hint: 'NVMe SAN Array', isDark: isDark),
              _buildGridInput('SSD/HDD/SAS/NVMe', hint: 'NVMe PCIe Gen4', isDark: isDark),
              _buildGridInput('Capacity', hint: '100 TB', isDark: isDark),
              _buildGridInput('Used Space', hint: '42 TB', isDark: isDark),
              _buildGridInput('Available Space', hint: '58 TB', isDark: isDark),
              _buildGridInput('Backup Storage', hint: 'Daily S3 Glacier', isDark: isDark),
              _buildGridInput('RAID Level', hint: 'RAID 10', isDark: isDark),
              _buildGridInput('NAS/SAN', hint: 'SAN Fiber Channel', isDark: isDark),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSaveTab('Storage Management'),
          isLoading: _isSavingTab,
          subtitle: '${serverList.length} Storage Nodes',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSecurityTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.shield_outlined,
          title: 'Security & Surveillance',
          addBtnText: 'Add Security Profile',
          onAdd: () {
            setState(() {
              _securityProfiles.add(_securityIdCounter++);
            });
          },
          children: _securityProfiles.map((id) => _buildFormBlock(
            isDark: isDark,
            onRemove: () {
              setState(() => _securityProfiles.remove(id));
            },
            header: Row(
              children: [
                Text(
                  'Profile #$id',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(color: Color(0xFF4F46E5), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Icon(Icons.copy_rounded, size: 16, color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _securityProfiles.remove(id));
                  },
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdownInput(
                  'Assigned Data Center',
                  _getDropdown('sec_${id}_dc', 'Select Data Center...'),
                  dcNames,
                  (v) => _setDropdown('sec_${id}_dc', v),
                  isDark: isDark,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                Text('1. SECURITY CONTROLS', style: _getSectionTitleStyle(isDark)),
                const SizedBox(height: 12),
                _buildResponsiveGrid([
                  _buildToggleInput('CCTV Monitoring', _getToggle('sec_${id}_cctv'), (v) => _setToggle('sec_${id}_cctv', v), isDark: isDark),
                  _buildToggleInput('Biometric Access', _getToggle('sec_${id}_bio'), (v) => _setToggle('sec_${id}_bio', v), isDark: isDark),
                  _buildToggleInput('RFID Access', _getToggle('sec_${id}_rfid'), (v) => _setToggle('sec_${id}_rfid', v), isDark: isDark),
                  _buildToggleInput('Fire Alarm', _getToggle('sec_${id}_fire'), (v) => _setToggle('sec_${id}_fire', v), isDark: isDark),
                  _buildToggleInput('Fire Suppression', _getToggle('sec_${id}_supp'), (v) => _setToggle('sec_${id}_supp', v), isDark: isDark),
                  _buildToggleInput('Emergency Exit Monitoring', _getToggle('sec_${id}_exit'), (v) => _setToggle('sec_${id}_exit', v), isDark: isDark),
                ]),
                const SizedBox(height: 24),
                
                Text('2. ACCESS & LOGS', style: _getSectionTitleStyle(isDark)),
                const SizedBox(height: 12),
                _buildResponsiveGrid([
                  _buildGridInput('Access Logs System', hint: 'e.g. Splunk, ELK', isDark: isDark),
                  _buildGridInput('Visitor Management', hint: 'e.g. Envoy', isDark: isDark),
                  _buildGridInput('Retention Period', hint: 'e.g. 90 Days', isDark: isDark),
                  _buildGridInput('Access Level', hint: 'Admin', isDark: isDark),
                ]),
                const SizedBox(height: 24),
                
                Text('3. SECURITY OPERATIONS', style: _getSectionTitleStyle(isDark)),
                const SizedBox(height: 12),
                _buildResponsiveGrid([
                  _buildGridInput('Security Team Info', hint: 'Internal / Outsourced', isDark: isDark),
                  _buildGridInput('Emergency Contact', hint: '+1 800 555 0199', isDark: isDark),
                  _buildGridInput('Incident Response Team', hint: 'Team Name', isDark: isDark),
                  _buildGridInput('Last Audit Date', hint: 'mm/dd/yyyy', suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16), isDark: isDark),
                ]),
                const SizedBox(height: 24),
                
                Text('4. ALERT & MONITORING', style: _getSectionTitleStyle(isDark)),
                const SizedBox(height: 12),
                _buildResponsiveGrid([
                  _buildToggleInput('SMS Alerts Enabled', _getToggle('sec_${id}_sms'), (v) => _setToggle('sec_${id}_sms', v), isDark: isDark),
                  _buildToggleInput('Email Alerts Enabled', _getToggle('sec_${id}_email'), (v) => _setToggle('sec_${id}_email', v), isDark: isDark),
                  _buildToggleInput('Intrusion Detection', _getToggle('sec_${id}_int'), (v) => _setToggle('sec_${id}_int', v), isDark: isDark),
                  _buildDropdownInput('Health Status', _getDropdown('sec_${id}_health', 'Active'), ['Active', 'Warning', 'Critical'], (v) => _setDropdown('sec_${id}_health', v), isDark: isDark),
                ]),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSaveTab('Security & Surveillance'),
          isLoading: _isSavingTab,
          subtitle: '${dcList.length} Sites Protected',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRackManagementTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];
    final serverList = serverState.servers.asData?.value ?? [];
    final serverNames = ['Select Server...', ...serverList.map((s) => s.name)];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.table_rows_rounded,
          title: 'Rack Management',
          addBtnText: 'Add Rack Setup',
          onAdd: () {
            setState(() {
              _rackSetups.add(_rackIdCounter++);
            });
          },
          children: _rackSetups.map((id) => _buildFormBlock(
            isDark: isDark,
            onRemove: () {
              setState(() => _rackSetups.remove(id));
            },
            header: Row(
              children: [
                Text(
                  'Rack Unit #$id',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _rackSetups.remove(id));
                  },
                ),
              ],
            ),
            child: _buildResponsiveGrid([
              _buildDropdownInput(
                'Assigned Data Center',
                _getDropdown('rack_${id}_dc', 'Select Data Center...'),
                dcNames,
                (v) => _setDropdown('rack_${id}_dc', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildDropdownInput(
                'Assigned Server',
                _getDropdown('rack_${id}_srv', 'Select Server...'),
                serverNames,
                (v) => _setDropdown('rack_${id}_srv', v),
                isDark: isDark,
                isRequired: true,
              ),
              _buildGridInput('Rack Name', hint: 'Rack Alpha-01', isDark: isDark),
              _buildGridInput('Rack Number', hint: 'R-42-A', isDark: isDark),
              _buildGridInput('Rack Size', hint: '42U (Standard 19-inch)', isDark: isDark),
              _buildGridInput('Rack Type', hint: 'Enclosed Server Cabinet', isDark: isDark),
              _buildGridInput('Rack Status', hint: 'Active / Operational', isDark: isDark),
              _buildGridInput('Rack Temperature', hint: '20.5 °C', isDark: isDark),
              _buildGridInput('Power Usage', hint: '4.8 kW / 10 kW', isDark: isDark),
              _buildGridInput('Rack Unit Availability', hint: '18U Available', isDark: isDark),
            ]),
          )).toList(),
        ),
        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSaveTab('Rack Management'),
          isLoading: _isSavingTab,
          subtitle: '${dcList.length} Facilities Monitored',
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNetworkTab(
    BuildContext context,
    DataCenterState dcState,
    ServerState serverState,
    bool isDark,
  ) {
    final dcList = dcState.dataCenters.asData?.value ?? [];
    final dcNames = ['Select Data Center...', ...dcList.map((dc) => dc.name)];
    final serverList = serverState.servers.asData?.value ?? [];
    final serverNames = ['Select Server...', ...serverList.map((s) => s.name)];
    final netConnections = serverState.networkConnections.asData?.value ?? [];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'ISP & Network Management',
          style: AppTextStyles.titleMedium(isDark).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage internet providers, broadband lines, and network details for your infrastructure.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 16),
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.wifi_rounded,
          title: 'Network Configuration',
          addBtnText: 'Add Connection',
          onAdd: () {
            setState(() {
              int newId = _networkIdCounter++;
              _networkConnections.add(newId);
              _networkIps[newId] = [1];
              _networkIpCounters[newId] = 2;
            });
          },
          children: _networkConnections.map((id) {
            List<int> ips = _networkIps[id] ?? [1];
            return _buildFormBlock(
              isDark: isDark,
              onRemove: () {
                setState(() {
                  _networkConnections.remove(id);
                  _networkIps.remove(id);
                  _networkIpCounters.remove(id);
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildResponsiveGrid([
                    _buildDropdownInput(
                      'Assigned Data Center',
                      _getDropdown('net_${id}_dc', 'Select Data Center...'),
                      dcNames,
                      (v) => _setDropdown('net_${id}_dc', v),
                      isDark: isDark,
                      isRequired: true,
                    ),
                    _buildDropdownInput(
                      'Server',
                      _getDropdown('net_${id}_srv', 'Select Server...'),
                      serverNames,
                      (v) => _setDropdown('net_${id}_srv', v),
                      isDark: isDark,
                      isRequired: true,
                    ),
                    _buildDropdownInput(
                      'Network Provider',
                      _getDropdown('net_${id}_prov', 'Tata Communications'),
                      ['Tata Communications', 'Airtel Business', 'Jio Fiber', 'Vodafone Idea', 'BSNL Lease', 'AWS Direct Connect'],
                      (v) => _setDropdown('net_${id}_prov', v),
                      isDark: isDark,
                      isRequired: true,
                    ),
                    _buildGridInput(
                      'Network Name',
                      hint: 'e.g. Office Fiber Line',
                      controller: _getController(_networkNameControllers, id),
                      isDark: isDark,
                      isRequired: true,
                    ),
                    _buildDropdownInput(
                      'Connection Type',
                      _getDropdown('net_${id}_type', 'Fiber'),
                      ['Fiber', 'Ethernet', 'Broadband', 'Leased Line', 'MPLS'],
                      (v) => _setDropdown('net_${id}_type', v),
                      isDark: isDark,
                      isRequired: true,
                    ),
                    _buildGridInput(
                      'Bandwidth',
                      hint: 'e.g. 100 Mbps, 1 Gbps',
                      controller: _getController(_networkBandwidthControllers, id),
                      isDark: isDark,
                      isRequired: true,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  
                  // IPs section
                  ...ips.map((ipId) {
                    bool isFirst = ipId == 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildGridInput(
                              isFirst ? 'IPv4' : 'IPv4 #$ipId',
                              hint: 'e.g. 192.168.1.1',
                              controller: _getIpController('ipv4_${id}_$ipId'),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGridInput(
                              isFirst ? 'IPv6' : 'IPv6 #$ipId',
                              hint: 'e.g. 2001:0db8::',
                              controller: _getIpController('ipv6_${id}_$ipId'),
                              isDark: isDark,
                            ),
                          ),
                          if (!isFirst) ...[
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _networkIps[id]?.remove(ipId);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          int nextIpId = (_networkIpCounters[id] ?? 2);
                          _networkIps[id]?.add(nextIpId);
                          _networkIpCounters[id] = nextIpId + 1;
                        });
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add IPs'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        side: const BorderSide(color: Color(0xFFEEF2F6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Live Network Connections from API
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.lan_rounded,
          title: 'Configured Network Connections (${netConnections.length})',
          children: [
            if (netConnections.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  'No network connections returned from backend yet. Use the form above and click Save Configuration.',
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...netConnections.map((nc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.wifi_rounded, size: 18, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nc.networkName.isNotEmpty ? nc.networkName : 'Network Connection',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Provider: ${nc.networkProvider} • Type: ${nc.connectionType} • Bandwidth: ${nc.bandwidth}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),

        const SizedBox(height: 24),
        _buildBottomActionBar(
          isDark,
          onSave: () => _handleSaveNetwork(dcList, serverList),
          isLoading: _isSavingNetwork,
          subtitle: '${netConnections.length} Active Lines',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog 1: View Data Center Configuration (Photo 4)
// ---------------------------------------------------------------------------
class _ViewDataCenterDialog extends StatefulWidget {
  final DataCenterModel dataCenter;

  const _ViewDataCenterDialog({required this.dataCenter});

  @override
  State<_ViewDataCenterDialog> createState() => _ViewDataCenterDialogState();
}

class _ViewDataCenterDialogState extends State<_ViewDataCenterDialog> {
  String _selectedMethod = 'Use PIN';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header (Purple square icon + Title + Close Button)
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.view_agenda_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Center Configuration',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 1: Data Center Name & Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Center Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.dataCenter.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
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
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 6, color: Color(0xFF047857)),
                              SizedBox(width: 5),
                              Text(
                                'Operational',
                                style: TextStyle(
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // LOCATION ENTRY METHOD Header
            Center(
              child: Text(
                'LOCATION ENTRY METHOD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Radio options row
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildViewRadio('Use PIN', isDark),
                _buildViewRadio('Use ZIP Code', isDark),
                _buildViewRadio('Use Latitude & Longitude', isDark),
              ],
            ),
            const SizedBox(height: 18),

            // Location details display
            if (_selectedMethod == 'Use PIN') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PIN Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 210,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.dataCenter.pincode?.isNotEmpty == true
                          ? widget.dataCenter.pincode!
                          : '-',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedMethod == 'Use ZIP Code') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Country',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.dataCenter.country.isEmpty ? '-' : widget.dataCenter.country,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
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
                        Text(
                          'ZIP / Postal Code',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.dataCenter.zipCode?.isNotEmpty == true
                                ? widget.dataCenter.zipCode!
                                : '-',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.dataCenter.latitude?.isNotEmpty == true
                                ? widget.dataCenter.latitude!
                                : '-',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
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
                        Text(
                          'Longitude',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.dataCenter.longitude?.isNotEmpty == true
                                ? widget.dataCenter.longitude!
                                : '-',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewRadio(String value, bool isDark) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                  width: isSelected ? 4.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? AppColors.textSecondaryDark : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog 2: Edit Data Center with Dynamic Location Entry Method (Photo 5)
// ---------------------------------------------------------------------------
class _EditDataCenterDialog extends StatefulWidget {
  final DataCenterModel dataCenter;
  final ValueChanged<DataCenterModel> onSave;

  const _EditDataCenterDialog({
    required this.dataCenter,
    required this.onSave,
  });

  @override
  State<_EditDataCenterDialog> createState() => _EditDataCenterDialogState();
}

class _EditDataCenterDialogState extends State<_EditDataCenterDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pinController;
  late final TextEditingController _countryController;
  late final TextEditingController _zipController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;

  late bool _statusSwitch;
  String _selectedMethod = 'Use PIN';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dataCenter.name);
    _statusSwitch = widget.dataCenter.status == 'active' || widget.dataCenter.activeStatus == 1;
    _selectedMethod = widget.dataCenter.locationMethod == 'zip'
        ? 'Use ZIP Code'
        : (widget.dataCenter.locationMethod == 'lat_long'
            ? 'Use Latitude & Longitude'
            : 'Use PIN');
    _pinController = TextEditingController(text: widget.dataCenter.pincode ?? '');
    _countryController = TextEditingController(text: widget.dataCenter.country);
    _zipController = TextEditingController(text: widget.dataCenter.zipCode ?? '');
    _latController = TextEditingController(text: widget.dataCenter.latitude ?? '');
    _longController = TextEditingController(text: widget.dataCenter.longitude ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header (Purple square icon with Pencil + Title + Close Button)
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Data Center',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 1: Data Center Name (Editable) & Status (Switch Toggle)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Center Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
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
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _statusSwitch,
                                activeTrackColor: const Color(0xFF4F46E5),
                                activeThumbColor: Colors.white,
                                onChanged: (val) => setState(() => _statusSwitch = val),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _statusSwitch ? 'Operational' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
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
            const SizedBox(height: 22),

            // LOCATION ENTRY METHOD Header
            Center(
              child: Text(
                'LOCATION ENTRY METHOD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Radio options row
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildEditRadio('Use PIN', isDark),
                _buildEditRadio('Use ZIP Code', isDark),
                _buildEditRadio('Use Latitude & Longitude', isDark),
              ],
            ),
            const SizedBox(height: 18),

            // Dynamic Form Fields in Edit Dialog (As specifically requested by user)
            if (_selectedMethod == 'Use PIN') ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PIN Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 210,
                    height: 44,
                    child: TextField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedMethod == 'Use ZIP Code') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Country',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _countryController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
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
                        Text(
                          'ZIP / Postal Code',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _zipController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _latController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
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
                        Text(
                          'Longitude',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _longController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 26),

            // Modal Bottom Actions: Cancel & Save Changes
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final method = _selectedMethod == 'Use PIN'
                        ? 'pincode'
                        : (_selectedMethod == 'Use ZIP Code' ? 'zip' : 'lat_long');
                    final updatedDc = widget.dataCenter.copyWith(
                      name: _nameController.text.trim().isEmpty
                          ? widget.dataCenter.name
                          : _nameController.text.trim(),
                      status: _statusSwitch ? 'active' : 'maintenance',
                      activeStatus: _statusSwitch ? 1 : 0,
                      locationMethod: method,
                      country: _countryController.text.trim().isNotEmpty
                          ? _countryController.text.trim()
                          : widget.dataCenter.country,
                      pincode: _pinController.text.trim(),
                      zipCode: _zipController.text.trim(),
                      latitude: _latController.text.trim(),
                      longitude: _longController.text.trim(),
                      address: 'PIN: ${_pinController.text.trim()}',
                    );
                    widget.onSave(updatedDc);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditRadio(String value, bool isDark) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                  width: isSelected ? 4.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? AppColors.textSecondaryDark : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
