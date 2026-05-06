class CyberScoreModel {
  final int cyberScore;
  final String level;
  final Map<String, dynamic> factors;

  CyberScoreModel({
    required this.cyberScore,
    required this.level,
    required this.factors,
  });

  factory CyberScoreModel.fromJson(Map<String, dynamic> json) {
    return CyberScoreModel(
      cyberScore: json['cyber_score'] ?? 0,
      level: json['level'] ?? '',
      factors: json['factors'] ?? {},
    );
  }
}
