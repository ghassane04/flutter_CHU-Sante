class Report {
  final int? id;
  final String titre;
  final String type;
  final String periode;
  final String? resume;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? generePar;
  final String? donneesPrincipales;
  final String? conclusions;
  final String? recommandations;
  final String statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    this.id,
    required this.titre,
    required this.type,
    required this.periode,
    this.resume,
    required this.dateDebut,
    required this.dateFin,
    this.generePar,
    this.donneesPrincipales,
    this.conclusions,
    this.recommandations,
    required this.statut,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      titre: json['titre'] ?? '',
      type: json['type'] ?? '',
      periode: json['periode'] ?? '',
      resume: json['resume'],
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      generePar: json['generePar'],
      donneesPrincipales: json['donneesPrincipales'],
      conclusions: json['conclusions'],
      recommandations: json['recommandations'],
      statut: json['statut'] ?? 'BROUILLON',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'type': type,
      'periode': periode,
      if (resume != null) 'resume': resume,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      if (generePar != null) 'generePar': generePar,
      if (donneesPrincipales != null) 'donneesPrincipales': donneesPrincipales,
      if (conclusions != null) 'conclusions': conclusions,
      if (recommandations != null) 'recommandations': recommandations,
      'statut': statut,
    };
  }
}
