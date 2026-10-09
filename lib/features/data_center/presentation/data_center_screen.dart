import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/data_center_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
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
  final _countryController = TextEditingController(text: 'United States');
  final _zipController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  String _locationMethod = 'Use PIN';
  bool _isActiveStatus = true;

  // Dynamic form state for other tabs
  List<int> _softwareStacks = [1];
  int _softwareIdCounter = 2;

  List<int> _powerConfigs = [1];
  int _powerIdCounter = 2;

  List<int> _storageArrays = [1];
  int _storageIdCounter = 2;

  List<int> _securityProfiles = [1];
  int _securityIdCounter = 2;

  List<int> _rackSetups = [1];
  int _rackIdCounter = 2;

  List<int> _networkConnections = [1];
  int _networkIdCounter = 2;
  Map<int, List<int>> _networkIps = {1: [1]};
  Map<int, int> _networkIpCounters = {1: 2};

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(dataCenterControllerProvider);
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
                          child: _buildTabContent(context, state, isDark),
                        ),
                      ],
                    )
                  : _buildTabContent(context, state, isDark),
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
    bool isDark,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAddDataCenterTab(context, state, isDark);
      case 1:
        return _buildSoftwareTab(context, isDark);
      case 2:
        return _buildPowerCoolingTab(context, isDark);
      case 3:
        return _buildStorageTab(context, isDark);
      case 4:
        return _buildSecurityTab(context, isDark);
      case 5:
        return _buildRackManagementTab(context, isDark);
      case 6:
        return _buildNetworkTab(context, isDark);
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
              child: Text(
                '${state.dataCenters.value?.length ?? 1} Location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Configured Circuit Point Card
        state.dataCenters.maybeWhen(
          data: (list) {
            final dc = list.isNotEmpty
                ? list.first
                : const DataCenterModel(
                    id: 'dc-circuit-point',
                    name: 'Circuit Point',
                    code: 'IN-SOUTH-1',
                    city: 'Coimbatore',
                    country: 'India',
                    region: 'Asia Pacific',
                    address: 'Circuit Point Tech Park, PIN: 641062',
                    status: 'active',
                    healthScore: 99.98,
                    totalServers: 24,
                    activeServers: 24,
                    totalRacks: 6,
                    powerCapacityKva: 1200.0,
                    coolingEfficiencyPue: 1.14,
                    ipPrefix: '198.51.100.0/24',
                  );
            return _buildCircuitPointCard(context, dc, isDark);
          },
          orElse: () => _buildCircuitPointCard(
            context,
            const DataCenterModel(
              id: 'dc-circuit-point',
              name: 'Circuit Point',
              code: 'IN-SOUTH-1',
              city: 'Coimbatore',
              country: 'India',
              region: 'Asia Pacific',
              address: 'Circuit Point Tech Park, PIN: 641062',
              status: 'active',
              healthScore: 99.98,
              totalServers: 24,
              activeServers: 24,
              totalRacks: 6,
              powerCapacityKva: 1200.0,
              coolingEfficiencyPue: 1.14,
              ipPrefix: '198.51.100.0/24',
            ),
            isDark,
          ),
        ),

        const SizedBox(height: 24),

        // Bottom Action Bar: Discard / Save Configuration
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 500;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Last saved: Just now',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _dcNameController.clear();
                            _pinController.clear();
                            _zipController.clear();
                            _latController.clear();
                            _longController.clear();
                            context.showSnackBar('Changes discarded');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final name = _dcNameController.text.trim().isEmpty
                                ? 'Circuit Point Alpha'
                                : _dcNameController.text.trim();
                            final newDc = DataCenterModel(
                              id: 'dc-${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              code: 'DC-${DateTime.now().millisecond}',
                              city: 'Coimbatore',
                              country: 'India',
                              region: 'Asia Pacific',
                              address: 'Circuit Point Tech Park',
                              status: _isActiveStatus ? 'active' : 'maintenance',
                              healthScore: 99.98,
                              totalServers: 24,
                              activeServers: 24,
                              totalRacks: 6,
                              powerCapacityKva: 1200.0,
                              coolingEfficiencyPue: 1.14,
                              ipPrefix: '198.51.100.0/24',
                            );
                            ref.read(dataCenterControllerProvider.notifier).addDataCenter(newDc);
                            context.showSnackBar('Configuration for "$name" saved successfully');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Configuration',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last saved: Just now',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _dcNameController.clear();
                        _pinController.clear();
                        _zipController.clear();
                        _latController.clear();
                        _longController.clear();
                        context.showSnackBar('Changes discarded');
                      },
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
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final name = _dcNameController.text.trim().isEmpty
                            ? 'Circuit Point Alpha'
                            : _dcNameController.text.trim();
                        final newDc = DataCenterModel(
                          id: 'dc-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          code: 'DC-${DateTime.now().millisecond}',
                          city: 'Coimbatore',
                          country: 'India',
                          region: 'Asia Pacific',
                          address: 'Circuit Point Tech Park',
                          status: _isActiveStatus ? 'active' : 'maintenance',
                          healthScore: 99.98,
                          totalServers: 24,
                          activeServers: 24,
                          totalRacks: 6,
                          powerCapacityKva: 1200.0,
                          coolingEfficiencyPue: 1.14,
                          ipPrefix: '198.51.100.0/24',
                        );
                        ref.read(dataCenterControllerProvider.notifier).addDataCenter(newDc);
                        context.showSnackBar('Configuration for "$name" saved successfully');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Configuration',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
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
      onPressed: () {
        if (_locationMethod == 'Use PIN') {
          final pin = _pinController.text.trim();
          context.showSnackBar(
            'Location coordinates resolved for PIN: ${pin.isEmpty ? "641062" : pin}',
          );
        } else if (_locationMethod == 'Use ZIP Code') {
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
      },
      child: const Text(
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
                                dc.country,
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
                  // Edit Pencil Icon: Opens Photo 5 Edit Dialog
                  IconButton(
                    tooltip: 'Edit Data Center',
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                    onPressed: () => _showEditConfigDialog(context, dc, isDark),
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
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 6,
                          color: Color(0xFF047857),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dc.status == 'active' ? 'Operational' : 'Maintenance',
                          style: const TextStyle(
                            color: Color(0xFF047857),
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
        onSave: (updatedDc) {
          ref.read(dataCenterControllerProvider.notifier).updateDataCenter(updatedDc);
          context.showSnackBar('Data Center "${updatedDc.name}" updated successfully');
        },
      ),
    );
  }

  // Infrastructure Tabs
  Widget _buildSectionContainer({
    required bool isDark,
    required IconData titleIcon,
    required String title,
    required String addBtnText,
    required VoidCallback onAdd,
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
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(addBtnText),
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

  Widget _buildGridInput(String label, {bool isDark = false, Widget? suffixIcon, String? hint, bool isRequired = false}) {
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

  Widget _buildDropdownInput(String label, String value, List<String> items, ValueChanged<String?> onChanged, {bool isDark = false, bool isRequired = false}) {
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
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8)),
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Inter',
              ),
              items: items.map((item) {
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

  Widget _buildSoftwareTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.view_in_ar_rounded,
          title: 'Software & Licensing',
          addBtnText: '+ Add Software Stack',
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
            child: _buildResponsiveGrid([
              _buildGridInput('Operating System', isDark: isDark),
              _buildGridInput('Hypervisor', isDark: isDark),
              _buildGridInput('Database Engine', isDark: isDark),
              _buildGridInput('Monitoring Tool', isDark: isDark),
              _buildGridInput('Backup Software', isDark: isDark),
              _buildGridInput('Antivirus', isDark: isDark),
              _buildGridInput('License Key', isDark: isDark),
              _buildGridInput('Vendor', isDark: isDark),
              _buildGridInput('Support Contact', isDark: isDark),
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
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'VALID',
                      style: TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ]),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPowerCoolingTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.bolt_rounded,
          title: 'Power & Cooling',
          addBtnText: '+ Add Environment Config',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResponsiveGrid([
                  _buildGridInput('UPS Capacity', isDark: isDark),
                  _buildGridInput('Power Consumption (W)', isDark: isDark),
                  _buildGridInput('Generator Backup', isDark: isDark),
                  _buildGridInput('Cooling Type', isDark: isDark),
                  _buildGridInput('Rack Temp (°C)', isDark: isDark),
                  _buildGridInput('PDU Details', isDark: isDark),
                ]),
                const SizedBox(height: 16),
                _buildCheckboxInput('Redundancy', false, (v) {}, isDark: isDark),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStorageTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.dns_outlined,
          title: 'Storage Management',
          addBtnText: '+ Add Storage Array',
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
            child: _buildResponsiveGrid([
              _buildGridInput('Storage Type', isDark: isDark),
              _buildGridInput('SSD/HDD/SAS/NVMe', isDark: isDark),
              _buildGridInput('Capacity', isDark: isDark),
              _buildGridInput('Used Space', isDark: isDark),
              _buildGridInput('Available Space', isDark: isDark),
              _buildGridInput('Backup Storage', isDark: isDark),
              _buildGridInput('RAID Level', isDark: isDark),
              _buildGridInput('NAS/SAN', isDark: isDark),
            ]),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSecurityTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.shield_outlined,
          title: 'Security & Surveillance',
          addBtnText: '+ Add Security Profile',
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
                Icon(Icons.delete_outline_rounded, size: 18, color: const Color(0xFFEF4444)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
      ],
    );
  }

  Widget _buildRackManagementTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        _buildSectionContainer(
          isDark: isDark,
          titleIcon: Icons.table_rows_rounded,
          title: 'Rack Management',
          addBtnText: '+ Add Rack Setup',
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
            child: _buildResponsiveGrid([
              _buildGridInput('Rack Name', isDark: isDark),
              _buildGridInput('Rack Number', isDark: isDark),
              _buildGridInput('Rack Size', isDark: isDark),
              _buildGridInput('Rack Type', isDark: isDark),
              _buildGridInput('Rack Status', isDark: isDark),
              _buildGridInput('Rack Temperature', isDark: isDark),
              _buildGridInput('Power Usage', isDark: isDark),
              _buildGridInput('Rack Unit Availability', isDark: isDark),
            ]),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNetworkTab(BuildContext context, bool isDark) {
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
          addBtnText: '+ Add Connection',
          onAdd: () {
            setState(() {
              int newId = _networkIdCounter++;
              _networkConnections.add(newId);
              _networkIps[newId] = [1];
              _networkIpCounters[newId] = 2;
            });
          },
          children: _networkConnections.map((id) {
            List<int> ips = _networkIps[id] ?? [];
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
                    _buildDropdownInput('Assigned Data Center', _getDropdown('net_${id}_dc', 'Select Data Center...'), ['Select Data Center...'], (v) => _setDropdown('net_${id}_dc', v), isDark: isDark, isRequired: true),
                    _buildDropdownInput('Server', _getDropdown('net_${id}_srv', 'Select Server...'), ['Select Server...'], (v) => _setDropdown('net_${id}_srv', v), isDark: isDark, isRequired: true),
                    _buildDropdownInput('Network Provider', _getDropdown('net_${id}_prov', 'Select ISP...'), ['Select ISP...'], (v) => _setDropdown('net_${id}_prov', v), isDark: isDark, isRequired: true),
                    _buildGridInput('Network Name', hint: 'e.g. Office Fiber Line', isDark: isDark, isRequired: true),
                    _buildDropdownInput('Connection Type', _getDropdown('net_${id}_type', 'Select Type...'), ['Select Type...'], (v) => _setDropdown('net_${id}_type', v), isDark: isDark, isRequired: true),
                    _buildGridInput('Bandwidth', hint: 'e.g. 100 Mbps, 1 Gbps', isDark: isDark, isRequired: true),
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
                          Expanded(child: _buildGridInput(isFirst ? 'IPv4' : 'IPv4 #$ipId', hint: 'e.g. 192.168.1.1', isDark: isDark)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGridInput(isFirst ? 'IPv6' : 'IPv6 #$ipId', hint: 'e.g. 2001:0db8::', isDark: isDark)),
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
                  }).toList(),
                  
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
      ],
    );
  }

  Widget _buildDetailStatCard(
    String title,
    String value,
    String desc,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Center(child: Icon(icon, color: color, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall(isDark).copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall(isDark).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    child: const Text(
                      '641062',
                      style: TextStyle(
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
                            widget.dataCenter.country.isEmpty ? 'India' : widget.dataCenter.country,
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
                          child: const Text(
                            '641062',
                            style: TextStyle(
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
                          child: const Text(
                            '11.0168',
                            style: TextStyle(
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
                          child: const Text(
                            '76.9558',
                            style: TextStyle(
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
    _statusSwitch = widget.dataCenter.status == 'active';
    _pinController = TextEditingController(text: '641062');
    _countryController = TextEditingController(
      text: widget.dataCenter.country.isEmpty ? 'India' : widget.dataCenter.country,
    );
    _zipController = TextEditingController(text: '641062');
    _latController = TextEditingController(text: '11.0168');
    _longController = TextEditingController(text: '76.9558');
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
                    final updatedDc = widget.dataCenter.copyWith(
                      name: _nameController.text.trim().isEmpty
                          ? widget.dataCenter.name
                          : _nameController.text.trim(),
                      status: _statusSwitch ? 'active' : 'maintenance',
                      address: 'Circuit Point Tech Park, PIN: ${_pinController.text.trim()}',
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
