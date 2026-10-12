class ResolvedLocationModel {
  final String pincode;
  final String cityName;
  final String talukName;
  final String districtName;
  final String stateName;
  final String countryName;

  const ResolvedLocationModel({
    required this.pincode,
    required this.cityName,
    required this.talukName,
    required this.districtName,
    required this.stateName,
    required this.countryName,
  });

  factory ResolvedLocationModel.fromJson(Map<String, dynamic> json) {
    return ResolvedLocationModel(
      pincode: json['pincode']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
      talukName: json['taluk_name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pincode': pincode,
      'city_name': cityName,
      'taluk_name': talukName,
      'district_name': districtName,
      'state_name': stateName,
      'country_name': countryName,
    };
  }
}

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

  // Live Backend specific fields
  final String? locationMethod;
  final String? pincode;
  final String? zipCode;
  final String? latitude;
  final String? longitude;
  final int? activeStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.locationMethod,
    this.pincode,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.activeStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory DataCenterModel.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? '').toString();
    final name = json['data_center_name'] as String? ?? json['name'] as String? ?? 'Data Center $rawId';
    final locationMethod = json['location_method'] as String? ?? 'pincode';
    final pincode = json['pincode'] as String?;
    final zipCode = json['zip_code'] as String?;
    final lat = json['latitude']?.toString();
    final lng = json['longitude']?.toString();
    final activeStatus = json['active_status'] is int
        ? json['active_status'] as int
        : (json['active_status'] == 1 || json['active_status'] == true || json['status'] == 'active' ? 1 : 0);
    final status = (activeStatus == 1 || json['status'] == 'active') ? 'active' : 'maintenance';
    final country = json['country'] as String? ?? 'India';
    final city = json['city'] as String? ?? (pincode != null && pincode.isNotEmpty ? 'PIN: $pincode' : '');
    final address = json['address'] as String? ?? (pincode != null ? 'Pincode $pincode' : '');

    return DataCenterModel(
      id: rawId,
      name: name,
      code: json['code'] as String? ?? 'DC-$rawId',
      city: city,
      country: country,
      region: json['region'] as String? ?? 'Asia Pacific',
      address: address,
      status: status,
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 99.98,
      totalServers: json['totalServers'] as int? ?? 24,
      activeServers: json['activeServers'] as int? ?? 24,
      totalRacks: json['totalRacks'] as int? ?? 6,
      powerCapacityKva: (json['powerCapacityKva'] as num?)?.toDouble() ?? 1200.0,
      coolingEfficiencyPue: (json['coolingEfficiencyPue'] as num?)?.toDouble() ?? 1.14,
      ipPrefix: json['ipPrefix'] as String? ?? '198.51.100.0/24',
      locationMethod: locationMethod,
      pincode: pincode,
      zipCode: zipCode,
      latitude: lat,
      longitude: lng,
      activeStatus: activeStatus,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_center_name': name,
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
      'location_method': locationMethod,
      'pincode': pincode,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'active_status': activeStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'data_center_name': name,
      'active_status': activeStatus ?? (status == 'active' ? 1 : 0),
      'location_method': locationMethod ?? 'pincode',
      'pincode': pincode ?? '',
      'country': country.isNotEmpty ? country : 'India',
      if (zipCode != null && zipCode!.isNotEmpty) 'zip_code': zipCode,
      if (latitude != null && latitude!.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude!.isNotEmpty) 'longitude': longitude,
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
    String? locationMethod,
    String? pincode,
    String? zipCode,
    String? latitude,
    String? longitude,
    int? activeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      locationMethod: locationMethod ?? this.locationMethod,
      pincode: pincode ?? this.pincode,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      activeStatus: activeStatus ?? this.activeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
