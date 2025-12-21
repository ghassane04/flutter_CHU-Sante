# Testing & Quality Configuration

## SonarQube

### Configuration
Modifiez les propriétés dans `pom.xml` :
```xml
<sonar.projectKey>YOUR_PROJECT_KEY_HERE</sonar.projectKey>
<sonar.organization>YOUR_ORGANIZATION_HERE</sonar.organization>
```

### Exécution
```bash
# Générer le rapport de couverture et envoyer à SonarCloud
mvn clean verify sonar:sonar -Dsonar.token=YOUR_SONAR_TOKEN
```

### Rapport de couverture local
```bash
mvn clean test
# Voir le rapport dans: target/site/jacoco/index.html
```

---

## JMeter

### Prérequis
- Télécharger JMeter: https://jmeter.apache.org/download_jmeter.cgi
- Ajouter JMeter au PATH

### Exécution GUI
```bash
jmeter -t jmeter/healthcare-api-load-test.jmx
```

### Exécution CLI (sans GUI)
```bash
jmeter -n -t jmeter/healthcare-api-load-test.jmx -l results.jtl -e -o jmeter-report/
```

### Configuration du test
- **50 utilisateurs virtuels**
- **10 itérations par utilisateur**
- **30 secondes de montée en charge (ramp-up)**
- Endpoints testés: `/api/patients`, `/api/services`, `/api/medecins`, `/api/sejours`, `/api/actes`, `/actuator/health`

---

## Tests Unitaires

```bash
# Exécuter tous les tests
mvn test

# Exécuter avec rapport de couverture
mvn clean verify
```
