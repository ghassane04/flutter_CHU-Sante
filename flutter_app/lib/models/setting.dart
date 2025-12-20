class Setting {
  final int? id;
  final String cle;
  final String categorie;
  final String libelle;
  final String valeur;
  final String typeValeur;
  final String? description;
  final String? valeurParDefaut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Setting({
    this.id,
    required this.cle,
    required this.categorie,
    required this.libelle,
    required this.valeur,
    required this.typeValeur,
    this.description,
    this.valeurParDefaut,
    this.createdAt,
    this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'],
      cle: json['cle'] ?? '',
      categorie: json['categorie'] ?? '',
      libelle: json['libelle'] ?? '',
      valeur: json['valeur'] ?? '',
      typeValeur: json['typeValeur'] ?? 'STRING',
      description: json['description'],
      valeurParDefaut: json['valeurParDefaut'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cle': cle,
      'categorie': categorie,
      'libelle': libelle,
      'valeur': valeur,
      'typeValeur': typeValeur,
      if (description != null) 'description': description,
      if (valeurParDefaut != null) 'valeurParDefaut': valeurParDefaut,
    };
  }
}
