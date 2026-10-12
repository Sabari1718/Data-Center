class ServerModel {
  final String id;
  final String name;
  final String hostname;
  final String ipAddress;
  final String ipv6Address;
  final String dataCenterId;
  final String dataCenterName;
  final String location;
  final String status; // 'running', 'warning', 'stopped', 'maintenance', 'Active'
  final String serverType;
  final String os;
  final double cpuUsagePercent;
  final int cpuCores;
  final int threadCount;
  final String cpuModel;
  final String? macAddress;
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

  // Environment & Power/Cooling configuration properties
  final String? upsCapacity;
  final String? powerConsumption;
  final String? generatorBackup;
  final String? coolingType;
  final String? rackTemperature;
  final String? pduDetails;
  final bool hasRedundancy;

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
    this.serverType = 'Rack Server',
    required this.os,
    required this.cpuUsagePercent,
    required this.cpuCores,
    this.threadCount = 0,
    required this.cpuModel,
    this.macAddress,
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
    this.upsCapacity,
    this.powerConsumption,
    this.generatorBackup,
    this.coolingType,
    this.rackTemperature,
    this.pduDetails,
    this.hasRedundancy = false,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id']?.toString() ?? '';
    final nameVal = json['server_name'] as String? ?? json['name'] as String? ?? 'Server';
    final dcIdVal = json['data_center_id']?.toString() ?? json['dataCenterId']?.toString() ?? '';
    final dcNameVal = json['data_center_name'] as String? ?? json['dataCenterName'] as String? ?? '';
    final statusVal = json['server_status'] as String? ?? json['status'] as String? ?? 'Active';
    final processor = json['processor_name'] as String? ?? json['cpuModel'] as String? ?? 'AMD EPYC 7763';
    final cores = (json['cpu_cores'] as num?)?.toInt() ?? (json['cpuCores'] as num?)?.toInt() ?? 4;
    final threads = (json['thread_count'] as num?)?.toInt() ?? (json['threadCount'] as num?)?.toInt() ?? 0;
    final mac = json['mac_address'] as String? ?? json['macAddress'] as String?;
    final sType = json['server_type'] as String? ?? json['serverType'] as String? ?? 'Rack Server';
    final host = json['hostname'] as String? ?? nameVal;
    final ip = json['ipAddress'] as String? ?? (mac != null && mac.contains('.') ? mac : '10.0.0.1');

    return ServerModel(
      id: idVal,
      name: nameVal,
      hostname: host,
      ipAddress: ip,
      ipv6Address: json['ipv6Address'] as String? ?? '',
      dataCenterId: dcIdVal,
      dataCenterName: dcNameVal,
      location: json['location'] as String? ?? (dcNameVal.isNotEmpty ? dcNameVal : 'India'),
      status: statusVal,
      serverType: sType,
      os: json['os'] as String? ?? 'Ubuntu 22.04 LTS',
      cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble() ?? 45.0,
      cpuCores: cores,
      threadCount: threads,
      cpuModel: processor,
      macAddress: mac,
      ramUsagePercent: (json['ramUsagePercent'] as num?)?.toDouble() ?? 32.0,
      ramTotalGb: (json['ramTotalGb'] as num?)?.toDouble() ?? 64.0,
      ramUsedGb: (json['ramUsedGb'] as num?)?.toDouble() ?? 20.48,
      storageUsagePercent: (json['storageUsagePercent'] as num?)?.toDouble() ?? 55.0,
      storageTotalGb: (json['storageTotalGb'] as num?)?.toDouble() ?? 1000.0,
      storageUsedGb: (json['storageUsedGb'] as num?)?.toDouble() ?? 550.0,
      networkUsageMbps: (json['networkUsageMbps'] as num?)?.toDouble() ?? 120.0,
      networkInMbps: (json['networkInMbps'] as num?)?.toDouble() ?? 65.0,
      networkOutMbps: (json['networkOutMbps'] as num?)?.toDouble() ?? 55.0,
      uptimeSeconds: json['uptimeSeconds'] as int? ?? 86400,
      healthStatus: json['healthStatus'] as String? ?? 'healthy',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      upsCapacity: json['upsCapacity'] as String?,
      powerConsumption: json['powerConsumption'] as String? ?? json['consumption'] as String?,
      generatorBackup: json['generatorBackup'] as String? ?? json['generator'] as String?,
      coolingType: json['coolingType'] as String?,
      rackTemperature: json['rackTemperature'] as String? ?? json['temperature'] as String?,
      pduDetails: json['pduDetails'] as String? ?? json['pdu'] as String?,
      hasRedundancy: json['hasRedundancy'] as bool? ?? json['redundancy'] as bool? ?? false,
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
      'serverType': serverType,
      'os': os,
      'cpuUsagePercent': cpuUsagePercent,
      'cpuCores': cpuCores,
      'threadCount': threadCount,
      'cpuModel': cpuModel,
      'macAddress': macAddress,
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
      'upsCapacity': upsCapacity,
      'powerConsumption': powerConsumption,
      'generatorBackup': generatorBackup,
      'coolingType': coolingType,
      'rackTemperature': rackTemperature,
      'pduDetails': pduDetails,
      'hasRedundancy': hasRedundancy,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'data_center_id': dataCenterId.isNotEmpty
          ? (int.tryParse(dataCenterId) ?? dataCenterId)
          : '',
      'server_name': name,
      'server_type': serverType,
      'processor_name': cpuModel,
      'cpu_cores': cpuCores,
      'thread_count': threadCount,
      'mac_address': macAddress ?? '',
      'server_status': status,
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
    String? serverType,
    String? os,
    double? cpuUsagePercent,
    int? cpuCores,
    int? threadCount,
    String? cpuModel,
    String? macAddress,
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
    String? upsCapacity,
    String? powerConsumption,
    String? generatorBackup,
    String? coolingType,
    String? rackTemperature,
    String? pduDetails,
    bool? hasRedundancy,
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
      serverType: serverType ?? this.serverType,
      os: os ?? this.os,
      cpuUsagePercent: cpuUsagePercent ?? this.cpuUsagePercent,
      cpuCores: cpuCores ?? this.cpuCores,
      threadCount: threadCount ?? this.threadCount,
      cpuModel: cpuModel ?? this.cpuModel,
      macAddress: macAddress ?? this.macAddress,
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
      upsCapacity: upsCapacity ?? this.upsCapacity,
      powerConsumption: powerConsumption ?? this.powerConsumption,
      generatorBackup: generatorBackup ?? this.generatorBackup,
      coolingType: coolingType ?? this.coolingType,
      rackTemperature: rackTemperature ?? this.rackTemperature,
      pduDetails: pduDetails ?? this.pduDetails,
      hasRedundancy: hasRedundancy ?? this.hasRedundancy,
    );
  }
}

