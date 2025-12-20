class Alert {
  final int? id;
  final String titre;
  final String message;
  final String type;
  final String priorite;
  final String categorie;
  final bool lu;
  final bool resolu;
  final String? assigneA;
  final DateTime? dateResolution;
  final String? commentaire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Alert({
    this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.priorite,
    required this.categorie,
    this.lu = false,
    this.resolu = false,
    this.assigneA,
    this.dateResolution,
    this.commentaire,
    this.createdAt,
    this.updatedAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      titre: json['titre'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'INFO',
      priorite: json['priorite'] ?? 'MOYENNE',
      categorie: json['categorie'] ?? '',
      lu: json['lu'] ?? false,
      resolu: json['resolu'] ?? false,
      assigneA: json['assigneA'],
      dateResolution: json['dateResolution'] != null ? DateTime.parse(json['dateResolution']) : null,
      commentaire: json['commentaire'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'message': message,
      'type': type,
      'priorite': priorite,
      'categorie': categorie,
      'lu': lu,
      'resolu': resolu,
      if (assigneA != null) 'assigneA': assigneA,
      if (dateResolution != null) 'dateResolution': dateResolution!.toIso8601String().split('T')[0],
      if (commentaire != null) 'commentaire': commentaire,
    };
  }
}
