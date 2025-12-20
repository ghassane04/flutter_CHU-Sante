class InvestmentStats {
  final double budgetTotal;
  final double roiTotal;
  final int projetsActifs;

  InvestmentStats({
    required this.budgetTotal,
    required this.roiTotal,
    required this.projetsActifs,
  });

  factory InvestmentStats.fromJson(Map<String, dynamic> json) {
    return InvestmentStats(
      budgetTotal: (json['budgetTotal'] ?? 0).toDouble(),
      roiTotal: (json['roiTotal'] ?? 0).toDouble(),
      projetsActifs: json['projetsActifs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budgetTotal': budgetTotal,
      'roiTotal': roiTotal,
      'projetsActifs': projetsActifs,
    };
  }
}
