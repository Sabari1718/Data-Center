import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/data_center_model.dart';
import '../../../data/models/server_model.dart';
import '../../../data/repositories/server_repository.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_outlined_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import '../../data_center/presentation/data_center_controller.dart';
import 'server_controller.dart';

class _StorageItem {
  final TextEditingController nameCtrl = TextEditingController();
  String type = 'SSD';
  final TextEditingController capacityCtrl = TextEditingController(text: '');

  void dispose() {
    nameCtrl.dispose();
    capacityCtrl.dispose();
  }
}

class _IpRow {
  final TextEditingController ipv4Ctrl = TextEditingController();
  final TextEditingController ipv6Ctrl = TextEditingController();

  _IpRow({String ipv4 = '', String ipv6 = ''}) {
    ipv4Ctrl.text = ipv4;
    ipv6Ctrl.text = ipv6;
  }

  void dispose() {
    ipv4Ctrl.dispose();
    ipv6Ctrl.dispose();
  }
}

class _RamModuleData {
  final int id;
  final TextEditingController sizeCtrl;
  String unit;
  String ramType;
  final TextEditingController freqCtrl;
  final TextEditingController voltCtrl;
  final TextEditingController latencyCtrl;

  _RamModuleData({
    required this.id,
    String size = '',
    this.unit = 'GB',
    this.ramType = 'DDR4',
    String freq = '',
    String volt = '',
    String latency = '',
  })  : sizeCtrl = TextEditingController(text: size),
        freqCtrl = TextEditingController(text: freq),
        voltCtrl = TextEditingController(text: volt),
        latencyCtrl = TextEditingController(text: latency);

  void dispose() {
    sizeCtrl.dispose();
    freqCtrl.dispose();
    voltCtrl.dispose();
    latencyCtrl.dispose();
  }
}

class ServersScreen extends ConsumerStatefulWidget {
  const ServersScreen({super.key});

  @override
  ConsumerState<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends ConsumerState<ServersScreen> {
  final ScrollController _serverScrollController = ScrollController();
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Add Server',
    'Configured Nodes',
    'Add RAM',
    'Add Storage',
    'Add Network',
  ];

  final List<IconData> _tabIcons = [
    Icons.storage_rounded,
    Icons.layers_rounded,
    Icons.memory_rounded,
    Icons.dns_outlined,
    Icons.show_chart_rounded,
  ];

  // Server Nodes Search & Filter State
  final _serverSearchCtrl = TextEditingController();
  String _nodeStatusFilter = 'All';
  String _nodeTypeFilter = 'All';
  String _nodeDcFilter = 'All';

  // Add Server Form controllers & state
  ServerModel? _editingServer;
  String? _selectedDataCenterId;
  final _serverNameCtrl = TextEditingController(text: '');
  final _processorCtrl = TextEditingController(text: '');
  final _coresCtrl = TextEditingController(text: '');
  final _threadsCtrl = TextEditingController(text: '');
  final _macAddressCtrl = TextEditingController(text: '');

  String _selectedServerType = 'Rack Server';
  String _selectedStatus = 'Active';
  bool _isSavingServer = false;

