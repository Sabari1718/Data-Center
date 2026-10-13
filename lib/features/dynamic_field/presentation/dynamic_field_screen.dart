import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_header.dart';
import 'dynamic_field_controller.dart';

class DynamicFieldScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const DynamicFieldScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<DynamicFieldScreen> createState() => _DynamicFieldScreenState();
}

class _DynamicFieldScreenState extends ConsumerState<DynamicFieldScreen> {
  late int _selectedIndex;

  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _hostingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  @override
  void dispose() {
    _domainController.dispose();
    _hostingController.dispose();
    super.dispose();
  }

  Future<void> _addDomainRegistrar() async {
    final text = _domainController.text.trim();
    if (text.isEmpty) return;

    final success = await ref
        .read(dynamicFieldControllerProvider.notifier)
        .addDomainRegistrar(text);

    if (mounted) {
      if (success) {
        _domainController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Domain registrar created successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create domain registrar. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addHostingType() async {
    final text = _hostingController.text.trim();
    if (text.isEmpty) return;

    final success = await ref
        .read(dynamicFieldControllerProvider.notifier)
        .addHostingType(text);

    if (mounted) {
      if (success) {
        _hostingController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hosting type created successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create hosting type. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeDomainRegistrar(int id) async {
    final success = await ref
        .read(dynamicFieldControllerProvider.notifier)
        .deleteDomainRegistrar(id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Domain registrar deleted successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete domain registrar. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeHostingType(int id) async {
    final success = await ref
        .read(dynamicFieldControllerProvider.notifier)
        .deleteHostingType(id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hosting type deleted successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete hosting type. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final state = ref.watch(dynamicFieldControllerProvider);

    final registrarCount = state.registrars.asData?.value.length ?? 0;
    final hostingCount = state.hostingTypes.asData?.value.length ?? 0;
    final currentCount = _selectedIndex == 0 ? registrarCount : hostingCount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // Web Top Navigation Bar
            if (isDesktop) _buildAcmeTopBar(context, isDark),

            if (!isDesktop) ...[
              const SizedBox(height: 6),
              AppHeader(
                title: 'Dynamic Field',
                subtitle: 'Manage dynamic options',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      context.pop();
                    } else {
                      context.go(RouteNames.dashboard);
                    }
                  },
                ),
              ),
            ],

          // Mobile / Tablet Tab Switcher
          if (!isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Domain Registrars')),
                      selected: _selectedIndex == 0,
                      selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                        color: _selectedIndex == 0
                            ? const Color(0xFF6366F1)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedIndex = 0);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Hosting Types')),
                      selected: _selectedIndex == 1,
                      selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                        color: _selectedIndex == 1
                            ? const Color(0xFF6366F1)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Sidebar
                if (isDesktop)
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'DYNAMIC FIELD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        _buildSidebarItem('Add Domain Registrars', Icons.language, 0, isDark),
                        _buildSidebarItem('Add Hosting Types', Icons.dns, 1, isDark),
                      ],
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Container(
                    color: isDark ? AppColors.backgroundDark : Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedIndex == 0 ? 'Add Domain Registrars' : 'Add Hosting Types',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage dropdown options and configurable fields across the application.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Configuration Box
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Box Header
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        size: 20,
                                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedIndex == 0
                                              ? 'Add Domain Registrars Configuration'
                                              : 'Add Hosting Types Configuration',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // Add Option Section
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 260,
                                          maxWidth: 420,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Add New Option',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: _selectedIndex == 0 ? _domainController : _hostingController,
                                              enabled: !state.isAdding,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'e.g. New Provider',
                                                hintStyle: TextStyle(
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                                  ),
                                                ),
                                                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                                                filled: true,
                                              ),
                                              onSubmitted: (_) {
                                                if (!state.isAdding) {
                                                  _selectedIndex == 0 ? _addDomainRegistrar() : _addHostingType();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 46,
                                        child: OutlinedButton(
                                          onPressed: state.isAdding
                                              ? null
                                              : () => _selectedIndex == 0
                                                  ? _addDomainRegistrar()
                                                  : _addHostingType(),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF6366F1),
                                            side: const BorderSide(color: Color(0xFFC7D2FE), style: BorderStyle.solid),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: state.isAdding
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFF6366F1),
                                                  ),
                                                )
                                              : const Text(
                                                  'Add',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1),

                                // Configured List Section
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _selectedIndex == 0
                                                  ? 'Configured Add Domain Registrars'
                                                  : 'Configured Add Hosting Types',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.surfaceDark : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                            ),
                                            child: Text(
                                              '$currentCount Options',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildConfiguredList(isDark, state),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    );
  }

  Widget _buildConfiguredList(bool isDark, DynamicFieldState state) {
    if (_selectedIndex == 0) {
      return state.registrars.when(
        loading: () => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF6366F1)),
            ),
          ),
        ),
        error: (err, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to load domain registrars.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.red[800],
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref
                    .read(dynamicFieldControllerProvider.notifier)
                    .loadRegistrars(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                ),
              ),
              child: Center(
                child: Text(
                  'No options configured yet.',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: list.map((item) {
              final isDeleting = state.deletingRegistrarId == item.id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: isDark ? AppColors.primaryLight : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        item.registrarName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (isDeleting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF4444),
                        ),
                      )
                    else
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => _removeDomainRegistrar(item.id),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      );
    } else {
      return state.hostingTypes.when(
        loading: () => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF6366F1)),
            ),
          ),
        ),
        error: (err, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to load hosting types.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.red[800],
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ref
                    .read(dynamicFieldControllerProvider.notifier)
                    .loadHostingTypes(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                ),
              ),
              child: Center(
                child: Text(
                  'No options configured yet.',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: list.map((item) {
              final isDeleting = state.deletingHostingTypeId == item.id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: isDark ? AppColors.primaryLight : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        item.hostingTypeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (isDeleting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF4444),
                        ),
                      )
                    else
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => _removeHostingType(item.id),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      );
    }
  }

  Widget _buildSidebarItem(String title, IconData icon, int index, bool isDark) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryDark.withValues(alpha: 0.1) : AppColors.primaryLight.withValues(alpha: 0.1))
              : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.fiber_manual_record,
                size: 8,
                color: Color(0xFF6366F1),
              ),
          ],
        ),
      ),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTopNavLink(title: 'Dashboard', route: RouteNames.dashboard, isDark: isDark, context: context),
                  _buildTopNavLink(title: 'Data Center', route: RouteNames.dataCenter, isDark: isDark, context: context),
                  _buildTopNavLink(title: 'Server', route: RouteNames.servers, isDark: isDark, context: context),
                  _buildTopNavLink(title: 'Domain', route: RouteNames.domains, isDark: isDark, context: context),
                  _buildTopNavLink(title: 'Hosting', route: RouteNames.hosting, isDark: isDark, context: context),
                  _buildTopNavLink(title: 'Dynamic Field', route: RouteNames.dynamicField, isActive: true, isDark: isDark, context: context),
                ],
              ),
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
              const Icon(Icons.circle, size: 4, color: Color(0xFF6366F1)),
            ]
          ],
        ),
      ),
    );
  }
}
