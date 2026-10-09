import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/server_model.dart';
import '../../../shared/components/server_card.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_outlined_button.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/sub_tab_bar.dart';
import 'server_controller.dart';

class ServersScreen extends ConsumerStatefulWidget {
  const ServersScreen({super.key});

  @override
  ConsumerState<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends ConsumerState<ServersScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Add Server',
    'Add RAM',
    'Add Storage',
    'Add Network',
  ];

  final List<IconData> _tabIcons = [
    Icons.storage_rounded,
    Icons.memory_rounded,
    Icons.dns_outlined,
    Icons.show_chart_rounded,
  ];

  // Add Server Form controllers & state
  final _serverNameCtrl = TextEditingController(text: 'Web-Node-01');
  final _processorCtrl = TextEditingController(text: 'Intel Xeon Platinum');
  final _coresCtrl = TextEditingController(text: '16');
  final _threadsCtrl = TextEditingController(text: '32');
  final _macAddressCtrl = TextEditingController(text: '00:1A:2B:3C:4D:5E');

  String _selectedDataCenter = 'Select Data Center';
  String _selectedServerType = 'Rack Server';
  String _selectedStatus = 'Active';

  final List<String> _dataCenters = [
    'Select Data Center',
    'Circuit Point',
  ];

  final List<String> _serverTypes = [
    'Rack Server',
    'Blade Server',
    'Tower Server',
    'Mainframe',
  ];

  final List<String> _statusOptions = [
    'Active',
    'Maintenance',
    'Offline',
  ];

  @override
  void dispose() {
    _serverNameCtrl.dispose();
    _processorCtrl.dispose();
    _coresCtrl.dispose();
    _threadsCtrl.dispose();
    _macAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(serverControllerProvider);

    return Scaffold(
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

            // Sub Tab Bar (Matches left navigation from web app)
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
                child: _buildTabContent(context, state, isDark),
              ),
            ),
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
        return _buildAddRamTab(context, isDark);
      case 2:
        return _buildAddStorageTab(context, isDark);
      case 3:
        return _buildAddNetworkTab(context, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Add Server Tab (Exact match to Image 4)
  Widget _buildAddServerTab(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Add Server',
          style: AppTextStyles.titleMedium(isDark).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Deploy and configure server for your infrastructure.',
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 16),

        // Server Node #1 Card
        Container(
          padding: const EdgeInsets.all(18),
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
                  Icon(
                    Icons.dns_rounded,
                    size: 20,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Server Node #1',
                    style: AppTextStyles.titleSmall(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const StatusBadge(
                    status: 'active',
                    customLabel: 'ACTIVE',
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
                    child: _buildDropdownField(
                      label: 'Data Center',
                      value: _selectedDataCenter,
                      items: _dataCenters,
                      onChanged: (val) => setState(() => _selectedDataCenter = val!),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Server Name',
                      hintText: 'e.g. Web-Node-01',
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
                      hintText: 'e.g. Intel Xeon',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configured Server Nodes',
                  style: AppTextStyles.titleMedium(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
                '${state.servers.value?.length ?? 4} Nodes',
                style: AppTextStyles.labelSmall(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Configured Nodes Preview Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = state.servers.maybeWhen(
              data: (list) {
                if (list.isEmpty) return _getSampleCards(isDark);
                return list.take(4).map((srv) => _buildConfiguredServerTile(srv, isDark)).toList();
              },
              orElse: () => _getSampleCards(isDark),
            );
            
            int cols = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
            double spacing = 12.0;
            double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
            
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards.map((c) => SizedBox(width: width, child: c)).toList(),
            );
          },
        ),

        const SizedBox(height: 20),

        // Bottom Action Bar: Discard Changes / Save Configuration (Matches Image 4)
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Discard Changes',
                      onPressed: () {
                        _serverNameCtrl.text = 'Web-Node-01';
                        _processorCtrl.text = 'Intel Xeon Platinum';
                        _coresCtrl.text = '16';
                        _threadsCtrl.text = '32';
                        _macAddressCtrl.text = '00:1A:2B:3C:4D:5E';
                        context.showSnackBar('Server form reset to defaults');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Save Configuration',
                      onPressed: () {
                        final cores = int.tryParse(_coresCtrl.text) ?? 16;
                        final newServer = ServerModel(
                          id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
                          name: _serverNameCtrl.text.trim(),
                          hostname: '${_serverNameCtrl.text.trim().toLowerCase()}.datacenter.cloud',
                          ipAddress: '198.51.100.${20 + (DateTime.now().millisecond % 80)}',
                          ipv6Address: '2001:db8:85a3::8a2e:370:${DateTime.now().second}',
                          dataCenterId: 'dc-001',
                          dataCenterName: _selectedDataCenter,
                          location: 'Chennai, India',
                          status: _selectedStatus.toLowerCase() == 'active' ? 'running' : 'maintenance',
                          os: 'Ubuntu 24.04 LTS',
                          cpuUsagePercent: 18.5,
                          cpuCores: cores,
                          cpuModel: _processorCtrl.text.trim(),
                          ramUsagePercent: 34.0,
                          ramTotalGb: 64.0,
                          ramUsedGb: 21.8,
                          storageUsagePercent: 28.0,
                          storageTotalGb: 1000.0,
                          storageUsedGb: 280.0,
                          networkUsageMbps: 120.0,
                          networkInMbps: 75.0,
                          networkOutMbps: 45.0,
                          uptimeSeconds: 3600,
                          healthStatus: 'healthy',
                          tags: ['production', _selectedServerType],
                        );
                        ref.read(serverControllerProvider.notifier).addServer(newServer);
                        context.showSnackBar('Server ${_serverNameCtrl.text} configured and added!');
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
                    ),
                    Text(
                      '${srv.ipAddress} • ${srv.cpuModel}',
                      style: AppTextStyles.bodySmall(isDark).copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                onPressed: () => context.push(RouteNames.serverDetails, extra: srv),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () {
                  _serverNameCtrl.text = srv.name;
                  _processorCtrl.text = srv.cpuModel;
                  _coresCtrl.text = '${srv.cpuCores}';
                  context.showSnackBar('Editing server ${srv.name}');
                },
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: AppColors.successDark),
                    SizedBox(width: 4),
                    Text(
                      'Operational',
                      style: TextStyle(
                        color: AppColors.successDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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

  List<Widget> _getSampleCards(bool isDark) {
    return [
      _buildSampleServerTile('WaytoCloud...', 'Rack Server', 'Active', isDark),
      _buildSampleServerTile('cloud-134bd1...', 'Rack Server', 'Active', isDark),
      _buildSampleServerTile('node256', 'Rack Server', 'Active', isDark),
      _buildSampleServerTile('akasha', 'Rack Server', 'Active', isDark),
    ];
  }

  Widget _buildSampleServerTile(String name, String type, String status, bool isDark) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.dns_rounded, color: Color(0xFF4F46E5), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 12, color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(type, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _showServerConfigDialog(context, isDark, isEdit: false, name: name.replaceAll('...', ''), type: type, status: status);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.remove_red_eye_outlined, size: 18, color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B)),
                ),
              ),
              InkWell(
                onTap: () {
                  _showServerConfigDialog(context, isDark, isEdit: true, name: name.replaceAll('...', ''), type: type, status: status);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.edit_outlined, size: 18, color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Configured Nodes Fleet List Tab
  // ignore: unused_element
  Widget _buildConfiguredNodesTab(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    final statusFilters = ['All', 'Running', 'Warning', 'Stopped', 'Maintenance'];

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: AppSearchBar(
            hintText: 'Search server name, IP, or hostname...',
            onChanged: (val) =>
                ref.read(serverControllerProvider.notifier).search(val),
          ),
        ),

        // Status filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: statusFilters.map((status) {
              final isSelected = state.statusFilter.toLowerCase() == status.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(serverControllerProvider.notifier)
                      .setStatusFilter(status),
                  selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),

        // Servers list
        Expanded(
          child: state.servers.when(
            loading: () => ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => LoadingSkeleton.card(height: 130),
            ),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.read(serverControllerProvider.notifier).refresh(),
            ),
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.dns_rounded,
                  title: 'No Servers Found',
                  description: 'No servers match your current search query or filter criteria.',
                  primaryButtonText: 'Clear Filters',
                  onPrimaryPressed: () {
                    ref.read(serverControllerProvider.notifier).search('');
                    ref.read(serverControllerProvider.notifier).setStatusFilter('All');
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.read(serverControllerProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: AppSpacing.screenPadding,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final srv = list[i];
                    return ServerCard(
                      server: srv,
                      onTap: () {
                        context.push(RouteNames.serverDetails, extra: srv);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Add RAM Tab
  Widget _buildAddRamTab(BuildContext context, bool isDark) {
    bool isExpanded1 = true;
    bool isExpanded2 = false;
    bool isBasicDetails1 = false;
    List<int> ramModules1 = [1];
    List<int> ramModules2 = [1];
    int ramCounter1 = 2;
    int ramCounter2 = 2;

    return StatefulBuilder(
      builder: (context, setState) {
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
              'Web Server Alpha', 'Bare Metal', true, isExpanded1, isBasicDetails1, ramModules1,
              onExpand: () => setState(() => isExpanded1 = !isExpanded1),
              onCheckBasic: (v) => setState(() => isBasicDetails1 = v!),
              onAddRam: () => setState(() {
                ramModules1.add(ramCounter1++);
              }),
              onRemoveRam: (id) => setState(() {
                ramModules1.remove(id);
              }),
              isDark: isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Server 2
            _buildServerRamBlock(
              'Database Node 1', 'Virtual Machine', true, isExpanded2, false, ramModules2,
              onExpand: () => setState(() => isExpanded2 = !isExpanded2),
              onCheckBasic: (v) {},
              onAddRam: () => setState(() {
                ramModules2.add(ramCounter2++);
              }),
              onRemoveRam: (id) => setState(() {
                ramModules2.remove(id);
              }),
              isDark: isDark,
              isServer2: true,
            ),
          ],
        );
      },
    );
  }

  // 3. Add Storage Tab (Photo 3)
  Widget _buildAddStorageTab(BuildContext context, bool isDark) {
    List<int> storageList = [];
    int storageCounter = 1;

    return StatefulBuilder(
      builder: (context, setState) {
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
                        Text('Node #1 - Storage', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => storageList.add(storageCounter++)),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('+ Add Storage'),
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
                  if (storageList.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...storageList.map((id) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRamInput('Name', hint: '', isDark: isDark)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildRamInput('Type', hint: 'SSD', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildRamInput('Capacity (TB)', hint: '', isDark: isDark)),
                                const SizedBox(width: 16),
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: InkWell(
                                    onTap: () => setState(() => storageList.remove(id)),
                                    child: const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Text(
                              'Storage Array Pool: 0 TB Active',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF6366F1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddNetworkTab(BuildContext context, bool isDark) {
    List<int> ipList = [1];
    int ipCounter = 2;

    return StatefulBuilder(
      builder: (context, setState) {
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
                        Expanded(child: Text('Network Configuration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 14),
                          label: const Flexible(child: Text('+ Add Connection', overflow: TextOverflow.ellipsis)),
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
                        Row(
                          children: [
                            Expanded(child: _buildRamInput('Assigned Data Center *', hint: 'Select Data Center...', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRamInput('Server *', hint: 'Select Server...', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRamInput('Network Provider *', hint: 'Select ISP...', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildRamInput('Network Name *', hint: 'e.g. Office Fiber Line', isDark: isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRamInput('Connection Type *', hint: 'Select Type...', isDark: isDark, suffix: const Icon(Icons.keyboard_arrow_down, size: 16))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRamInput('Bandwidth *', hint: 'e.g. 100 Mbps, 1 Gbps', isDark: isDark)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...ipList.map((id) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildRamInput('IPv4${id > 1 ? ' #$id' : ''}', hint: 'e.g. 192.168.1.1', isDark: isDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildRamInput('IPv6${id > 1 ? ' #$id' : ''}', hint: 'e.g. 2001:0db8::', isDark: isDark)),
                              if (id > 1) ...[
                                const SizedBox(width: 16),
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: InkWell(
                                    onTap: () => setState(() => ipList.remove(id)),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                                      child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => ipList.add(ipCounter++)),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('+ Add IPs'),
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
          ],
        );
      },
    );
  }
  void _showServerConfigDialog(BuildContext context, bool isDark, {required bool isEdit, required String name, required String type, required String status}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
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
                      child: Icon(isEdit ? Icons.edit : Icons.dns_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Server Configuration' : 'Server Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
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
                // Form Fields
                Row(
                  children: [
                    Expanded(child: _buildDialogField('Data Center', 'Circuit Point', isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Server Name', name, isEdit, isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('Server Type', type, isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Processor Name', 'E5-2680 v4', isEdit, isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('CPU Cores', isEdit ? 'e.g. 16' : '', isEdit, isDark, isEmpty: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Threads', isEdit ? 'e.g. 32' : '', isEdit, isDark, isEmpty: true)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Server Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                if (!isEdit) ...[
                                  const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    status,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isEdit
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                          : const Color(0xFF10B981),
                                      fontWeight: isEdit ? FontWeight.normal : FontWeight.w600,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('MAC Address', isEdit ? '00:00:00:00:00:00' : 'N/A', isEdit, isDark, isEmpty: isEdit)),
                    const SizedBox(width: 16),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isEdit) {
                          setState(() {
                            _serverNameCtrl.text = name;
                            _selectedServerType = type;
                            _selectedStatus = status;
                          });
                        }
                        Navigator.pop(context);
                      },
                      icon: isEdit ? const SizedBox.shrink() : const Icon(Icons.edit, size: 16),
                      label: Flexible(child: Text(isEdit ? 'Save Changes' : 'Edit Configuration', overflow: TextOverflow.ellipsis)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
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

  Widget _buildDialogField(String label, String value, bool isEdit, bool isDark, {bool isEmpty = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: isEdit ? (isDark ? AppColors.surfaceDark : Colors.white) : (isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isEmpty ? (isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8)) : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRamInput(String label, {String? hint, String? value, bool isDark = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          height: 40,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRamModuleForm(int id, Function(int) onRemove, bool isDark, {bool isServer2 = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('RAM Module #$id', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                  if (!isServer2 && id == 1) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                      child: const Text('64 GB', style: TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onRemove(id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFFEF2F2),
                      ),
                      child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildRamInput('RAM Size', hint: 'Enter RAM Size', value: (!isServer2 && id == 1) ? '64' : null, isDark: isDark)),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text('GB', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRamInput('RAM Type', hint: 'DDR4', value: (!isServer2 && id == 1) ? 'DDR4' : null, isDark: isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRamInput('Frequency (MHz)', hint: 'Enter Frequency', value: (!isServer2 && id == 1) ? '3200' : null, isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildRamInput('Voltage (V)', hint: 'Enter Voltage (e.g. 1.2)', value: (!isServer2 && id == 1) ? '1.2' : null, isDark: isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRamInput('Latency', hint: 'CL16 / CL18 / CL40', value: (!isServer2 && id == 1) ? 'CL16' : null, isDark: isDark),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerRamBlock(
    String name, String type, bool isOnline, bool isExpanded, bool isBasicChecked, List<int> modules, {
    required VoidCallback onExpand,
    required ValueChanged<bool?> onCheckBasic,
    required VoidCallback onAddRam,
    required Function(int) onRemoveRam,
    required bool isDark,
    bool isServer2 = false,
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
                    ...modules.map((id) => _buildRamModuleForm(id, onRemoveRam, isDark, isServer2: isServer2)),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
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
