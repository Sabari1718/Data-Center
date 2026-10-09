import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RouteNames.dashboard)) return 0;
    if (location.startsWith(RouteNames.dataCenter)) return 1;
    if (location.startsWith(RouteNames.servers)) return 2;
    if (location.startsWith(RouteNames.domains)) return 3;
    if (location.startsWith(RouteNames.hosting)) return 4;
    if (location.startsWith(RouteNames.dynamicField)) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
        break;
      case 1:
        context.go(RouteNames.dataCenter);
        break;
      case 2:
        context.go(RouteNames.servers);
        break;
      case 3:
        context.go(RouteNames.domains);
        break;
      case 4:
        context.go(RouteNames.hosting);
        break;
      case 5:
        _showDynamicFieldMenu(context);
        break;
    }
  }

  void _showDynamicFieldMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF6366F1)),
                title: const Text('Add Domain Registrars', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('${RouteNames.dynamicField}?tab=0');
                },
              ),
              ListTile(
                leading: const Icon(Icons.dns, color: Color(0xFF6366F1)),
                title: const Text('Add Hosting Types', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('${RouteNames.dynamicField}?tab=1');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    return Scaffold(
      body: child,
      bottomNavigationBar: isDesktop
          ? null
          : AppBottomNavigation(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(index, context),
            ),
    );
  }
}
