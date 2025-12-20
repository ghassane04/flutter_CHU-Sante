class ActeMedical {
  final int id;
  final int sejourId;
  final String code;
  final String libelle;
  final String type;
  final String dateRealisation;
  final double tarif;
  final String? medecin;
  final String? notes;

  ActeMedical({
    required this.id,
    required this.sejourId,
    required this.code,
    required this.libelle,
    required this.type,
    required this.dateRealisation,
    required this.tarif,
    this.medecin,
    this.notes,
  });

  factory ActeMedical.fromJson(Map<String, dynamic> json) {
    return ActeMedical(
      id: json['id'] ?? 0,
      sejourId: json['sejourId'] ?? 0,
      code: json['code'] ?? '',
      libelle: json['libelle'] ?? '',
      type: json['type'] ?? '',
      dateRealisation: json['dateRealisation'] ?? '',
      tarif: (json['tarif'] ?? 0).toDouble(),
      medecin: json['medecin'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sejourId': sejourId,
      'code': code,
      'libelle': libelle,
      'type': type,
      'dateRealisation': dateRealisation,
      'tarif': tarif,
      'medecin': medecin,
      'notes': notes,
    };
  }

  ActeMedical copyWith({
    int? id,
    int? sejourId,
    String? code,
    String? libelle,
    String? type,
    String? dateRealisation,
    double? tarif,
    String? medecin,
    String? notes,
  }) {
    return ActeMedical(
      id: id ?? this.id,
      sejourId: sejourId ?? this.sejourId,
      code: code ?? this.code,
      libelle: libelle ?? this.libelle,
      type: type ?? this.type,
      dateRealisation: dateRealisation ?? this.dateRealisation,
      tarif: tarif ?? this.tarif,
      medecin: medecin ?? this.medecin,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'ActeMedical(id: $id, code: $code, libelle: $libelle)';
}
