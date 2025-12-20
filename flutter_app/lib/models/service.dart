class MedicalService {
  final int id;
  final String nom;
  final String? description;
  final String type;
  final int? capacite;
  final int? litsDisponibles;
  final String? responsable;

  MedicalService({
    required this.id,
    required this.nom,
    this.description,
    required this.type,
    this.capacite,
    this.litsDisponibles,
    this.responsable,
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) {
    return MedicalService(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'],
      type: json['type'] ?? '',
      capacite: json['capacite'],
      litsDisponibles: json['litsDisponibles'],
      responsable: json['responsable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type,
      'capacite': capacite,
      'litsDisponibles': litsDisponibles,
      'responsable': responsable,
    };
  }

  MedicalService copyWith({
    int? id,
    String? nom,
    String? description,
    String? type,
    int? capacite,
    int? litsDisponibles,
    String? responsable,
  }) {
    return MedicalService(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      capacite: capacite ?? this.capacite,
      litsDisponibles: litsDisponibles ?? this.litsDisponibles,
      responsable: responsable ?? this.responsable,
    );
  }

  @override
  String toString() => 'MedicalService(id: $id, nom: $nom, type: $type)';
}

// Alias pour la compatibilité
typedef Service = MedicalService;
