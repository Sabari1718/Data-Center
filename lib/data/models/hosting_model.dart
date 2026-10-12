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

class HostingNewModel {
  final dynamic id;
  final String hostingId;
  final String serviceProvider;
  final String hostingType;
  final String ipAddress;
  final String status;
  final String controlPanel;
  final String hostingName;
  final String username;
  final String password;
  final String customerId;
  final String nameserver1;
  final String nameserver2;
  final String storageHarddisk;
  final String bandwidthLimit;
  final int addonDomainLimit;
  final int subdomainLimit;
  final int emailAccountsLimit;
  final int ftpAccountsLimit;
  final int mysqlDatabaseLimit;
  final int inodeLimit;
  final String webServer;
  final String phpVersion;
  final String databaseType;
  final String sslCertificate;
  final int sshAccess;
  final int backupEnabled;
  final String createdDate;
  final String expiryDate;
  final String renewalDate;
  final String? extension;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HostingNewModel({
    required this.id,
    this.hostingId = '',
    this.serviceProvider = '',
    this.hostingType = '',
    this.ipAddress = '',
    this.status = 'Pending',
    this.controlPanel = '',
    this.hostingName = '',
    this.username = '',
    this.password = '',
    this.customerId = '',
    this.nameserver1 = '',
    this.nameserver2 = '',
    this.storageHarddisk = '',
    this.bandwidthLimit = '',
    this.addonDomainLimit = 0,
    this.subdomainLimit = 0,
    this.emailAccountsLimit = 0,
    this.ftpAccountsLimit = 0,
    this.mysqlDatabaseLimit = 0,
    this.inodeLimit = 0,
    this.webServer = '',
    this.phpVersion = '',
    this.databaseType = '',
    this.sslCertificate = '',
    this.sshAccess = 0,
    this.backupEnabled = 0,
    this.createdDate = '',
    this.expiryDate = '',
    this.renewalDate = '',
    this.extension,
    this.createdAt,
    this.updatedAt,
  });

  factory HostingNewModel.fromJson(Map<String, dynamic> json) {
    return HostingNewModel(
      id: json['id'],
      hostingId: json['hosting_id']?.toString() ?? '',
      serviceProvider: json['service_provider']?.toString() ?? '',
      hostingType: json['hosting_type']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      controlPanel: json['control_panel']?.toString() ?? '',
      hostingName: json['hosting_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      nameserver1: json['nameserver_1']?.toString() ?? '',
      nameserver2: json['nameserver_2']?.toString() ?? '',
      storageHarddisk: json['storage_harddisk']?.toString() ?? '',
      bandwidthLimit: json['bandwidth_limit']?.toString() ?? '',
      addonDomainLimit: _parseInt(json['addon_domain_limit']),
      subdomainLimit: _parseInt(json['subdomain_limit']),
      emailAccountsLimit: _parseInt(json['email_accounts_limit']),
      ftpAccountsLimit: _parseInt(json['ftp_accounts_limit']),
      mysqlDatabaseLimit: _parseInt(json['mysql_database_limit']),
      inodeLimit: _parseInt(json['inode_limit']),
      webServer: json['web_server']?.toString() ?? '',
      phpVersion: json['php_version']?.toString() ?? '',
      databaseType: json['database_type']?.toString() ?? '',
      sslCertificate: json['ssl_certificate']?.toString() ?? '',
      sshAccess: _parseInt(json['ssh_access']),
      backupEnabled: _parseInt(json['backup_enabled']),
      createdDate: json['created_date']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
      renewalDate: json['renewal_date']?.toString() ?? '',
      extension: json['extension']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is bool) return val ? 1 : 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'service_provider': serviceProvider,
      'hosting_type': hostingType,
      'ip_address': ipAddress,
      'status': status,
      'control_panel': controlPanel,
      'hosting_name': hostingName,
      'username': username,
      'password': password,
      'customer_id': customerId,
      'nameserver_1': nameserver1,
      'nameserver_2': nameserver2,
      'storage_harddisk': storageHarddisk,
      'bandwidth_limit': bandwidthLimit,
      'addon_domain_limit': addonDomainLimit,
      'subdomain_limit': subdomainLimit,
      'email_accounts_limit': emailAccountsLimit,
      'ftp_accounts_limit': ftpAccountsLimit,
      'mysql_database_limit': mysqlDatabaseLimit,
      'inode_limit': inodeLimit,
      'web_server': webServer,
      'php_version': phpVersion,
      'database_type': databaseType,
      'ssl_certificate': sslCertificate,
      'ssh_access': sshAccess,
      'backup_enabled': backupEnabled,
      'created_date': createdDate,
      'expiry_date': expiryDate,
      'renewal_date': renewalDate,
      if (extension != null) 'extension': extension,
    };
  }

