class Medecin {
  final int? id;
  final String nom;
  final String prenom;
  final String specialite;
  final String? numeroOrdre;
  final String? telephone;
  final String? email;
  final int? serviceId;
  final String? serviceNom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medecin({
    this.id,
    required this.nom,
    required this.prenom,
    required this.specialite,
    this.numeroOrdre,
    this.telephone,
    this.email,
    this.serviceId,
    this.serviceNom,
    this.createdAt,
    this.updatedAt,
  });

  factory Medecin.fromJson(Map<String, dynamic> json) {
    return Medecin(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      specialite: json['specialite'] ?? '',
      numeroOrdre: json['numeroOrdre'],
      telephone: json['telephone'],
      email: json['email'],
      serviceId: json['serviceId'],
      serviceNom: json['serviceNom'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'specialite': specialite,
      if (numeroOrdre != null) 'numeroOrdre': numeroOrdre,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (serviceId != null) 'serviceId': serviceId,
    };
  }

  String get fullName => '$prenom $nom';
}
