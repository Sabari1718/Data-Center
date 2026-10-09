import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/extensions/context_extensions.dart';

import '../../../shared/widgets/app_header.dart';

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

  List<String> _domainRegistrars = [];
  List<String> _hostingTypes = ['sa'];

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

  void _addDomainRegistrar() {
    if (_domainController.text.trim().isNotEmpty) {
      setState(() {
        _domainRegistrars.add(_domainController.text.trim());
        _domainController.clear();
      });
    }
  }

  void _addHostingType() {
    if (_hostingController.text.trim().isNotEmpty) {
      setState(() {
        _hostingTypes.add(_hostingController.text.trim());
        _hostingController.clear();
      });
    }
  }

  void _removeDomainRegistrar(int index) {
    setState(() {
      _domainRegistrars.removeAt(index);
    });
  }

  void _removeHostingType(int index) {
    setState(() {
      _hostingTypes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Web Top Navigation Bar
          if (isDesktop) _buildAcmeTopBar(context, isDark),
          
          if (!isDesktop)
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
                                      Text(
                                        _selectedIndex == 0 ? 'Add Domain Registrars Configuration' : 'Add Hosting Types Configuration',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // Add Option Section
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                              onSubmitted: (_) => _selectedIndex == 0 ? _addDomainRegistrar() : _addHostingType(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton(
                                        onPressed: _selectedIndex == 0 ? _addDomainRegistrar : _addHostingType,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF6366F1),
                                          side: const BorderSide(color: Color(0xFFC7D2FE), style: BorderStyle.solid), // Dashed border is hard in standard OutlinedButton, using light color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        ),
                                        child: const Text('Add'),
                                      ),
                                      const Spacer(),
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
                                              _selectedIndex == 0 ? 'Configured Add Domain Registrars' : 'Configured Add Hosting Types',
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
                                              '${_selectedIndex == 0 ? _domainRegistrars.length : _hostingTypes.length} Options',
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
                                      _buildConfiguredList(isDark),
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
    );
  }

  Widget _buildConfiguredList(bool isDark) {
    final list = _selectedIndex == 0 ? _domainRegistrars : _hostingTypes;

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
      children: list.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
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
              Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => _selectedIndex == 0 ? _removeDomainRegistrar(index) : _removeHostingType(index),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, int index, bool isDark) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryDark.withOpacity(0.1) : AppColors.primaryLight.withOpacity(0.1))
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
