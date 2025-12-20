class Patient {
  final int id;
  final String nom;
  final String prenom;
  final String numeroSecuriteSociale;
  final String dateNaissance;
  final String sexe;
  final String? adresse;
  final String? telephone;
  final String? email;
  final int? age;

  Patient({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.numeroSecuriteSociale,
    required this.dateNaissance,
    required this.sexe,
    this.adresse,
    this.telephone,
    this.email,
    this.age,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      numeroSecuriteSociale: json['numeroSecuriteSociale'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
      sexe: json['sexe'] ?? '',
      adresse: json['adresse'],
      telephone: json['telephone'],
      email: json['email'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'numeroSecuriteSociale': numeroSecuriteSociale,
      'dateNaissance': dateNaissance,
      'sexe': sexe,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'age': age,
    };
  }

  Patient copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? numeroSecuriteSociale,
    String? dateNaissance,
    String? sexe,
    String? adresse,
    String? telephone,
    String? email,
    int? age,
  }) {
    return Patient(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      numeroSecuriteSociale: numeroSecuriteSociale ?? this.numeroSecuriteSociale,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      sexe: sexe ?? this.sexe,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }

  @override
  String toString() => 'Patient(id: $id, nom: $nom, prenom: $prenom)';
}
