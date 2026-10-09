import 'activity_log_model.dart';

class DashboardModel {
  final int totalServers;
  final int activeServers;
  final int warningServers;
  final int offlineServers;
  final int dataCentersCount;
  final double hostingUsagePercent;
  final int totalDomains;
  final double systemHealthScore;
  final List<ActivityLogModel> recentActivity;
  final Map<String, dynamic> resourceUsage;

  const DashboardModel({
    required this.totalServers,
    required this.activeServers,
    required this.warningServers,
    required this.offlineServers,
    required this.dataCentersCount,
    required this.hostingUsagePercent,
    required this.totalDomains,
    required this.systemHealthScore,
    required this.recentActivity,
    this.resourceUsage = const {},
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalServers: json['totalServers'] as int? ?? 0,
      activeServers: json['activeServers'] as int? ?? 0,
      warningServers: json['warningServers'] as int? ?? 0,
      offlineServers: json['offlineServers'] as int? ?? 0,
      dataCentersCount: json['dataCentersCount'] as int? ?? 0,
      hostingUsagePercent: (json['hostingUsagePercent'] as num?)?.toDouble() ?? 0.0,
      totalDomains: json['totalDomains'] as int? ?? 0,
      systemHealthScore: (json['systemHealthScore'] as num?)?.toDouble() ?? 100.0,
      recentActivity: (json['recentActivity'] as List<dynamic>?)
              ?.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      resourceUsage: json['resourceUsage'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalServers': totalServers,
      'activeServers': activeServers,
      'warningServers': warningServers,
      'offlineServers': offlineServers,
      'dataCentersCount': dataCentersCount,
      'hostingUsagePercent': hostingUsagePercent,
      'totalDomains': totalDomains,
      'systemHealthScore': systemHealthScore,
      'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
      'resourceUsage': resourceUsage,
    };
  }
}
