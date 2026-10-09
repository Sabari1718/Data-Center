class DomainModel {
  final String id;
  final String domainName;
  final String registrar;
  final String status; // 'active', 'expiring_soon', 'expired', 'transferring'
  final DateTime expiryDate;
  final DateTime registrationDate;
  final bool autoRenew;
  final List<String> nameservers;
  final bool dnsSec;
  final bool privacyProtection;

  const DomainModel({
    required this.id,
    required this.domainName,
    required this.registrar,
    required this.status,
    required this.expiryDate,
    required this.registrationDate,
    required this.autoRenew,
    this.nameservers = const [],
    this.dnsSec = true,
    this.privacyProtection = true,
  });

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as String? ?? '',
      domainName: json['domainName'] as String? ?? '',
      registrar: json['registrar'] as String? ?? 'CloudFlare Registrar',
      status: json['status'] as String? ?? 'active',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      registrationDate: json['registrationDate'] != null
          ? DateTime.tryParse(json['registrationDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      autoRenew: json['autoRenew'] as bool? ?? true,
      nameservers: (json['nameservers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dnsSec: json['dnsSec'] as bool? ?? true,
      privacyProtection: json['privacyProtection'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domainName': domainName,
      'registrar': registrar,
      'status': status,
      'expiryDate': expiryDate.toIso8601String(),
      'registrationDate': registrationDate.toIso8601String(),
      'autoRenew': autoRenew,
      'nameservers': nameservers,
      'dnsSec': dnsSec,
      'privacyProtection': privacyProtection,
    };
  }

  DomainModel copyWith({
    String? id,
    String? domainName,
    String? registrar,
    String? status,
    DateTime? expiryDate,
    DateTime? registrationDate,
    bool? autoRenew,
    List<String>? nameservers,
    bool? dnsSec,
    bool? privacyProtection,
  }) {
    return DomainModel(
      id: id ?? this.id,
      domainName: domainName ?? this.domainName,
      registrar: registrar ?? this.registrar,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      registrationDate: registrationDate ?? this.registrationDate,
      autoRenew: autoRenew ?? this.autoRenew,
      nameservers: nameservers ?? this.nameservers,
      dnsSec: dnsSec ?? this.dnsSec,
      privacyProtection: privacyProtection ?? this.privacyProtection,
    );
  }
}
