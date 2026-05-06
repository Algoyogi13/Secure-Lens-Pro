class AdminMetrics {
  final int totalUsers;
  final int highRiskUsers;
  final int recentThreats;
  final int averageCyberScore;
  final List<dynamic> trend;

  AdminMetrics({
    required this.totalUsers,
    required this.highRiskUsers,
    required this.recentThreats,
    required this.averageCyberScore,
    required this.trend,
  });

  factory AdminMetrics.fromJson(Map<String, dynamic> json) {
    return AdminMetrics(
      totalUsers: json['total_users'] ?? 0,
      highRiskUsers: json['high_risk_users'] ?? 0,
      recentThreats: json['recent_threats'] ?? 0,
      averageCyberScore: json['average_cyber_score'] ?? 0,
      trend: json['trend'] ?? [],
    );
  }
}
