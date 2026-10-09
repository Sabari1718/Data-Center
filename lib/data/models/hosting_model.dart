class HostingModel {
  final String id;
  final String serviceName;
  final String planName;
  final String domain;
  final String ipAddress;
  final String status; // 'active', 'suspended', 'pending', 'expired'
  final double storageUsedGb;
  final double storageTotalGb;
  final double bandwidthUsedGb;
  final double bandwidthTotalGb;
  final bool sslActive;
  final String phpVersion;
  final DateTime expiryDate;
  final DateTime createdAt;

  const HostingModel({
    required this.id,
    required this.serviceName,
    required this.planName,
    required this.domain,
    required this.ipAddress,
    required this.status,
    required this.storageUsedGb,
    required this.storageTotalGb,
    required this.bandwidthUsedGb,
    required this.bandwidthTotalGb,
    required this.sslActive,
    required this.phpVersion,
    required this.expiryDate,
    required this.createdAt,
  });

  double get storageUsagePercent =>
      storageTotalGb > 0 ? (storageUsedGb / storageTotalGb) : 0.0;
  double get bandwidthUsagePercent =>
      bandwidthTotalGb > 0 ? (bandwidthUsedGb / bandwidthTotalGb) : 0.0;

  factory HostingModel.fromJson(Map<String, dynamic> json) {
    return HostingModel(
      id: json['id'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      storageUsedGb: (json['storageUsedGb'] as num?)?.toDouble() ?? 0.0,
      storageTotalGb: (json['storageTotalGb'] as num?)?.toDouble() ?? 50.0,
      bandwidthUsedGb: (json['bandwidthUsedGb'] as num?)?.toDouble() ?? 0.0,
      bandwidthTotalGb: (json['bandwidthTotalGb'] as num?)?.toDouble() ?? 500.0,
      sslActive: json['sslActive'] as bool? ?? true,
      phpVersion: json['phpVersion'] as String? ?? '8.3',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String) ??
              DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'planName': planName,
      'domain': domain,
      'ipAddress': ipAddress,
      'status': status,
      'storageUsedGb': storageUsedGb,
      'storageTotalGb': storageTotalGb,
      'bandwidthUsedGb': bandwidthUsedGb,
      'bandwidthTotalGb': bandwidthTotalGb,
      'sslActive': sslActive,
      'phpVersion': phpVersion,
      'expiryDate': expiryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  HostingModel copyWith({
    String? id,
    String? serviceName,
    String? planName,
    String? domain,
    String? ipAddress,
    String? status,
    double? storageUsedGb,
    double? storageTotalGb,
    double? bandwidthUsedGb,
    double? bandwidthTotalGb,
    bool? sslActive,
    String? phpVersion,
    DateTime? expiryDate,
    DateTime? createdAt,
  }) {
    return HostingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      planName: planName ?? this.planName,
      domain: domain ?? this.domain,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      storageUsedGb: storageUsedGb ?? this.storageUsedGb,
      storageTotalGb: storageTotalGb ?? this.storageTotalGb,
      bandwidthUsedGb: bandwidthUsedGb ?? this.bandwidthUsedGb,
      bandwidthTotalGb: bandwidthTotalGb ?? this.bandwidthTotalGb,
      sslActive: sslActive ?? this.sslActive,
      phpVersion: phpVersion ?? this.phpVersion,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
