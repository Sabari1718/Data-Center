class ActivityLogModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'server', 'security', 'domain', 'hosting', 'datacenter'
  final String severity; // 'info', 'warning', 'error', 'success'
  final String actorName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.actorName,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'server',
      severity: json['severity'] as String? ?? 'info',
      actorName: json['actorName'] as String? ?? 'System',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'actorName': actorName,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
