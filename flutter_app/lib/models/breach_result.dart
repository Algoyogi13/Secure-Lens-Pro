class BreachResult {
  final String identifier;
  final String status;
  final int breachCount;
  final String recommendation;

  BreachResult({
    required this.identifier,
    required this.status,
    required this.breachCount,
    required this.recommendation,
  });

  factory BreachResult.fromJson(Map<String, dynamic> json) {
    return BreachResult(
      identifier: json['identifier'] ?? '',
      status: json['status'] ?? '',
      breachCount: json['breach_count'] ?? 0,
      recommendation: json['recommendation'] ?? '',
    );
  }
}
