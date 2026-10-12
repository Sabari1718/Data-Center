import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/data_center_model.dart';
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
import '../../data_center/presentation/data_center_controller.dart';
import 'server_controller.dart';

class _StorageItem {
  final TextEditingController nameCtrl = TextEditingController();
  String type = 'SSD';
  final TextEditingController capacityCtrl = TextEditingController(text: '0');

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
  ServerModel? _editingServer;
  String? _selectedDataCenterId;
  final _serverNameCtrl = TextEditingController(text: '');
  final _processorCtrl = TextEditingController(text: '');
  final _coresCtrl = TextEditingController(text: '0');
  final _threadsCtrl = TextEditingController(text: '0');
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
    'Maintenance',
    'Stopped',
    'Offline',
  ];

  // Storage Form state
  final List<_StorageItem> _storageItems = [];

  // Network Form state
  String? _selectedNetworkDcId;
  String? _selectedNetworkServerId;
  String _selectedNetworkProvider = 'Jio';
  final _networkNameCtrl = TextEditingController(text: 'gggh');
  String _selectedConnectionType = '5G';
  final _bandwidthCtrl = TextEditingController(text: '122');
  final List<_IpRow> _ipRows = [];
  bool _isSavingNetwork = false;

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
    _ipRows.add(_IpRow(ipv4: '122.233.44', ipv6: '7272:uur:990'));
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  void _resetServerForm() {
    _editingServer = null;
    _serverNameCtrl.clear();
    _processorCtrl.clear();
    _coresCtrl.text = '0';
    _threadsCtrl.text = '0';
    _macAddressCtrl.clear();
    _selectedServerType = 'Rack Server';
    _selectedStatus = 'Active';
    _selectedDataCenterId = null;
  }

  void _editServer(ServerModel srv) {
    setState(() {
      _editingServer = srv;
      _serverNameCtrl.text = srv.name;
      _processorCtrl.text = srv.cpuModel;
      _coresCtrl.text = '${srv.cpuCores}';
      _threadsCtrl.text = '${srv.threadCount}';
      _macAddressCtrl.text = srv.macAddress ?? '';
      _selectedServerType = srv.serverType;
      _selectedStatus = srv.status;
      _selectedDataCenterId = srv.dataCenterId.isNotEmpty ? srv.dataCenterId : null;
      _selectedTabIndex = 0;
    });
    context.showSnackBar('Editing server "${srv.name}". Modify values and click Save Configuration.');
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

  // 1. Add Server Tab (Matches Screenshot 1)
  Widget _buildAddServerTab(
    BuildContext context,
    ServerState state,
    bool isDark,
  ) {
    final dcState = ref.watch(dataCenterControllerProvider);
    final dcList = dcState.dataCenters.value ?? [];
    final serverList = state.servers.value ?? [];

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

        // Server Node #1 Card / Edit Server Card
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
                    _editingServer != null
                        ? 'Edit Server: ${_editingServer!.name}'
                        : 'Server Node #1',
                    style: AppTextStyles.titleSmall(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_editingServer != null) ...[
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        setState(() => _resetServerForm());
                        context.showSnackBar('Edit cancelled. Switched to new server mode.');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              'Cancel Edit',
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
                  const Spacer(),
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
                      hintText: 'e.g. sabari ',
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
                      hintText: 'e.g. 1',
                      controller: _coresCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Thread Count',
                      hintText: 'e.g. 1',
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
                      hintText: 'e.g. sadccd',
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
                '${serverList.length} Nodes',
                style: AppTextStyles.labelSmall(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Configured Nodes Preview Cards (Live data from GET /api/server-details)
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

            return LayoutBuilder(
              builder: (context, constraints) {
                int cols = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                double spacing = 12.0;
                double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: list.map((srv) {
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
                    ),
                    Text(
                      '${srv.ipAddress} • ${srv.cpuModel}',
                      style: AppTextStyles.bodySmall(isDark).copyWith(fontSize: 11.5),
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
                onPressed: () => _editServer(srv),
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
                            'Click "+ Add Storage" to configure storage disks.',
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
                          _networkNameCtrl.text = 'gggh';
                          _bandwidthCtrl.text = '122';
                          _selectedNetworkProvider = 'Jio';
                          _selectedConnectionType = '5G';
                          _ipRows.clear();
                          _ipRows.add(_IpRow(ipv4: '122.233.44', ipv6: '7272:uur:990'));
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
                    Expanded(child: _buildDialogField('Data Center', server.dataCenterName.isNotEmpty ? server.dataCenterName : 'Circuit Point', isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Server Name', server.name, isEdit, isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('Server Type', server.serverType, isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Processor Name', server.cpuModel, isEdit, isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDialogField('CPU Cores', '${server.cpuCores}', isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDialogField('Threads', '${server.threadCount}', isEdit, isDark)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Status',
                            style: TextStyle(
                              fontSize: 11,
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
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    server.status,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
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
                    Expanded(child: _buildDialogField('MAC Address', server.macAddress ?? 'N/A', isEdit, isDark)),
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
                        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        side: BorderSide(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editServer(server);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Configuration'),
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
              ?suffix,
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
