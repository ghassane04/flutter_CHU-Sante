class Prediction {
  final int? id;
  final String type;
  final String titre;
  final String? description;
  final String periodePrevue;
  final String? donneesHistoriques;
  final String? resultatPrediction;
  final double? confiance;
  final String? methodologie;
  final String? facteursCles;
  final String? recommandations;
  final String? generePar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Prediction({
    this.id,
    required this.type,
    required this.titre,
    this.description,
    required this.periodePrevue,
    this.donneesHistoriques,
    this.resultatPrediction,
    this.confiance,
    this.methodologie,
    this.facteursCles,
    this.recommandations,
    this.generePar,
    this.createdAt,
    this.updatedAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      type: json['type'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'],
      periodePrevue: json['periodePrevue'] ?? '',
      donneesHistoriques: json['donneesHistoriques'],
      resultatPrediction: json['resultatPrediction'],
      confiance: json['confiance']?.toDouble(),
      methodologie: json['methodologie'],
      facteursCles: json['facteursCles'],
      recommandations: json['recommandations'],
      generePar: json['generePar'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'titre': titre,
      if (description != null) 'description': description,
      'periodePrevue': periodePrevue,
      if (donneesHistoriques != null) 'donneesHistoriques': donneesHistoriques,
      if (resultatPrediction != null) 'resultatPrediction': resultatPrediction,
      if (confiance != null) 'confiance': confiance,
      if (methodologie != null) 'methodologie': methodologie,
      if (facteursCles != null) 'facteursCles': facteursCles,
      if (recommandations != null) 'recommandations': recommandations,
      if (generePar != null) 'generePar': generePar,
    };
  }
}