  HostingNewModel copyWith({
    dynamic id,
    String? hostingId,
    String? serviceProvider,
    String? hostingType,
    String? ipAddress,
    String? status,
    String? controlPanel,
    String? hostingName,
    String? username,
    String? password,
    String? customerId,
    String? nameserver1,
    String? nameserver2,
    String? storageHarddisk,
    String? bandwidthLimit,
    int? addonDomainLimit,
    int? subdomainLimit,
    int? emailAccountsLimit,
    int? ftpAccountsLimit,
    int? mysqlDatabaseLimit,
    int? inodeLimit,
    String? webServer,
    String? phpVersion,
    String? databaseType,
    String? sslCertificate,
    int? sshAccess,
    int? backupEnabled,
    String? createdDate,
    String? expiryDate,
    String? renewalDate,
    String? extension,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostingNewModel(
      id: id ?? this.id,
      hostingId: hostingId ?? this.hostingId,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      hostingType: hostingType ?? this.hostingType,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      controlPanel: controlPanel ?? this.controlPanel,
      hostingName: hostingName ?? this.hostingName,
      username: username ?? this.username,
      password: password ?? this.password,
      customerId: customerId ?? this.customerId,
      nameserver1: nameserver1 ?? this.nameserver1,
      nameserver2: nameserver2 ?? this.nameserver2,
      storageHarddisk: storageHarddisk ?? this.storageHarddisk,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
      addonDomainLimit: addonDomainLimit ?? this.addonDomainLimit,
      subdomainLimit: subdomainLimit ?? this.subdomainLimit,
      emailAccountsLimit: emailAccountsLimit ?? this.emailAccountsLimit,
      ftpAccountsLimit: ftpAccountsLimit ?? this.ftpAccountsLimit,
      mysqlDatabaseLimit: mysqlDatabaseLimit ?? this.mysqlDatabaseLimit,
      inodeLimit: inodeLimit ?? this.inodeLimit,
      webServer: webServer ?? this.webServer,
      phpVersion: phpVersion ?? this.phpVersion,
      databaseType: databaseType ?? this.databaseType,
      sslCertificate: sslCertificate ?? this.sslCertificate,
      sshAccess: sshAccess ?? this.sshAccess,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      createdDate: createdDate ?? this.createdDate,
      expiryDate: expiryDate ?? this.expiryDate,
      renewalDate: renewalDate ?? this.renewalDate,
      extension: extension ?? this.extension,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HostingTypeModel {
  final int id;
  final String hostingTypeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HostingTypeModel({
    required this.id,
    required this.hostingTypeName,
    this.createdAt,
    this.updatedAt,
  });

  factory HostingTypeModel.fromJson(Map<String, dynamic> json) {
    return HostingTypeModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      hostingTypeName: json['hosting_type_name']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hosting_type_name': hostingTypeName,
  };
}

class ServerHostingModel {
  final dynamic id;
  final String hostingId;
  final dynamic serverId;
  final String? serverName;
  final String hostingType;
  final String ipAddress;
  final String status;
  final String controlPanel;
  final String hostingName;
  final String username;
  final String password;
  final String customerId;
  final String nameserver1;
  final String nameserver2;
  final String storageHarddisk;
  final String bandwidthLimit;
  final int addonDomainLimit;
  final int subdomainLimit;
  final int emailAccountsLimit;
  final int ftpAccountsLimit;
  final int mysqlDatabaseLimit;
  final int inodeLimit;
  final String webServer;
  final String phpVersion;
  final String databaseType;
  final String sslCertificate;
  final bool sshAccess;
  final bool backupEnabled;
  final String createdDate;
  final String expiryDate;
  final String renewalDate;
  final List<dynamic> domainId;
  final String? domainName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServerHostingModel({
    required this.id,
    this.hostingId = '',
    this.serverId,
    this.serverName,
    this.hostingType = 'sa',
    this.ipAddress = '',
    this.status = 'Active',
    this.controlPanel = 'Plesk',
    this.hostingName = '',
    this.username = '',
    this.password = '',
    this.customerId = '',
    this.nameserver1 = '',
    this.nameserver2 = '',
    this.storageHarddisk = '',
    this.bandwidthLimit = '',
    this.addonDomainLimit = 0,
    this.subdomainLimit = 0,
    this.emailAccountsLimit = 0,
    this.ftpAccountsLimit = 0,
    this.mysqlDatabaseLimit = 0,
    this.inodeLimit = 0,
    this.webServer = 'Nginx',
    this.phpVersion = '',
    this.databaseType = 'MariaDB',
    this.sslCertificate = "Let's Encrypt (Free)",
    this.sshAccess = false,
    this.backupEnabled = false,
    this.createdDate = '',
    this.expiryDate = '',
    this.renewalDate = '',
    this.domainId = const [],
    this.domainName,
    this.createdAt,
    this.updatedAt,
  });

  factory ServerHostingModel.fromJson(Map<String, dynamic> json) {
    return ServerHostingModel(
      id: json['id'],
      hostingId: json['hosting_id']?.toString() ?? '',
      serverId: json['server_id'] ?? json['serverId'],
      serverName: json['server_name']?.toString(),
      hostingType: json['hosting_type']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      controlPanel: json['control_panel']?.toString() ?? '',
      hostingName: json['hosting_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      nameserver1: json['nameserver_1']?.toString() ?? '',
      nameserver2: json['nameserver_2']?.toString() ?? '',
      storageHarddisk: json['storage_harddisk']?.toString() ?? '',
      bandwidthLimit: json['bandwidth_limit']?.toString() ?? '',
      addonDomainLimit: _parseInt(json['addon_domain_limit']),
      subdomainLimit: _parseInt(json['subdomain_limit']),
      emailAccountsLimit: _parseInt(json['email_accounts_limit']),
      ftpAccountsLimit: _parseInt(json['ftp_accounts_limit']),
      mysqlDatabaseLimit: _parseInt(json['mysql_database_limit']),
      inodeLimit: _parseInt(json['inode_limit']),
      webServer: json['web_server']?.toString() ?? '',
      phpVersion: json['php_version']?.toString() ?? '',
      databaseType: json['database_type']?.toString() ?? '',
      sslCertificate: json['ssl_certificate']?.toString() ?? '',
      sshAccess: _parseBool(json['ssh_access']),
      backupEnabled: _parseBool(json['backup_enabled']),
      createdDate: json['created_date']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
      renewalDate: json['renewal_date']?.toString() ?? '',
      domainId: (json['domain_id'] is List) ? (json['domain_id'] as List) : [],
      domainName: json['domain_name']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is bool) return val ? 1 : 0;
    return int.tryParse(val.toString()) ?? 0;
  }

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val != 0;
    final s = val.toString().toLowerCase().trim();
    return s == '1' || s == 'true' || s == 'yes';
  }

  Map<String, dynamic> toJson() {
    return {
      'server_id': serverId is int ? serverId : (int.tryParse(serverId?.toString() ?? '') ?? serverId),
      'hosting_type': hostingType,
      'hosting_name': hostingName,
      'domain_id': domainId,
      'username': username,
      'password': password,
      'customer_id': customerId,
      'nameserver_1': nameserver1,
      'nameserver_2': nameserver2,
      'storage_harddisk': storageHarddisk,
      'bandwidth_limit': bandwidthLimit,
      'addon_domain_limit': addonDomainLimit,
      'subdomain_limit': subdomainLimit,
      'email_accounts_limit': emailAccountsLimit,
      'ftp_accounts_limit': ftpAccountsLimit,
      'mysql_database_limit': mysqlDatabaseLimit,
      'inode_limit': inodeLimit,
      'web_server': webServer,
      'php_version': phpVersion,
      'database_type': databaseType,
      'ssl_certificate': sslCertificate,
      'ssh_access': sshAccess,
      'backup_enabled': backupEnabled,
      'created_date': createdDate,
      'expiry_date': expiryDate,
      'renewal_date': renewalDate,
      'ip_address': ipAddress,
      'status': status,
      'control_panel': controlPanel,
    };
  }

  ServerHostingModel copyWith({
    dynamic id,
    String? hostingId,
    dynamic serverId,
    String? serverName,
    String? hostingType,
    String? ipAddress,
    String? status,
    String? controlPanel,
    String? hostingName,
    String? username,
    String? password,
    String? customerId,
    String? nameserver1,
    String? nameserver2,
    String? storageHarddisk,
    String? bandwidthLimit,
    int? addonDomainLimit,
    int? subdomainLimit,
    int? emailAccountsLimit,
    int? ftpAccountsLimit,
    int? mysqlDatabaseLimit,
    int? inodeLimit,
    String? webServer,
    String? phpVersion,
    String? databaseType,
    String? sslCertificate,
    bool? sshAccess,
    bool? backupEnabled,
    String? createdDate,
    String? expiryDate,
    String? renewalDate,
    List<dynamic>? domainId,
    String? domainName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServerHostingModel(
      id: id ?? this.id,
      hostingId: hostingId ?? this.hostingId,
      serverId: serverId ?? this.serverId,
      serverName: serverName ?? this.serverName,
      hostingType: hostingType ?? this.hostingType,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      controlPanel: controlPanel ?? this.controlPanel,
      hostingName: hostingName ?? this.hostingName,
      username: username ?? this.username,
      password: password ?? this.password,
      customerId: customerId ?? this.customerId,
      nameserver1: nameserver1 ?? this.nameserver1,
      nameserver2: nameserver2 ?? this.nameserver2,
      storageHarddisk: storageHarddisk ?? this.storageHarddisk,
      bandwidthLimit: bandwidthLimit ?? this.bandwidthLimit,
      addonDomainLimit: addonDomainLimit ?? this.addonDomainLimit,
      subdomainLimit: subdomainLimit ?? this.subdomainLimit,
      emailAccountsLimit: emailAccountsLimit ?? this.emailAccountsLimit,
      ftpAccountsLimit: ftpAccountsLimit ?? this.ftpAccountsLimit,
      mysqlDatabaseLimit: mysqlDatabaseLimit ?? this.mysqlDatabaseLimit,
      inodeLimit: inodeLimit ?? this.inodeLimit,
      webServer: webServer ?? this.webServer,
      phpVersion: phpVersion ?? this.phpVersion,
      databaseType: databaseType ?? this.databaseType,
      sslCertificate: sslCertificate ?? this.sslCertificate,
      sshAccess: sshAccess ?? this.sshAccess,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      createdDate: createdDate ?? this.createdDate,
      expiryDate: expiryDate ?? this.expiryDate,
      renewalDate: renewalDate ?? this.renewalDate,
      domainId: domainId ?? this.domainId,
      domainName: domainName ?? this.domainName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HostingDomainMappingModel {
  final dynamic id;
  final dynamic hostingId;
  final dynamic domainId;
  final String mappingStatus;
  final DateTime? mappedAt;
  final String? hostingName;
  final String? domainName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HostingDomainMappingModel({
    required this.id,
    required this.hostingId,
    required this.domainId,
    this.mappingStatus = 'active',
    this.mappedAt,
    this.hostingName,
    this.domainName,
    this.createdAt,
    this.updatedAt,
  });

  factory HostingDomainMappingModel.fromJson(Map<String, dynamic> json) {
    return HostingDomainMappingModel(
      id: json['id'],
      hostingId: json['hosting_id'] ?? json['hostingId'],
      domainId: json['domain_id'] ?? json['domainId'],
      mappingStatus: json['mapping_status']?.toString() ?? 'active',
      mappedAt: json['mapped_at'] != null ? DateTime.tryParse(json['mapped_at'].toString()) : null,
      hostingName: json['hosting_name']?.toString(),
      domainName: json['domain_name']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hosting_id': hostingId,
    'domain_id': domainId,
    'mapping_status': mappingStatus,
  };
}
