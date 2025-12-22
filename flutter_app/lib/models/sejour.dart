class Sejour {
  final int id;
  final int patientId;
  final String? patientNom;
  final String? patientPrenom;
  final int serviceId;
  final String? serviceNom;
  final String dateEntree;
  final String? dateSortie;
  final String motif;
  final String? diagnostic;
  final String statut; // EN_COURS, TERMINE, ANNULE
  final String? typeAdmission;
  final double? coutTotal;

  Sejour({
    required this.id,
    required this.patientId,
    this.patientNom,
    this.patientPrenom,
    required this.serviceId,
    this.serviceNom,
    required this.dateEntree,
    this.dateSortie,
    required this.motif,
    this.diagnostic,
    required this.statut,
    this.typeAdmission,
    this.coutTotal,
  });

  factory Sejour.fromJson(Map<String, dynamic> json) {
    return Sejour(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      patientNom: json['patientNom'],
      patientPrenom: json['patientPrenom'],
      serviceId: json['serviceId'] ?? 0,
      serviceNom: json['serviceNom'],
      dateEntree: json['dateEntree'] ?? '',
      dateSortie: json['dateSortie'],
      motif: json['motif'] ?? '',
      diagnostic: json['diagnostic'],
      statut: json['statut'] ?? 'EN_COURS',
      typeAdmission: json['typeAdmission'],
      coutTotal: json['coutTotal']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to ensure LocalDateTime format
    String formatDateTime(String date) {
      if (!date.contains('T')) {
        return '${date}T00:00:00';
      }
      return date;
    }
    
    return {
      'id': id,
      'patientId': patientId,
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
      'serviceId': serviceId,
      'serviceNom': serviceNom,
      'dateEntree': formatDateTime(dateEntree),
      'dateSortie': dateSortie != null ? formatDateTime(dateSortie!) : null,
      'motif': motif,
      'diagnostic': diagnostic,
      'statut': statut,
      'typeAdmission': typeAdmission,
      'coutTotal': coutTotal,
    };
  }

  Sejour copyWith({
    int? id,
    int? patientId,
    String? patientNom,
    String? patientPrenom,
    int? serviceId,
    String? serviceNom,
    String? dateEntree,
    String? dateSortie,
    String? motif,
    String? diagnostic,
    String? statut,
    String? typeAdmission,
    double? coutTotal,
  }) {
    return Sejour(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientNom: patientNom ?? this.patientNom,
      patientPrenom: patientPrenom ?? this.patientPrenom,
      serviceId: serviceId ?? this.serviceId,
      serviceNom: serviceNom ?? this.serviceNom,
      dateEntree: dateEntree ?? this.dateEntree,
      dateSortie: dateSortie ?? this.dateSortie,
      motif: motif ?? this.motif,
      diagnostic: diagnostic ?? this.diagnostic,
      statut: statut ?? this.statut,
      typeAdmission: typeAdmission ?? this.typeAdmission,
      coutTotal: coutTotal ?? this.coutTotal,
    );
  }

  @override
  String toString() => 'Sejour(id: $id, patientId: $patientId, serviceId: $serviceId)';
}
