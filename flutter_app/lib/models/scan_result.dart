class ScanResult {
  final String type;
  final String riskLevel;
  final List<dynamic> matchedSignals;
  final String summary;

  ScanResult({
    required this.type,
    required this.riskLevel,
    required this.matchedSignals,
    required this.summary,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      type: json['type'] ?? '',
      riskLevel: json['risk_level'] ?? '',
      matchedSignals: json['matched_signals'] ?? [],
      summary: json['summary'] ?? '',
    );
  }
}
