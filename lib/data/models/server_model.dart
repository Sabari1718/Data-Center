class ServerModel {
  final String id;
  final String name;
  final String hostname;
  final String ipAddress;
  final String ipv6Address;
  final String dataCenterId;
  final String dataCenterName;
  final String location;
  final String status; // 'running', 'warning', 'stopped', 'maintenance'
  final String os;
  final double cpuUsagePercent;
  final int cpuCores;
  final String cpuModel;
  final double ramUsagePercent;
  final double ramTotalGb;
  final double ramUsedGb;
  final double storageUsagePercent;
  final double storageTotalGb;
  final double storageUsedGb;
  final double networkUsageMbps;
  final double networkInMbps;
  final double networkOutMbps;
  final int uptimeSeconds;
  final String healthStatus; // 'healthy', 'degraded', 'critical'
  final List<String> tags;

  const ServerModel({
    required this.id,
    required this.name,
    required this.hostname,
    required this.ipAddress,
    required this.ipv6Address,
    required this.dataCenterId,
    required this.dataCenterName,
    required this.location,
    required this.status,
    required this.os,
    required this.cpuUsagePercent,
    required this.cpuCores,
    required this.cpuModel,
    required this.ramUsagePercent,
    required this.ramTotalGb,
    required this.ramUsedGb,
    required this.storageUsagePercent,
    required this.storageTotalGb,
    required this.storageUsedGb,
    required this.networkUsageMbps,
    required this.networkInMbps,
    required this.networkOutMbps,
    required this.uptimeSeconds,
    required this.healthStatus,
    this.tags = const [],
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hostname: json['hostname'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      ipv6Address: json['ipv6Address'] as String? ?? '',
      dataCenterId: json['dataCenterId'] as String? ?? '',
      dataCenterName: json['dataCenterName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'running',
      os: json['os'] as String? ?? 'Ubuntu 22.04 LTS',
      cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble() ?? 0.0,
      cpuCores: json['cpuCores'] as int? ?? 4,
      cpuModel: json['cpuModel'] as String? ?? 'AMD EPYC 7763',
      ramUsagePercent: (json['ramUsagePercent'] as num?)?.toDouble() ?? 0.0,
      ramTotalGb: (json['ramTotalGb'] as num?)?.toDouble() ?? 16.0,
      ramUsedGb: (json['ramUsedGb'] as num?)?.toDouble() ?? 0.0,
      storageUsagePercent: (json['storageUsagePercent'] as num?)?.toDouble() ?? 0.0,
      storageTotalGb: (json['storageTotalGb'] as num?)?.toDouble() ?? 500.0,
      storageUsedGb: (json['storageUsedGb'] as num?)?.toDouble() ?? 0.0,
      networkUsageMbps: (json['networkUsageMbps'] as num?)?.toDouble() ?? 0.0,
      networkInMbps: (json['networkInMbps'] as num?)?.toDouble() ?? 0.0,
      networkOutMbps: (json['networkOutMbps'] as num?)?.toDouble() ?? 0.0,
      uptimeSeconds: json['uptimeSeconds'] as int? ?? 0,
      healthStatus: json['healthStatus'] as String? ?? 'healthy',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostname': hostname,
      'ipAddress': ipAddress,
      'ipv6Address': ipv6Address,
      'dataCenterId': dataCenterId,
      'dataCenterName': dataCenterName,
      'location': location,
      'status': status,
      'os': os,
      'cpuUsagePercent': cpuUsagePercent,
      'cpuCores': cpuCores,
      'cpuModel': cpuModel,
      'ramUsagePercent': ramUsagePercent,
      'ramTotalGb': ramTotalGb,
      'ramUsedGb': ramUsedGb,
      'storageUsagePercent': storageUsagePercent,
      'storageTotalGb': storageTotalGb,
      'storageUsedGb': storageUsedGb,
      'networkUsageMbps': networkUsageMbps,
      'networkInMbps': networkInMbps,
      'networkOutMbps': networkOutMbps,
      'uptimeSeconds': uptimeSeconds,
      'healthStatus': healthStatus,
      'tags': tags,
    };
  }

  ServerModel copyWith({
    String? id,
    String? name,
    String? hostname,
    String? ipAddress,
    String? ipv6Address,
    String? dataCenterId,
    String? dataCenterName,
    String? location,
    String? status,
    String? os,
    double? cpuUsagePercent,
    int? cpuCores,
    String? cpuModel,
    double? ramUsagePercent,
    double? ramTotalGb,
    double? ramUsedGb,
    double? storageUsagePercent,
    double? storageTotalGb,
    double? storageUsedGb,
    double? networkUsageMbps,
    double? networkInMbps,
    double? networkOutMbps,
    int? uptimeSeconds,
    String? healthStatus,
    List<String>? tags,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostname: hostname ?? this.hostname,
      ipAddress: ipAddress ?? this.ipAddress,
      ipv6Address: ipv6Address ?? this.ipv6Address,
      dataCenterId: dataCenterId ?? this.dataCenterId,
      dataCenterName: dataCenterName ?? this.dataCenterName,
      location: location ?? this.location,
      status: status ?? this.status,
      os: os ?? this.os,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      cpuCores: cpuCores ?? this.cpuCores,
      cpuModel: cpuModel ?? this.cpuModel,
      ramUsagePercent: ramUsagePercent ?? this.ramUsagePercent,
      ramTotalGb: ramTotalGb ?? this.ramTotalGb,
      ramUsedGb: ramUsedGb ?? this.ramUsedGb,
      storageUsagePercent: storageUsagePercent ?? this.storageUsagePercent,
      storageTotalGb: storageTotalGb ?? this.storageTotalGb,
      storageUsedGb: storageUsedGb ?? this.storageUsedGb,
      networkUsageMbps: networkUsageMbps ?? this.networkUsageMbps,
      networkInMbps: networkInMbps ?? this.networkInMbps,
      networkOutMbps: networkOutMbps ?? this.networkOutMbps,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      healthStatus: healthStatus ?? this.healthStatus,
      tags: tags ?? this.tags,
    );
  }
}
