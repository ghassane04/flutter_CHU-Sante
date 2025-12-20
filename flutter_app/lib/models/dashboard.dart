class DashboardStats {
  final int totalPatients;
  final int sejoursEnCours;
  final int totalActes;
  final double revenusTotal;
  final double revenusAnnee;
  final double revenusMois;

  DashboardStats({
    required this.totalPatients,
    required this.sejoursEnCours,
    required this.totalActes,
    required this.revenusTotal,
    required this.revenusAnnee,
    required this.revenusMois,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPatients: json['totalPatients'] ?? 0,
      sejoursEnCours: json['sejoursEnCours'] ?? 0,
      totalActes: json['totalActes'] ?? 0,
      revenusTotal: (json['revenusTotal'] ?? 0).toDouble(),
      revenusAnnee: (json['revenusAnnee'] ?? 0).toDouble(),
      revenusMois: (json['revenusMois'] ?? 0).toDouble(),
    );
  }
}

class ActesByTypeStats {
  final String type;
  final int count;
  final double totalTarif;

  ActesByTypeStats({
    required this.type,
    required this.count,
    required this.totalTarif,
  });

  factory ActesByTypeStats.fromJson(Map<String, dynamic> json) {
    return ActesByTypeStats(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      totalTarif: (json['totalTarif'] ?? 0).toDouble(),
    );
  }
}

class RevenusByMonthStats {
  final String month;
  final double amount;

  RevenusByMonthStats({
    required this.month,
    required this.amount,
  });

  factory RevenusByMonthStats.fromJson(Map<String, dynamic> json) {
    return RevenusByMonthStats(
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class SejoursByServiceStats {
  final String serviceName;
  final int count;

  SejoursByServiceStats({
    required this.serviceName,
    required this.count,
  });

  factory SejoursByServiceStats.fromJson(Map<String, dynamic> json) {
    return SejoursByServiceStats(
      serviceName: json['serviceName'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
