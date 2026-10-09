import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/mock_data_store.dart';
import '../../data/models/data_center_model.dart';
import '../../data/models/server_model.dart';
import '../../features/activity/presentation/activity_screen.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/data_center/presentation/data_center_details_screen.dart';
import '../../features/data_center/presentation/data_center_screen.dart';
import '../../features/domains/presentation/domains_screen.dart';
import '../../features/hosting/presentation/hosting_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/servers/presentation/server_details_screen.dart';
import '../../features/servers/presentation/servers_screen.dart';
import '../../features/shell/presentation/main_shell_screen.dart';
import '../../features/system_status/presentation/system_status_screen.dart';
import '../../features/dynamic_field/presentation/dynamic_field_screen.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final isLoggingIn = state.matchedLocation == RouteNames.login;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    // While initial auth status is being loaded from storage
    if (authState.status == AuthStatus.initial) {
      return null;
    }

    if (!isAuthenticated && !isLoggingIn) {
      return RouteNames.login;
    }

    if (isAuthenticated && isLoggingIn) {
      return RouteNames.dashboard;
    }

    return null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: RouteNames.dashboard,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.dataCenterDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final dc = state.extra is DataCenterModel
              ? state.extra as DataCenterModel
              : MockDataStore.initialDataCenters.first;
          return DataCenterDetailsScreen(dataCenter: dc);
        },
      ),
      GoRoute(
        path: RouteNames.serverDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final srv = state.extra is ServerModel
              ? state.extra as ServerModel
              : MockDataStore.initialServers.first;
          return ServerDetailsScreen(server: srv);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.dataCenter,
            builder: (context, state) => const DataCenterScreen(),
          ),
          GoRoute(
            path: RouteNames.servers,
            builder: (context, state) => const ServersScreen(),
          ),
          GoRoute(
            path: RouteNames.hosting,
            builder: (context, state) => const HostingScreen(),
          ),
          GoRoute(
            path: RouteNames.domains,
            builder: (context, state) => const DomainsScreen(),
          ),
          GoRoute(
            path: RouteNames.activity,
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: RouteNames.systemStatus,
            builder: (context, state) => const SystemStatusScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.dynamicField,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tabIndex = state.uri.queryParameters['tab'] ?? '0';
          return DynamicFieldScreen(initialTab: int.tryParse(tabIndex) ?? 0);
        },
      ),
    ],
  );
});