  final List<String> _serverTypes = [
    'Rack Server',
    'Blade Server',
    'Tower Server',
    'Mainframe',
  ];

  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Maintenance',
  ];

  // Storage Form state
  final List<_StorageItem> _storageItems = [];

  // Network Form state
  String? _selectedNetworkDcId;
  String? _selectedNetworkServerId;
  String _selectedNetworkProvider = 'Jio';
  final _networkNameCtrl = TextEditingController(text: '');
  String _selectedConnectionType = '5G';
  final _bandwidthCtrl = TextEditingController(text: '');
  final List<_IpRow> _ipRows = [];
  bool _isSavingNetwork = false;

  // RAM Management State
  bool _isRamExpanded1 = true;
  bool _isRamExpanded2 = false;
  bool _isBasicRamDetails1 = false;
  bool _isBasicRamDetails2 = false;
  final List<_RamModuleData> _ramModules1 = [];
  final List<_RamModuleData> _ramModules2 = [];
  int _ramCounter1 = 2;
  int _ramCounter2 = 2;

  final List<String> _networkProviders = [
    'Jio',
    'Airtel',
    'Vodafone Idea',
    'BSNL',
    'ACT Fibernet',
    'Tata Communications',
    'Cloudflare',
    'Other',
  ];

  final List<String> _connectionTypes = [
    '5G',
    '4G LTE',
    'Fiber',
    'Dedicated Leased Line',
    'Broadband',
    'Satellite',
  ];

  @override
  void initState() {
    super.initState();
    _storageItems.add(_StorageItem());
    _ipRows.add(_IpRow());
    _ramModules1.add(_RamModuleData(
      id: 1,
      size: '63',
      unit: 'GB',
      ramType: 'DDR4',
      freq: '3200',
      volt: '1.2',
      latency: 'CL16',
    ));
    _ramModules2.add(_RamModuleData(
      id: 1,
      size: '32',
      unit: 'GB',
      ramType: 'DDR4',
      freq: '3200',
      volt: '1.2',
      latency: 'CL16',
    ));
  }

  @override
  void dispose() {
    _serverScrollController.dispose();
    _serverSearchCtrl.dispose();
    _serverNameCtrl.dispose();
    _processorCtrl.dispose();
    _coresCtrl.dispose();
    _threadsCtrl.dispose();
    _macAddressCtrl.dispose();
    for (final item in _storageItems) {
      item.dispose();
    }
    _networkNameCtrl.dispose();
    _bandwidthCtrl.dispose();
    for (final ip in _ipRows) {
      ip.dispose();
    }
    for (final m in _ramModules1) {
      m.dispose();
    }
    for (final m in _ramModules2) {
      m.dispose();
    }
    super.dispose();
  }

  void _resetServerForm() {
    _editingServer = null;
    _serverNameCtrl.clear();
    _processorCtrl.clear();
    _coresCtrl.clear();
    _threadsCtrl.clear();
    _macAddressCtrl.clear();
    _selectedServerType = 'Rack Server';
    _selectedStatus = 'Active';
    _selectedDataCenterId = null;
  }


  String _getDataCenterName(String? id, List<DataCenterModel> dcList) {
    if (id == null || id.isEmpty) return '';
    try {
      final dc = dcList.firstWhere((d) => d.id == id);
      return dc.name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(serverControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Server',
              subtitle: 'Fleet status, compute nodes & load metrics',
              actions: [
                IconButton(
                  tooltip: 'Refresh Fleet',
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  onPressed: () => ref.read(serverControllerProvider.notifier).refresh(),
                ),
              ],
            ),

            // Sub Tab Bar (Mobile/Tablet view)
            if (!isDesktop)
              SubTabBar(
                tabs: _tabs,
                icons: _tabIcons,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() => _selectedTabIndex = index);
                },
              ),

            // Tab Content with Desktop Sidebar
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) _buildSidebar(context, state, isDark),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildTabContent(context, state, isDark),
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

  Widget _buildSidebar(BuildContext context, ServerState state, bool isDark) {
    final serverList = state.servers.value ?? [];
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'SERVER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          _buildSideMenuItem(
            'Add Server',
            Icons.storage_rounded,
            _selectedTabIndex == 0,
            () => setState(() => _selectedTabIndex = 0),
            isDark,
          ),
          _buildSideMenuItem(
            'Configured Nodes',
            Icons.layers_rounded,
            _selectedTabIndex == 1,
            () => setState(() => _selectedTabIndex = 1),
            isDark,
            badge: '${serverList.length}',
          ),
          _buildSideMenuItem(
            'Add RAM',
            Icons.memory_rounded,
            _selectedTabIndex == 2,
            () => setState(() => _selectedTabIndex = 2),
            isDark,
          ),
          _buildSideMenuItem(
            'Add Storage',
            Icons.dns_outlined,
            _selectedTabIndex == 3,
            () => setState(() => _selectedTabIndex = 3),
            isDark,
          ),
          _buildSideMenuItem(
            'Add Network',
            Icons.show_chart_rounded,
            _selectedTabIndex == 4,
            () => setState(() => _selectedTabIndex = 4),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuItem(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF))
              : Colors.transparent,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null && badge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
              )
            else if (isSelected)
              const Icon(Icons.circle, size: 6, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAddServerTab(context, state, isDark);
      case 1:
        return _buildConfiguredNodesTab(context, state, isDark);
      case 2:
        return _buildAddRamTab(context, isDark);
      case 3:
        return _buildAddStorageTab(context, isDark);
      case 4:
        return _buildAddNetworkTab(context, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Add Server Tab (Matches Screenshot 1)
  Widget _buildAddServerTab(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    final dcState = ref.watch(dataCenterControllerProvider);
    final dcList = dcState.dataCenters.value ?? [];
    final serverList = state.servers.value ?? [];

    return RefreshIndicator(
      onRefresh: () => ref.read(serverControllerProvider.notifier).refresh(),
      child: ListView(
        controller: _serverScrollController,
        padding: AppSpacing.screenPadding,
        children: [
        Text(
          _editingServer != null ? 'Edit Server' : 'Add Server',
          style: AppTextStyles.titleMedium(isDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _editingServer != null
              ? 'Update configuration for "${_editingServer!.name}".'
              : 'Deploy and configure server for your infrastructure.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 16),

        // Server Node #1 Card / Edit Server Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: _editingServer != null
                  ? const Color(0xFF6366F1)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: _editingServer != null ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _editingServer != null ? Icons.edit_note_rounded : Icons.dns_rounded,
                    size: 20,
                    color: _editingServer != null
                        ? const Color(0xFF6366F1)
                        : (isDark ? AppColors.primaryLight : AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingServer != null
                          ? 'Edit Server: ${_editingServer!.name}'
                          : 'Server Node #1',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall(isDark).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_editingServer != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() => _resetServerForm());
                        context.showSnackBar('Edit cancelled. Switched to new server mode.');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 12, color: Color(0xFFDC2626)),
                            SizedBox(width: 4),
                            Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  StatusBadge(
                    status: _selectedStatus.toLowerCase(),
                    customLabel: _selectedStatus.toUpperCase(),
                    size: BadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Data Center Dropdown & Server Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Center',
                          style: AppTextStyles.labelMedium(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: dcList.any((d) => d.id == _selectedDataCenterId)
                                  ? _selectedDataCenterId
                                  : null,
                              hint: Text(
                                'Select Data Center',
                                style: AppTextStyles.bodyMedium(isDark).copyWith(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                              style: AppTextStyles.bodyMedium(isDark).copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Select Data Center'),
                                ),
                                ...dcList.map((dc) => DropdownMenuItem<String?>(
                                      value: dc.id,
                                      child: Text(dc.name, overflow: TextOverflow.ellipsis),
                                    )),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedDataCenterId = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Server Name',
                      hintText: 'e.g. Web Server Alpha',
                      controller: _serverNameCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Server Type Dropdown & Processor Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Server Type',
                      value: _selectedServerType,
                      items: _serverTypes,
                      onChanged: (val) => setState(() => _selectedServerType = val!),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Processor Name',
                      hintText: 'e.g. Intel Xeon / E5-2680 v4',
                      controller: _processorCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // CPU Cores & Thread Count
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'CPU Cores',
                      hintText: 'e.g. 16',
                      controller: _coresCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Thread Count',
                      hintText: 'e.g. 32',
                      controller: _threadsCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // MAC Address & Server Status Dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'MAC Address',
                      hintText: '00:00:00:00:00:00',
                      controller: _macAddressCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Server Status',
                      value: _selectedStatus,
                      items: _statusOptions,
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Configured Server Nodes Section
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                Text(
                  'Configured Server Nodes',
                  style: AppTextStyles.titleMedium(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    '${serverList.length} Nodes',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => setState(() => _selectedTabIndex = 1),
              icon: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF4F46E5)),
              label: Text(
                'View & Filter All (${serverList.length}) →',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Configured Nodes Preview Cards (Live data from GET /api/server-details, showing up to 3 cleanly)
        state.servers.when(
          loading: () => LoadingSkeleton.card(height: 120),
          error: (err, _) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.read(serverControllerProvider.notifier).refresh(),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No server nodes configured yet. Fill form above to add a server node.',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                ),
              );
            }

            final previewList = list.take(3).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    int cols = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                    double spacing = 12.0;
                    double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: previewList.map((srv) {
                        return SizedBox(
                          width: width,
                          child: _buildConfiguredServerTile(srv, isDark),
                        );
                      }).toList(),
                    );
                  },
                ),
                if (list.length > 3) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing 3 of ${list.length} configured nodes. Switch to "Configured Nodes" tab to search, filter, and manage all.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Open Tab →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Bottom Action Bar: Discard Changes / Save Configuration (Matches Screenshot 1)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last saved: Just now',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    '${serverList.length} Servers Configured',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Discard Changes',
                      onPressed: () {
                        setState(() => _resetServerForm());
                        context.showSnackBar('Server form reset');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _isSavingServer
                          ? 'Saving...'
                          : (_editingServer != null ? 'Save Configuration' : 'Save Configuration'),
                      isLoading: _isSavingServer,
                      onPressed: _handleSaveServer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}

  Future<void> _handleSaveServer() async {
    final srvName = _serverNameCtrl.text.trim();
    final procName = _processorCtrl.text.trim();
    final cores = int.tryParse(_coresCtrl.text.trim()) ?? 0;
    final threads = int.tryParse(_threadsCtrl.text.trim()) ?? 0;
    final mac = _macAddressCtrl.text.trim();

    setState(() => _isSavingServer = true);
    try {
      final dcState = ref.read(dataCenterControllerProvider);
      final dcList = dcState.dataCenters.value ?? [];
      final dcName = _getDataCenterName(_selectedDataCenterId, dcList);

      if (_editingServer != null) {
        // PUT /api/server-details/{id}
        final updated = _editingServer!.copyWith(
          name: srvName.isEmpty ? 'Unnamed Server' : srvName,
          cpuModel: procName,
          cpuCores: cores,
          threadCount: threads,
          macAddress: mac,
          serverType: _selectedServerType,
          status: _selectedStatus,
          dataCenterId: _selectedDataCenterId ?? '',
          dataCenterName: dcName,
        );
        await ref.read(serverControllerProvider.notifier).updateServer(updated);
        setState(() => _resetServerForm());
        if (mounted) {
          context.showSnackBar('Server "$srvName" updated successfully!');
        }
      } else {
        // POST /api/server-details
        final newServer = ServerModel(
          id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
          name: srvName.isEmpty ? 'Unnamed Server' : srvName,
          hostname: srvName.isNotEmpty
              ? '${srvName.toLowerCase().replaceAll(' ', '-')}.managed.cloud'
              : 'unnamed.managed.cloud',
          ipAddress: mac.contains('.') ? mac : '10.0.0.${DateTime.now().millisecond % 250}',
          ipv6Address: '',
          dataCenterId: _selectedDataCenterId ?? '',
          dataCenterName: dcName,
          location: dcName.isNotEmpty ? dcName : 'India',
          status: _selectedStatus,
          serverType: _selectedServerType,
          os: 'Ubuntu 24.04 LTS',
          cpuUsagePercent: 0.0,
          cpuCores: cores,
          threadCount: threads,
          cpuModel: procName,
          macAddress: mac,
          ramUsagePercent: 0.0,
          ramTotalGb: 64.0,
          ramUsedGb: 0.0,
          storageUsagePercent: 0.0,
          storageTotalGb: 1000.0,
          storageUsedGb: 0.0,
          networkUsageMbps: 0.0,
          networkInMbps: 0.0,
          networkOutMbps: 0.0,
          uptimeSeconds: 0,
          healthStatus: 'healthy',
        );
        await ref.read(serverControllerProvider.notifier).addServer(newServer);
        setState(() => _resetServerForm());
        if (mounted) {
          context.showSnackBar('Server "$srvName" created successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save server: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingServer = false);
      }
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfiguredServerTile(ServerModel srv, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.14)
                      : AppColors.primarySubtle,
                  borderRadius: AppRadius.borderSm,
                ),
                child: const Center(
                  child: Icon(Icons.dns_rounded, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      srv.name,
                      style: AppTextStyles.titleSmall(isDark).copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.view_in_ar_outlined,
                          size: 13,
                          color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            srv.serverType,
                            style: AppTextStyles.bodySmall(isDark).copyWith(
                              fontSize: 11.5,
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View Server Details',
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                onPressed: () => _showServerConfigDialog(
                  context,
                  isDark,
                  server: srv,
                  isEdit: false,
                ),
              ),
              IconButton(
                tooltip: 'Edit Server',
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showServerConfigDialog(
                  context,
                  isDark,
                  server: srv,
                  isEdit: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUS',
                style: AppTextStyles.labelSmall(isDark).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              _buildServerStatusBadge(srv.status, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerStatusBadge(String status, bool isDark) {
    final s = status.toLowerCase();
    Color bg;
    Color dot;
    Color text;
    String display = status;

    if (s == 'active') {
      bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
      dot = const Color(0xFF10B981);
      text = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);
      display = 'Active';
    } else if (s == 'inactive') {
      bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEF2F2);
      dot = const Color(0xFFEF4444);
      text = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
      display = 'Inactive';
    } else if (s == 'maintenance') {
      bg = isDark ? const Color(0xFF7C2D12).withValues(alpha: 0.5) : const Color(0xFFFFF1F2);
      dot = const Color(0xFFF43F5E);
      text = isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48);
      display = 'Maintenance';
    } else {
      bg = isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9);
      dot = const Color(0xFF64748B);
      text = isDark ? Colors.white70 : const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: dot),
          const SizedBox(width: 4),
          Text(
            display,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }



  // 2. Configured Nodes Fleet List Tab
  Widget _buildConfiguredNodesTab(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    final dcState = ref.watch(dataCenterControllerProvider);
    final dcList = dcState.dataCenters.value ?? [];
    final allServers = state.servers.value ?? [];

    // Filter servers based on search query and filter criteria
    final query = _serverSearchCtrl.text.trim().toLowerCase();
    final filteredServers = allServers.where((srv) {
      if (query.isNotEmpty) {
        final matchesQuery = srv.name.toLowerCase().contains(query) ||
            srv.ipAddress.toLowerCase().contains(query) ||
            srv.hostname.toLowerCase().contains(query) ||
            srv.cpuModel.toLowerCase().contains(query) ||
            (srv.macAddress ?? '').toLowerCase().contains(query) ||
            srv.dataCenterName.toLowerCase().contains(query) ||
            srv.serverType.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }
      if (_nodeStatusFilter != 'All') {
        if (srv.status.toLowerCase() != _nodeStatusFilter.toLowerCase()) return false;
      }
      if (_nodeTypeFilter != 'All') {
        if (srv.serverType.toLowerCase() != _nodeTypeFilter.toLowerCase()) return false;
      }
      if (_nodeDcFilter != 'All') {
        if (srv.dataCenterId != _nodeDcFilter && srv.dataCenterName != _nodeDcFilter) return false;
      }
      return true;
    }).toList();

    final hasActiveFilter = query.isNotEmpty ||
        _nodeStatusFilter != 'All' ||
        _nodeTypeFilter != 'All' ||
        _nodeDcFilter != 'All';

    final statusOptions = ['All', 'Active', 'Inactive', 'Maintenance'];
    final typeOptions = ['All', ..._serverTypes];
    final dcOptions = ['All', ...dcList.map((d) => d.name)];

    return RefreshIndicator(
      onRefresh: () => ref.read(serverControllerProvider.notifier).refresh(),
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        size: 24,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                      Text(
                        'Configured Server Nodes',
                        style: AppTextStyles.titleMedium(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFC7D2FE),
                          ),
                        ),
                        child: Text(
                          '${filteredServers.length} of ${allServers.length} Nodes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse, search, and manage all deployed servers across your data centers.',
                    style: AppTextStyles.bodySmall(isDark),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _resetServerForm();
                  setState(() => _selectedTabIndex = 0);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Server'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and Filter Bar Card
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
                // Search Input Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _serverSearchCtrl,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search server name, IP address, processor, MAC, or datacenter...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_serverSearchCtrl.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _serverSearchCtrl.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Controls Row
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status Filter Chips
                    Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                    ...statusOptions.map((st) {
                      final isSelected = _nodeStatusFilter.toLowerCase() == st.toLowerCase();
                      return ChoiceChip(
                        label: Text(st),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _nodeStatusFilter = st),
                        selectedColor: isDark ? AppColors.primaryLight : const Color(0xFF4F46E5),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                      );
                    }),

                    // Server Type Filter Dropdown
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _nodeTypeFilter != 'All'
                              ? const Color(0xFF4F46E5)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: typeOptions.contains(_nodeTypeFilter) ? _nodeTypeFilter : 'All',
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          items: typeOptions.map((t) {
                            return DropdownMenuItem<String>(
                              value: t,
                              child: Text(t == 'All' ? 'All Types' : t),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _nodeTypeFilter = val);
                          },
                        ),
                      ),
                    ),

                    // Data Center Filter Dropdown
                    if (dcOptions.length > 1)
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _nodeDcFilter != 'All'
                                ? const Color(0xFF4F46E5)
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: dcOptions.contains(_nodeDcFilter) ? _nodeDcFilter : 'All',
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                            dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            items: dcOptions.map((dc) {
                              return DropdownMenuItem<String>(
                                value: dc,
                                child: Text(dc == 'All' ? 'All Data Centers' : dc),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _nodeDcFilter = val);
                            },
                          ),
                        ),
                      ),

                    // Reset Filters Button
                    if (hasActiveFilter)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _serverSearchCtrl.clear();
                            _nodeStatusFilter = 'All';
                            _nodeTypeFilter = 'All';
                            _nodeDcFilter = 'All';
                          });
                        },
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Reset Filters', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Servers Content Grid
          state.servers.when(
            loading: () => LoadingSkeleton.card(height: 140),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.read(serverControllerProvider.notifier).refresh(),
            ),
            data: (_) {
              if (filteredServers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 48,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasActiveFilter ? 'No Servers Match Filters' : 'No Servers Configured Yet',
                          style: AppTextStyles.titleMedium(isDark).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasActiveFilter
                              ? 'Try adjusting your search terms or filter criteria.'
                              : 'Deploy and configure a new server node to get started.',
                          style: AppTextStyles.bodySmall(isDark),
                        ),
                        const SizedBox(height: 16),
                        if (hasActiveFilter)
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _serverSearchCtrl.clear();
                                _nodeStatusFilter = 'All';
                                _nodeTypeFilter = 'All';
                                _nodeDcFilter = 'All';
                              });
                            },
                            child: const Text('Clear All Filters'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              _resetServerForm();
                              setState(() => _selectedTabIndex = 0);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Server Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  int cols = constraints.maxWidth > 850 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
                  double spacing = 14.0;
                  double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: filteredServers.map((srv) {
                      return SizedBox(
                        width: width,
                        child: _buildConfiguredServerTile(srv, isDark),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 3. Add RAM Tab
  Widget _buildAddRamTab(BuildContext context, bool isDark) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'RAM Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a deployed server below to configure its RAM modules.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),

        // Server 1
        _buildServerRamBlock(
          'Web Server Alpha',
          'Bare Metal',
          true,
          _isRamExpanded1,
          _isBasicRamDetails1,
          _ramModules1,
          onExpand: () => setState(() => _isRamExpanded1 = !_isRamExpanded1),
          onCheckBasic: (v) => setState(() => _isBasicRamDetails1 = v ?? false),
          onAddRam: () => setState(() {
            _ramModules1.add(_RamModuleData(
              id: _ramCounter1++,
              size: '',
              unit: 'GB',
              ramType: 'DDR4',
              freq: '',
              volt: '',
              latency: '',
            ));
          }),
          onRemoveRam: (id) => setState(() {
            _ramModules1.removeWhere((m) => m.id == id);
          }),
          onDuplicateRam: (mod) => setState(() {
            _ramModules1.add(_RamModuleData(
              id: _ramCounter1++,
              size: mod.sizeCtrl.text,
              unit: mod.unit,
              ramType: mod.ramType,
              freq: mod.freqCtrl.text,
              volt: mod.voltCtrl.text,
              latency: mod.latencyCtrl.text,
            ));
          }),
          onSaveRam: () {
            context.showSnackBar('RAM configuration for Web Server Alpha saved successfully!');
          },
          onUpdate: () => setState(() {}),
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Server 2
        _buildServerRamBlock(
          'Database Node 1',
          'Virtual Machine',
          true,
          _isRamExpanded2,
          _isBasicRamDetails2,
          _ramModules2,
          onExpand: () => setState(() => _isRamExpanded2 = !_isRamExpanded2),
          onCheckBasic: (v) => setState(() => _isBasicRamDetails2 = v ?? false),
          onAddRam: () => setState(() {
            _ramModules2.add(_RamModuleData(
              id: _ramCounter2++,
              size: '',
              unit: 'GB',
              ramType: 'DDR4',
              freq: '',
              volt: '',
              latency: '',
            ));
          }),
          onRemoveRam: (id) => setState(() {
            _ramModules2.removeWhere((m) => m.id == id);
          }),
          onDuplicateRam: (mod) => setState(() {
            _ramModules2.add(_RamModuleData(
              id: _ramCounter2++,
              size: mod.sizeCtrl.text,
              unit: mod.unit,
              ramType: mod.ramType,
              freq: mod.freqCtrl.text,
              volt: mod.voltCtrl.text,
              latency: mod.latencyCtrl.text,
            ));
          }),
          onSaveRam: () {
            context.showSnackBar('RAM configuration for Database Node 1 saved successfully!');
          },
          onUpdate: () => setState(() {}),
          isDark: isDark,
        ),
      ],
    );
  }

  // 3. Add Storage Tab (Matches Screenshot 2)
  double _calculateStoragePool() {
    double total = 0.0;
    for (final item in _storageItems) {
      final val = double.tryParse(item.capacityCtrl.text.trim()) ?? 0.0;
      total += val;
    }
    return total;
  }

  Widget _buildAddStorageTab(BuildContext context, bool isDark) {
    final serverCount = ref.watch(serverControllerProvider).servers.value?.length ?? 1;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Add Storage',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Deploy and configure storage for your infrastructure.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),

        // Node #1 - Storage Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.dns_outlined, color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Node #1 - Storage',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _storageItems.add(_StorageItem()));
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Storage'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFFE0E7FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_storageItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'Click "Add Storage" to configure storage disks.',
                            style: TextStyle(
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      ..._storageItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Expanded(
                                flex: 3,
                                child: _buildStorageInputField(
                                  label: 'Name',
                                  hint: 'e.g. SSD Vol ${idx + 1}',
                                  controller: item.nameCtrl,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Type
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Type',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                        borderRadius: BorderRadius.circular(8),
                                        color: isDark ? AppColors.surfaceDark : Colors.white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: item.type,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          items: ['SSD', 'HDD', 'NVMe', 'Hybrid'].map((t) {
                                            return DropdownMenuItem<String>(value: t, child: Text(t));
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => item.type = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Capacity (TB)
                              Expanded(
                                flex: 3,
                                child: _buildStorageInputField(
                                  label: 'Capacity (TB)',
                                  hint: 'e.g. 2',
                                  controller: item.capacityCtrl,
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Delete Button
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _storageItems.removeAt(idx));
                                  },
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFEF4444),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    // Summary pool bar matching Screenshot 2
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Storage Array Pool: ${_calculateStoragePool().toStringAsFixed(_calculateStoragePool() % 1 == 0 ? 0 : 1)} TB Active',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Bottom Action Bar
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last saved: Just now',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    '$serverCount Servers Configured',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Discard Changes',
                      onPressed: () {
                        setState(() {
                          _storageItems.clear();
                          _storageItems.add(_StorageItem());
                        });
                        context.showSnackBar('Storage configuration reset');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Save Configuration',
                      onPressed: () {
                        context.showSnackBar('Storage configuration saved successfully!');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // 4. ISP & Network Management Tab (Matches Screenshot 3)
  Widget _buildAddNetworkTab(BuildContext context, bool isDark) {
    final dcState = ref.watch(dataCenterControllerProvider);
    final dcList = dcState.dataCenters.value ?? [];
    final serverState = ref.watch(serverControllerProvider);
    final serverList = serverState.servers.value ?? [];
    final networkConnections = serverState.networkConnections.value ?? [];

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'ISP & Network Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage internet providers, broadband lines, and network details for your infrastructure.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),

        // Network Configuration Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.wifi, color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Network Configuration',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _networkNameCtrl.clear();
                          _bandwidthCtrl.clear();
                          _ipRows.clear();
                          _ipRows.add(_IpRow());
                        });
                        context.showSnackBar('Connection form cleared');
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Connection', overflow: TextOverflow.ellipsis),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFFE0E7FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row 1: Assigned Data Center, Server, Network Provider
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Assigned Data Center
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned Data Center *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String?>(
                                    value: dcList.any((d) => d.id == _selectedNetworkDcId)
                                        ? _selectedNetworkDcId
                                        : null,
                                    hint: Text(
                                      'Select Data Center...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Select Data Center...'),
                                      ),
                                      ...dcList.map((dc) => DropdownMenuItem<String?>(
                                            value: dc.id,
                                            child: Text(dc.name, overflow: TextOverflow.ellipsis),
                                          )),
                                    ],
                                    onChanged: (val) => setState(() => _selectedNetworkDcId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Server
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Server *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String?>(
                                    value: serverList.any((s) => s.id == _selectedNetworkServerId)
                                        ? _selectedNetworkServerId
                                        : null,
                                    hint: Text(
                                      'Select Server...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Select Server...'),
                                      ),
                                      ...serverList.map((srv) => DropdownMenuItem<String?>(
                                            value: srv.id,
                                            child: Text(srv.name, overflow: TextOverflow.ellipsis),
                                          )),
                                    ],
                                    onChanged: (val) => setState(() => _selectedNetworkServerId = val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Network Provider
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Network Provider *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedNetworkProvider,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    items: _networkProviders.map((p) {
                                      return DropdownMenuItem<String>(value: p, child: Text(p));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedNetworkProvider = val);
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

                    // Row 2: Network Name, Connection Type, Bandwidth
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStorageInputField(
                            label: 'Network Name *',
                            hint: 'e.g. gggh',
                            controller: _networkNameCtrl,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connection Type *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedConnectionType,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    items: _connectionTypes.map((t) {
                                      return DropdownMenuItem<String>(value: t, child: Text(t));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedConnectionType = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStorageInputField(
                            label: 'Bandwidth *',
                            hint: 'e.g. 122',
                            controller: _bandwidthCtrl,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Dynamic IP rows
                    ..._ipRows.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final ipRow = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildStorageInputField(
                                label: 'IPv4${idx > 0 ? ' #${idx + 1}' : ''}',
                                hint: 'e.g. 122.233.44',
                                controller: ipRow.ipv4Ctrl,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStorageInputField(
                                label: 'IPv6${idx > 0 ? ' #${idx + 1}' : ''}',
                                hint: 'e.g. 7272:uur:990',
                                controller: ipRow.ipv6Ctrl,
                                isDark: isDark,
                              ),
                            ),
                            if (_ipRows.length > 1) ...[
                              const SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: InkWell(
                                  onTap: () => setState(() => _ipRows.removeAt(idx)),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _ipRows.add(_IpRow())),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add IPs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFFE0E7FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Configured Network Connections list if any
        if (networkConnections.isNotEmpty) ...[
          Text(
            'Configured Network Connections (${networkConnections.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...networkConnections.map((conn) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${conn.networkName} (${conn.networkProvider})',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '${conn.connectionType} • ${conn.bandwidth}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],

        // Bottom Action Bar: Discard / Save Configuration
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last saved: Just now',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    '${networkConnections.length} Connections Configured',
                    style: AppTextStyles.bodySmall(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Discard Changes',
                      onPressed: () {
                        setState(() {
                          _networkNameCtrl.clear();
                          _bandwidthCtrl.clear();
                          _selectedNetworkProvider = _networkProviders.first;
                          _selectedConnectionType = _connectionTypes.first;
                          _ipRows.clear();
                          _ipRows.add(_IpRow());
                        });
                        context.showSnackBar('Network form reset');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: _isSavingNetwork ? 'Saving...' : 'Save Configuration',
                      isLoading: _isSavingNetwork,
                      onPressed: _handleSaveNetworkConnection,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _handleSaveNetworkConnection() async {
    final netName = _networkNameCtrl.text.trim();
    if (netName.isEmpty) {
      context.showSnackBar('Please enter a Network Name');
      return;
    }

    setState(() => _isSavingNetwork = true);
    try {
      final ipsList = _ipRows
          .map((row) => {
                'ipv4': row.ipv4Ctrl.text.trim(),
                'ipv6': row.ipv6Ctrl.text.trim(),
              })
          .where((m) => m['ipv4']!.isNotEmpty || m['ipv6']!.isNotEmpty)
          .toList();

      final conn = ServerNetworkConnectionModel(
        id: 'net-${DateTime.now().millisecondsSinceEpoch}',
        dataCenterId: _selectedNetworkDcId,
        serverId: _selectedNetworkServerId,
        networkProvider: _selectedNetworkProvider,
        networkName: netName,
        connectionType: _selectedConnectionType,
        bandwidth: _bandwidthCtrl.text.trim(),
        ips: ipsList,
      );

      await ref.read(serverControllerProvider.notifier).saveNetworkConnection(conn);
      if (mounted) {
        context.showSnackBar('Network configuration saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save network configuration: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNetwork = false);
      }
    }
  }

  Widget _buildStorageInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
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
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: InputBorder.none,
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

  void _showServerConfigDialog(
    BuildContext context,
    bool isDark, {
    required ServerModel server,
    required bool isEdit,
  }) {
    final dcState = ref.read(dataCenterControllerProvider);
    final dcList = dcState.dataCenters.asData?.value ?? [];

    final nameCtrl = TextEditingController(text: server.name);
    final procCtrl = TextEditingController(text: server.cpuModel);
    final coresCtrl = TextEditingController(text: server.cpuCores > 0 ? '${server.cpuCores}' : '');
    final threadsCtrl = TextEditingController(text: server.threadCount > 0 ? '${server.threadCount}' : '');
    final macCtrl = TextEditingController(text: server.macAddress ?? '');

    String selectedType = _serverTypes.contains(server.serverType) ? server.serverType : _serverTypes.first;
    String selectedStatus = _statusOptions.contains(server.status) ? server.status : _statusOptions.first;
    String? selectedDcId = dcList.any((d) => d.id == server.dataCenterId) ? server.dataCenterId : null;

    bool currentEditMode = isEdit;
    bool isSaving = false;

    // Fetch latest details from API on dialog open (matches web app GET /api/server-details/{id})
    ref.read(serverRepositoryProvider).getServerById(server.id).then((fresh) {
      if (fresh != null) {
        nameCtrl.text = fresh.name;
        procCtrl.text = fresh.cpuModel;
        coresCtrl.text = fresh.cpuCores > 0 ? '${fresh.cpuCores}' : '';
        threadsCtrl.text = fresh.threadCount > 0 ? '${fresh.threadCount}' : '';
        macCtrl.text = fresh.macAddress ?? '';
        if (_serverTypes.contains(fresh.serverType)) {
          selectedType = fresh.serverType;
        }
        if (_statusOptions.contains(fresh.status)) {
          selectedStatus = fresh.status;
        }
        if (dcList.any((d) => d.id == fresh.dataCenterId)) {
          selectedDcId = fresh.dataCenterId;
        }
      }
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              currentEditMode ? Icons.edit_note_rounded : Icons.dns_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentEditMode
                                  ? 'Edit Server Configuration'
                                  : 'Server Configuration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogCtx),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          child: LayoutBuilder(
                            builder: (ctx, constraints) {
                              final isDialogMobile = constraints.maxWidth < 450;
                              if (isDialogMobile) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDialogDropdown(
                                      label: 'Data Center',
                                      value: selectedDcId,
                                      hint: 'Select Data Center',
                                      items: [
                                        const DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text('Select Data Center'),
                                        ),
                                        ...dcList.map((dc) => DropdownMenuItem<String?>(
                                          value: dc.id,
                                          child: Text(dc.name, overflow: TextOverflow.ellipsis),
                                        )),
                                      ],
                                      onChanged: currentEditMode
                                          ? (val) => setModalState(() => selectedDcId = val)
                                          : null,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDialogTextField(
                                      label: 'Server Name',
                                      controller: nameCtrl,
                                      hint: 'Unnamed Server',
                                      readOnly: !currentEditMode,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDialogDropdown(
                                      label: 'Server Type',
                                      value: selectedType,
                                      hint: 'Select Type',
                                      items: _serverTypes.map((t) => DropdownMenuItem<String?>(
                                        value: t,
                                        child: Text(t, overflow: TextOverflow.ellipsis),
                                      )).toList(),
                                      onChanged: currentEditMode
                                          ? (val) => setModalState(() => selectedType = val ?? _serverTypes.first)
                                          : null,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDialogTextField(
                                      label: 'Processor Name',
                                      controller: procCtrl,
                                      hint: 'e.g. Intel Xeon',
                                      readOnly: !currentEditMode,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDialogTextField(
                                            label: 'CPU Cores',
                                            controller: coresCtrl,
                                            hint: 'e.g. 16',
                                            keyboardType: TextInputType.number,
                                            readOnly: !currentEditMode,
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildDialogTextField(
                                            label: 'Threads',
                                            controller: threadsCtrl,
                                            hint: 'e.g. 32',
                                            keyboardType: TextInputType.number,
                                            readOnly: !currentEditMode,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDialogDropdown(
                                      label: 'Server Status',
                                      value: selectedStatus,
                                      hint: 'Status',
                                      items: _statusOptions.map((s) => DropdownMenuItem<String?>(
                                        value: s,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: s.toLowerCase() == 'active'
                                                  ? const Color(0xFF10B981)
                                                  : (s.toLowerCase() == 'inactive'
                                                      ? const Color(0xFFEF4444)
                                                      : const Color(0xFFF43F5E)),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                s,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
                                      onChanged: currentEditMode
                                          ? (val) => setModalState(() => selectedStatus = val ?? _statusOptions.first)
                                          : null,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDialogTextField(
                                      label: 'MAC Address',
                                      controller: macCtrl,
                                      hint: '00:00:00:00:00:00',
                                      readOnly: !currentEditMode,
                                      isDark: isDark,
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: Data Center & Server Name
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDialogDropdown(
                                          label: 'Data Center',
                                          value: selectedDcId,
                                          hint: 'Select Data Center',
                                          items: [
                                            const DropdownMenuItem<String?>(
                                              value: null,
                                              child: Text('Select Data Center'),
                                            ),
                                            ...dcList.map((dc) => DropdownMenuItem<String?>(
                                              value: dc.id,
                                              child: Text(dc.name, overflow: TextOverflow.ellipsis),
                                            )),
                                          ],
                                          onChanged: currentEditMode
                                              ? (val) => setModalState(() => selectedDcId = val)
                                              : null,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDialogTextField(
                                          label: 'Server Name',
                                          controller: nameCtrl,
                                          hint: 'Unnamed Server',
                                          readOnly: !currentEditMode,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Row 2: Server Type & Processor Name
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDialogDropdown(
                                          label: 'Server Type',
                                          value: selectedType,
                                          hint: 'Select Type',
                                          items: _serverTypes.map((t) => DropdownMenuItem<String?>(
                                            value: t,
                                            child: Text(t, overflow: TextOverflow.ellipsis),
                                          )).toList(),
                                          onChanged: currentEditMode
                                              ? (val) => setModalState(() => selectedType = val ?? _serverTypes.first)
                                              : null,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDialogTextField(
                                          label: 'Processor Name',
                                          controller: procCtrl,
                                          hint: 'e.g. Intel Xeon',
                                          readOnly: !currentEditMode,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Row 3: CPU Cores & Threads & Server Status
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildDialogTextField(
                                          label: 'CPU Cores',
                                          controller: coresCtrl,
                                          hint: 'e.g. 16',
                                          keyboardType: TextInputType.number,
                                          readOnly: !currentEditMode,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: _buildDialogTextField(
                                          label: 'Threads',
                                          controller: threadsCtrl,
                                          hint: 'e.g. 32',
                                          keyboardType: TextInputType.number,
                                          readOnly: !currentEditMode,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 3,
                                        child: _buildDialogDropdown(
                                          label: 'Server Status',
                                          value: selectedStatus,
                                          hint: 'Status',
                                          items: _statusOptions.map((s) => DropdownMenuItem<String?>(
                                            value: s,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: s.toLowerCase() == 'active'
                                                      ? const Color(0xFF10B981)
                                                      : (s.toLowerCase() == 'inactive'
                                                          ? const Color(0xFFEF4444)
                                                          : const Color(0xFFF43F5E)),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    s,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )).toList(),
                                          onChanged: currentEditMode
                                              ? (val) => setModalState(() => selectedStatus = val ?? _statusOptions.first)
                                              : null,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Row 4: MAC Address
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDialogTextField(
                                          label: 'MAC Address',
                                          controller: macCtrl,
                                          hint: '00:00:00:00:00:00',
                                          readOnly: !currentEditMode,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Spacer(),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                side: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                currentEditMode ? 'Cancel' : 'Close',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!currentEditMode) {
                                        setModalState(() => currentEditMode = true);
                                        return;
                                      }

                                      setModalState(() => isSaving = true);
                                      final srvName = nameCtrl.text.trim();
                                      final dcName = _getDataCenterName(selectedDcId, dcList);
                                      final updated = server.copyWith(
                                        name: srvName.isEmpty ? 'Unnamed Server' : srvName,
                                        cpuModel: procCtrl.text.trim(),
                                        cpuCores: int.tryParse(coresCtrl.text.trim()) ?? 0,
                                        threadCount: int.tryParse(threadsCtrl.text.trim()) ?? 0,
                                        macAddress: macCtrl.text.trim(),
                                        serverType: selectedType,
                                        status: selectedStatus,
                                        dataCenterId: selectedDcId ?? (server.dataCenterId.isNotEmpty ? server.dataCenterId : '5'),
                                        dataCenterName: dcName.isNotEmpty ? dcName : server.dataCenterName,
                                      );

                                      try {
                                        await ref.read(serverControllerProvider.notifier).updateServer(updated);
                                        if (dialogCtx.mounted) {
                                          Navigator.pop(dialogCtx);
                                          context.showSnackBar('Server "${updated.name}" updated successfully!');
                                        }
                                      } catch (e) {
                                        if (dialogCtx.mounted) {
                                          setModalState(() => isSaving = false);
                                          context.showSnackBar('Failed to update server: $e', isError: true);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      currentEditMode ? 'Save Changes' : 'Edit Configuration',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool readOnly,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: readOnly
                ? (isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC))
                : (isDark ? AppColors.surfaceDark : Colors.white),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String?>> items,
    required ValueChanged<String?>? onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: onChanged == null
                ? (isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC))
                : (isDark ? AppColors.surfaceDark : Colors.white),
          ),
          alignment: Alignment.centerLeft,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: items.any((it) => it.value == value) ? value : null,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              ),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildRamInput(
    String label, {
    String? hint,
    String? value,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool isDark = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
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
                child: TextFormField(
                  controller: controller,
                  initialValue: controller == null ? value : null,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              ?suffix,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRamModuleForm(
    _RamModuleData mod,
    VoidCallback onRemove,
    VoidCallback onDuplicate,
    VoidCallback onUpdate,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Title, Badge, Copy & Delete Actions
              Row(
                children: [
                  Text(
                    'RAM Module #${mod.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${mod.sizeCtrl.text.isNotEmpty ? mod.sizeCtrl.text : '0'} ${mod.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onDuplicate,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFFEF2F2),
                      ),
                      child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isMobile) ...[
                // Mobile layout
                _buildRamSizeWithUnitInput(mod, onUpdate, isDark),
                const SizedBox(height: 12),
                _buildRamTypeDropdown(mod, onUpdate, isDark),
                const SizedBox(height: 12),
                _buildRamInput(
                  'Frequency (MHz)',
                  controller: mod.freqCtrl,
                  hint: '3200',
                  isDark: isDark,
                  onChanged: (_) => onUpdate(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRamInput(
                        'Voltage (V)',
                        controller: mod.voltCtrl,
                        hint: '1.2',
                        isDark: isDark,
                        onChanged: (_) => onUpdate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRamInput(
                        'Latency',
                        controller: mod.latencyCtrl,
                        hint: 'CL16',
                        isDark: isDark,
                        onChanged: (_) => onUpdate(),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Desktop layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildRamSizeWithUnitInput(mod, onUpdate, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildRamTypeDropdown(mod, onUpdate, isDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildRamInput(
                        'Frequency (MHz)',
                        controller: mod.freqCtrl,
                        hint: '3200',
                        isDark: isDark,
                        onChanged: (_) => onUpdate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRamInput(
                        'Voltage (V)',
                        controller: mod.voltCtrl,
                        hint: '1.2',
                        isDark: isDark,
                        onChanged: (_) => onUpdate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRamInput(
                        'Latency',
                        controller: mod.latencyCtrl,
                        hint: 'CL16',
                        isDark: isDark,
                        onChanged: (_) => onUpdate(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRamSizeWithUnitInput(_RamModuleData mod, VoidCallback onUpdate, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RAM Size',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                ),
                child: TextField(
                  controller: mod.sizeCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onUpdate(),
                  decoration: const InputDecoration(
                    hintText: 'Enter RAM size',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF6366F1), // Purple border matching Screenshot 4
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.surfaceDark : Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ['MB', 'GB', 'TB'].contains(mod.unit) ? mod.unit : 'GB',
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6366F1)),
                  items: ['MB', 'GB', 'TB'].map((u) {
                    return DropdownMenuItem<String>(
                      value: u,
                      child: Text(
                        u,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      mod.unit = val;
                      onUpdate();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRamTypeDropdown(_RamModuleData mod, VoidCallback onUpdate, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RAM Type',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF6366F1), // Purple border matching Screenshot 5
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: ['DDR3', 'DDR4', 'DDR5'].contains(mod.ramType) ? mod.ramType : 'DDR4',
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6366F1)),
              items: ['DDR3', 'DDR4', 'DDR5'].map((t) {
                return DropdownMenuItem<String>(
                  value: t,
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  mod.ramType = val;
                  onUpdate();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerRamBlock(
    String name, String type, bool isOnline, bool isExpanded, bool isBasicChecked, List<_RamModuleData> modules, {
    required VoidCallback onExpand,
    required ValueChanged<bool?> onCheckBasic,
    required VoidCallback onAddRam,
    required Function(int) onRemoveRam,
    required Function(_RamModuleData) onDuplicateRam,
    required VoidCallback onSaveRam,
    required VoidCallback onUpdate,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onExpand,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.dns_outlined, color: Color(0xFF4F46E5), size: 20),
                  const SizedBox(width: 12),
                  Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                    child: Text(type, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.circle, size: 6, color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                  const Spacer(),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isBasicChecked,
                            onChanged: onCheckBasic,
                            activeColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          Text('Basic RAM Details', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: onAddRam,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add RAM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                  
                  if (isBasicChecked) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildRamInput('Total Installed RAM (GB)', hint: 'e.g. 128', isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRamInput('ECC Support', hint: 'Supported', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRamInput('Memory Channel Configuration', hint: 'Dual Channel', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  if (modules.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'No RAM modules configured for this server. Click "Add RAM" to begin.',
                          style: TextStyle(color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else ...[
                    ...modules.map((mod) => _buildRamModuleForm(
                          mod,
                          () => onRemoveRam(mod.id),
                          () => onDuplicateRam(mod),
                          onUpdate,
                          isDark,
                        )),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: onSaveRam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save RAM Configuration', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
