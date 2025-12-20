# Healthcare Dashboard Backend

API REST pour l'application Healthcare Dashboard développée avec Spring Boot.

## Technologies Utilisées

- Java 17
- Spring Boot 3.2.0
- Spring Security avec JWT
- Spring Data JPA
- MySQL
- Lombok
- Maven

## Structure du Projet

```
backend/
├── src/
│   └── main/
│       ├── java/com/healthcare/dashboard/
│       │   ├── entities/           # Entités JPA
│       │   ├── repositories/       # Repositories Spring Data
│       │   ├── services/          # Logique métier
│       │   ├── controllers/       # API REST Controllers
│       │   ├── dto/               # Data Transfer Objects
│       │   ├── security/          # Configuration JWT et sécurité
│       │   └── config/            # Configuration Spring
│       └── resources/
│           └── application.properties
└── pom.xml
```

## Configuration

1. Créer une base de données MySQL:
```sql
CREATE DATABASE healthcare_dashboard;
```

2. Modifier `application.properties` selon votre configuration:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/healthcare_dashboard
spring.datasource.username=your_username
spring.datasource.password=your_password
```

## Lancement
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

L'API sera disponible sur `http://localhost:8080`

## Tests et Qualité

### Tests Unitaires et Intégration
```bash
# Lancer tous les tests
mvn test

# Lancer un test spécifique
mvn test -Dtest=PatientServiceTest
```

### Qualité et Monitoring
Une stack Docker est disponible pour le monitoring :
```bash
docker-compose -f docker-compose.monitoring.yml up -d
```
- **SonarQube** (Qualité): `http://localhost:9000`
- **Prometheus** (Métriques): `http://localhost:9090`
- **Grafana** (Visualisation): `http://localhost:3001` (admin/admin)

## Endpoints API

### Authentication
- `POST /api/auth/login` - Authentification utilisateur

### Dashboard
- `GET /api/dashboard/stats` - Statistiques du dashboard

### Patients
- `GET /api/patients` - Liste des patients
- `GET /api/patients/{id}` - Détails d'un patient
- `POST /api/patients` - Créer un patient
- `PUT /api/patients/{id}` - Modifier un patient
- `DELETE /api/patients/{id}` - Supprimer un patient

### Services
- `GET /api/services` - Liste des services
- `GET /api/services/{id}` - Détails d'un service
- `POST /api/services` - Créer un service
- `PUT /api/services/{id}` - Modifier un service
- `DELETE /api/services/{id}` - Supprimer un service

### Séjours
- `GET /api/sejours` - Liste des séjours
- `GET /api/sejours/{id}` - Détails d'un séjour
- `GET /api/sejours/en-cours` - Séjours en cours
- `POST /api/sejours` - Créer un séjour
- `PUT /api/sejours/{id}` - Modifier un séjour
- `DELETE /api/sejours/{id}` - Supprimer un séjour

### Actes Médicaux
- `GET /api/actes` - Liste des actes médicaux
- `GET /api/actes/{id}` - Détails d'un acte
- `GET /api/actes/sejour/{sejourId}` - Actes d'un séjour
- `POST /api/actes` - Créer un acte médical
- `PUT /api/actes/{id}` - Modifier un acte médical
- `DELETE /api/actes/{id}` - Supprimer un acte médical