class ServerNetworkConnectionModel {
  final String id;
  final String? dataCenterId;
  final String? dataCenterName;
  final String? serverId;
  final String? serverName;
  final String networkProvider;
  final String networkName;
  final String connectionType;
  final String bandwidth;
  final List<dynamic> ips;

  const ServerNetworkConnectionModel({
    required this.id,
    this.dataCenterId,
    this.dataCenterName,
    this.serverId,
    this.serverName,
    required this.networkProvider,
    required this.networkName,
    required this.connectionType,
    required this.bandwidth,
    this.ips = const [],
  });

  factory ServerNetworkConnectionModel.fromJson(Map<String, dynamic> json) {
    return ServerNetworkConnectionModel(
      id: json['id']?.toString() ?? '',
      dataCenterId: json['data_center_id']?.toString() ?? json['dataCenterId']?.toString(),
      dataCenterName: json['data_center_name'] as String?,
      serverId: json['server_id']?.toString() ?? json['serverId']?.toString(),
      serverName: json['server_name'] as String?,
      networkProvider: json['network_provider'] as String? ?? json['networkProvider'] as String? ?? '',
      networkName: json['network_name'] as String? ?? json['networkName'] as String? ?? '',
      connectionType: json['connection_type'] as String? ?? json['connectionType'] as String? ?? '',
      bandwidth: json['bandwidth'] as String? ?? '',
      ips: json['ips'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      if (dataCenterId != null && dataCenterId!.isNotEmpty)
        'data_center_id': int.tryParse(dataCenterId!) ?? dataCenterId,
      if (serverId != null && serverId!.isNotEmpty)
        'server_id': int.tryParse(serverId!) ?? serverId,
      'network_provider': networkProvider,
      'network_name': networkName,
      'connection_type': connectionType,
      'bandwidth': bandwidth,
      'ips': ips,
    };
  }
}
