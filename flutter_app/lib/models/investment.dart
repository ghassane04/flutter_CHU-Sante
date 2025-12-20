class Investment {
  final int? id;
  final String nom;
  final String categorie;
  final String description;
  final double montant;
  final DateTime dateInvestissement;
  final DateTime? dateFinPrevue;
  final String statut;
  final String? fournisseur;
  final String? responsable;
  final String? beneficesAttendus;
  final double? retourInvestissement;
  final String? niveauRisque;
  final double? roiEstime;
  final DateTime? dateEcheance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Investment({
    this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.montant,
    required this.dateInvestissement,
    this.dateFinPrevue,
    required this.statut,
    this.fournisseur,
    this.responsable,
    this.beneficesAttendus,
    this.retourInvestissement,
    this.niveauRisque,
    this.roiEstime,
    this.dateEcheance,
    this.createdAt,
    this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      nom: json['nom'] ?? '',
      categorie: json['categorie'] ?? '',
      description: json['description'] ?? '',
      montant: (json['montant'] ?? 0).toDouble(),
      dateInvestissement: DateTime.parse(json['dateInvestissement']),
      dateFinPrevue: json['dateFinPrevue'] != null ? DateTime.parse(json['dateFinPrevue']) : null,
      statut: json['statut'] ?? 'PLANIFIE',
      fournisseur: json['fournisseur'],
      responsable: json['responsable'],
      beneficesAttendus: json['beneficesAttendus'],
      retourInvestissement: json['retourInvestissement']?.toDouble(),
      niveauRisque: json['niveauRisque'],
      roiEstime: json['roiEstime']?.toDouble(),
      dateEcheance: json['dateEcheance'] != null ? DateTime.parse(json['dateEcheance']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'categorie': categorie,
      'description': description,
      'montant': montant,
      'dateInvestissement': dateInvestissement.toIso8601String().split('T')[0],
      if (dateFinPrevue != null) 'dateFinPrevue': dateFinPrevue!.toIso8601String().split('T')[0],
      'statut': statut,
      if (fournisseur != null) 'fournisseur': fournisseur,
      if (responsable != null) 'responsable': responsable,
      if (beneficesAttendus != null) 'beneficesAttendus': beneficesAttendus,
      if (retourInvestissement != null) 'retourInvestissement': retourInvestissement,
      if (niveauRisque != null) 'niveauRisque': niveauRisque,
      if (roiEstime != null) 'roiEstime': roiEstime,
      if (dateEcheance != null) 'dateEcheance': dateEcheance!.toIso8601String().split('T')[0],
    };
  }
}
