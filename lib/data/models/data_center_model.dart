class DataCenterModel {
  final String id;
  final String name;
  final String code;
  final String city;
  final String country;
  final String region;
  final String address;
  final String status; // 'active', 'maintenance', 'degraded'
  final double healthScore;
  final int totalServers;
  final int activeServers;
  final int totalRacks;
  final double powerCapacityKva;
  final double coolingEfficiencyPue;
  final String ipPrefix;

  const DataCenterModel({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.country,
    required this.region,
    required this.address,
    required this.status,
    required this.healthScore,
    required this.totalServers,
    required this.activeServers,
    required this.totalRacks,
    required this.powerCapacityKva,
    required this.coolingEfficiencyPue,
    required this.ipPrefix,
  });

  factory DataCenterModel.fromJson(Map<String, dynamic> json) {
    return DataCenterModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      region: json['region'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 100.0,
      totalServers: json['totalServers'] as int? ?? 0,
      activeServers: json['activeServers'] as int? ?? 0,
      totalRacks: json['totalRacks'] as int? ?? 0,
      powerCapacityKva: (json['powerCapacityKva'] as num?)?.toDouble() ?? 0.0,
      coolingEfficiencyPue: (json['coolingEfficiencyPue'] as num?)?.toDouble() ?? 1.15,
      ipPrefix: json['ipPrefix'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'country': country,
      'region': region,
      'address': address,
      'status': status,
      'healthScore': healthScore,
      'totalServers': totalServers,
      'activeServers': activeServers,
      'totalRacks': totalRacks,
      'powerCapacityKva': powerCapacityKva,
      'coolingEfficiencyPue': coolingEfficiencyPue,
      'ipPrefix': ipPrefix,
    };
  }

  DataCenterModel copyWith({
    String? id,
    String? name,
    String? code,
    String? city,
    String? country,
    String? region,
    String? address,
    String? status,
    double? healthScore,
    int? totalServers,
    int? activeServers,
    int? totalRacks,
    double? powerCapacityKva,
    double? coolingEfficiencyPue,
    String? ipPrefix,
  }) {
    return DataCenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      city: city ?? this.city,
      country: country ?? this.country,
      region: region ?? this.region,
      address: address ?? this.address,
      status: status ?? this.status,
      healthScore: healthScore ?? this.healthScore,
      totalServers: totalServers ?? this.totalServers,
      activeServers: activeServers ?? this.activeServers,
      totalRacks: totalRacks ?? this.totalRacks,
      powerCapacityKva: powerCapacityKva ?? this.powerCapacityKva,
      coolingEfficiencyPue: coolingEfficiencyPue ?? this.coolingEfficiencyPue,
      ipPrefix: ipPrefix ?? this.ipPrefix,
    );
  }
}
