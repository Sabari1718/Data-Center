class DomainModel {
  final String id;
  final String? domainId;
  final String domainName;
  final String registrar;
  final String domainService;
  final int? extensionId;
  final String? customExtension;
  final DateTime? purchaseDate;
  final int durationYears;
  final double cost;
  final bool renewalWhatsapp;
  final bool renewalEmail;
  final bool renewalMessage;
  final String? extension;
  final String fullDomain;
  final String status; // 'active', 'expiring_soon', 'expired', 'transferring'
  final DateTime expiryDate;
  final DateTime registrationDate;
  final bool autoRenew;
  final List<String> nameservers;
  final bool dnsSec;
  final bool privacyProtection;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DomainModel({
    required this.id,
    this.domainId,
    required this.domainName,
    required this.registrar,
    this.domainService = 'godaddy',
    this.extensionId,
    this.customExtension,
    this.purchaseDate,
    this.durationYears = 1,
    this.cost = 0.0,
    this.renewalWhatsapp = false,
    this.renewalEmail = false,
    this.renewalMessage = false,
    this.extension,
    this.fullDomain = '',
    required this.status,
    required this.expiryDate,
    required this.registrationDate,
    required this.autoRenew,
    this.nameservers = const [],
    this.dnsSec = true,
    this.privacyProtection = true,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => fullDomain.isNotEmpty
      ? fullDomain
      : (extension != null && extension!.isNotEmpty ? '$domainName$extension' : domainName);

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    final domainName = json['domain_name'] as String? ?? json['domainName'] as String? ?? '';
    final ext = json['extension'] as String?;
    final full = json['full_domain'] as String? ?? (ext != null ? '$domainName$ext' : domainName);
    final reg = json['domain_service'] as String? ?? json['registrar'] as String? ?? 'godaddy';
    final pDate = json['purchase_date'] != null
        ? DateTime.tryParse(json['purchase_date'].toString())
        : (json['registrationDate'] != null ? DateTime.tryParse(json['registrationDate'].toString()) : null);
    final durYears = json['duration_years'] is int
        ? json['duration_years'] as int
        : (int.tryParse(json['duration_years']?.toString() ?? '1') ?? 1);
    final expDate = json['expiryDate'] != null
        ? DateTime.tryParse(json['expiryDate'].toString())
        : (pDate != null
            ? pDate.add(Duration(days: 365 * durYears))
            : DateTime.now().add(const Duration(days: 365)));

    return DomainModel(
      id: json['id']?.toString() ?? '',
      domainId: json['domain_id']?.toString(),
      domainName: domainName,
      registrar: reg,
      domainService: reg,
      extensionId: json['extension_id'] is int
          ? json['extension_id'] as int
          : int.tryParse(json['extension_id']?.toString() ?? ''),
      customExtension: json['custom_extension'] as String?,
      purchaseDate: pDate,
      durationYears: durYears,
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      renewalWhatsapp: json['renewal_whatsapp'] == 1 || json['renewal_whatsapp'] == true,
      renewalEmail: json['renewal_email'] == 1 || json['renewal_email'] == true,
      renewalMessage: json['renewal_message'] == 1 || json['renewal_message'] == true,
      extension: ext,
      fullDomain: full,
      status: json['status']?.toString() == '1' || json['status'] == null || json['status'] == 'Active'
          ? 'active'
          : json['status'].toString(),
      expiryDate: expDate ?? DateTime.now().add(const Duration(days: 365)),
      registrationDate: pDate ?? (json['registrationDate'] != null
          ? DateTime.tryParse(json['registrationDate'].toString()) ?? DateTime.now()
          : DateTime.now()),
      autoRenew: json['autoRenew'] as bool? ?? (json['renewal_whatsapp'] == 1 || json['renewal_whatsapp'] == true),
      nameservers: (json['nameservers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dnsSec: json['dnsSec'] as bool? ?? true,
      privacyProtection: json['privacyProtection'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain_id': domainId,
      'domain_name': domainName,
      'domainName': domainName,
      'registrar': registrar,
      'domain_service': domainService,
      'extension_id': extensionId,
      'custom_extension': customExtension,
      'purchase_date': purchaseDate?.toIso8601String(),
      'duration_years': durationYears,
      'cost': cost,
      'renewal_whatsapp': renewalWhatsapp ? 1 : 0,
      'renewal_email': renewalEmail ? 1 : 0,
      'renewal_message': renewalMessage ? 1 : 0,
      'extension': extension,
      'full_domain': fullDomain,
      'status': status,
      'expiryDate': expiryDate.toIso8601String(),
      'registrationDate': registrationDate.toIso8601String(),
      'autoRenew': autoRenew,
      'nameservers': nameservers,
      'dnsSec': dnsSec,
      'privacyProtection': privacyProtection,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DomainModel copyWith({
    String? id,
    String? domainId,
    String? domainName,
    String? registrar,
    String? domainService,
    int? extensionId,
    String? customExtension,
    DateTime? purchaseDate,
    int? durationYears,
    double? cost,
    bool? renewalWhatsapp,
    bool? renewalEmail,
    bool? renewalMessage,
    String? extension,
    String? fullDomain,
    String? status,
    DateTime? expiryDate,
    DateTime? registrationDate,
    bool? autoRenew,
    List<String>? nameservers,
    bool? dnsSec,
    bool? privacyProtection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DomainModel(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      domainName: domainName ?? this.domainName,
      registrar: registrar ?? this.registrar,
      domainService: domainService ?? this.domainService,
      extensionId: extensionId ?? this.extensionId,
      customExtension: customExtension ?? this.customExtension,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      durationYears: durationYears ?? this.durationYears,
      cost: cost ?? this.cost,
      renewalWhatsapp: renewalWhatsapp ?? this.renewalWhatsapp,
      renewalEmail: renewalEmail ?? this.renewalEmail,
      renewalMessage: renewalMessage ?? this.renewalMessage,
      extension: extension ?? this.extension,
      fullDomain: fullDomain ?? this.fullDomain,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      registrationDate: registrationDate ?? this.registrationDate,
      autoRenew: autoRenew ?? this.autoRenew,
      nameservers: nameservers ?? this.nameservers,
      dnsSec: dnsSec ?? this.dnsSec,
      privacyProtection: privacyProtection ?? this.privacyProtection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DomainExtensionModel {
  final int id;
  final String extension;
  final int status;

  const DomainExtensionModel({
    required this.id,
    required this.extension,
    this.status = 1,
  });

  factory DomainExtensionModel.fromJson(Map<String, dynamic> json) {
    return DomainExtensionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      extension: json['extension'] as String? ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'extension': extension,
    'status': status,
  };
}

class SubdomainModel {
  final dynamic id;
  final String subdomainId;
  final int? primaryDomainId;
  final String subdomainPrefix;
  final String targetSubdomain;
  final String loginUrl;
  final String domainName;
  final String extension;
  final String primaryDomainName;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubdomainModel({
    required this.id,
    this.subdomainId = '',
    this.primaryDomainId,
    required this.subdomainPrefix,
    required this.targetSubdomain,
    required this.loginUrl,
    this.domainName = '',
    this.extension = '',
    this.primaryDomainName = '',
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
  });

  factory SubdomainModel.fromJson(Map<String, dynamic> json) {
    return SubdomainModel(
      id: json['id'],
      subdomainId: json['subdomain_id']?.toString() ?? '',
      primaryDomainId: json['primary_domain_id'] is int
          ? json['primary_domain_id'] as int
          : int.tryParse(json['primary_domain_id']?.toString() ?? ''),
      subdomainPrefix: json['subdomain_prefix'] as String? ?? '',
      targetSubdomain: json['target_subdomain'] as String? ?? '',
      loginUrl: json['login_url'] as String? ?? '',
      domainName: json['domain_name'] as String? ?? '',
      extension: json['extension'] as String? ?? '',
      primaryDomainName: json['primary_domain_name'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subdomain_id': subdomainId,
    'primary_domain_id': primaryDomainId,
    'subdomain_prefix': subdomainPrefix,
    'target_subdomain': targetSubdomain,
    'login_url': loginUrl,
    'domain_name': domainName,
    'extension': extension,
    'primary_domain_name': primaryDomainName,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  SubdomainModel copyWith({
    dynamic id,
    String? subdomainId,
    int? primaryDomainId,
    String? subdomainPrefix,
    String? targetSubdomain,
    String? loginUrl,
    String? domainName,
    String? extension,
    String? primaryDomainName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubdomainModel(
      id: id ?? this.id,
      subdomainId: subdomainId ?? this.subdomainId,
      primaryDomainId: primaryDomainId ?? this.primaryDomainId,
      subdomainPrefix: subdomainPrefix ?? this.subdomainPrefix,
      targetSubdomain: targetSubdomain ?? this.targetSubdomain,
      loginUrl: loginUrl ?? this.loginUrl,
      domainName: domainName ?? this.domainName,
      extension: extension ?? this.extension,
      primaryDomainName: primaryDomainName ?? this.primaryDomainName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
