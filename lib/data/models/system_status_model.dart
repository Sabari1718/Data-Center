class SystemStatusModel {
  final String id;
  final String name;
  final String category; // 'api', 'server', 'database', 'hosting', 'network'
  final String status; // 'online', 'warning', 'offline'
  final int latencyMs;
  final double uptimePercentage;
  final DateTime lastChecked;
  final String? incidentNote;

  const SystemStatusModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.latencyMs,
    required this.uptimePercentage,
    required this.lastChecked,
    this.incidentNote,
  });

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    return SystemStatusModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'api',
      status: json['status'] as String? ?? 'online',
      latencyMs: json['latencyMs'] as int? ?? 24,
      uptimePercentage: (json['uptimePercentage'] as num?)?.toDouble() ?? 99.99,
      lastChecked: json['lastChecked'] != null
          ? DateTime.tryParse(json['lastChecked'] as String) ?? DateTime.now()
          : DateTime.now(),
      incidentNote: json['incidentNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'latencyMs': latencyMs,
      'uptimePercentage': uptimePercentage,
      'lastChecked': lastChecked.toIso8601String(),
      'incidentNote': incidentNote,
    };
  }

  SystemStatusModel copyWith({
    String? id,
    String? name,
    String? category,
    String? status,
    int? latencyMs,
    double? uptimePercentage,
    DateTime? lastChecked,
    String? incidentNote,
  }) {
    return SystemStatusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      latencyMs: latencyMs ?? this.latencyMs,
      uptimePercentage: uptimePercentage ?? this.uptimePercentage,
      lastChecked: lastChecked ?? this.lastChecked,
      incidentNote: incidentNote ?? this.incidentNote,
    );
  }
}
