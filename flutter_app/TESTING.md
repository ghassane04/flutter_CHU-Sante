# Flutter Testing & Quality

## 📋 Structure des Tests

```
test/
├── providers/           # Tests unitaires des providers
│   ├── auth_provider_test.dart
│   └── patient_provider_test.dart
├── screens/             # Tests widgets des écrans
│   └── login_screen_test.dart
└── widget_test.dart     # Test widget par défaut

integration_test/
└── login_flow_test.dart # Tests d'intégration E2E
```

---

## 🧪 Exécution des Tests

### Tests Unitaires & Widget
```bash
# Tous les tests
flutter test

# Test spécifique
flutter test test/providers/auth_provider_test.dart

# Avec couverture
flutter test --coverage
```

### Tests d'Intégration
```bash
# Sur l'émulateur/device connecté
flutter test integration_test/login_flow_test.dart

# Sur Chrome (web)
flutter test integration_test --platform chrome
```

### Générer les Mocks (Mockito)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📊 Couverture de Code

```bash
# Générer le rapport de couverture
flutter test --coverage

# Visualiser (nécessite lcov)
genhtml coverage/lcov.info -o coverage/html
# Ouvrir coverage/html/index.html
```

---

## 🔍 SonarQube

### Configuration
Modifiez `sonar-project.properties` :
```properties
sonar.projectKey=YOUR_PROJECT_KEY_HERE
sonar.organization=YOUR_ORGANIZATION_HERE
```

### Exécution
```bash
# Générer la couverture
flutter test --coverage

# Scanner avec SonarQube
sonar-scanner -Dsonar.token=YOUR_TOKEN
```

---

## ✅ Tests Implémentés

| Type | Fichier | Description |
|------|---------|-------------|
| Unit | `auth_provider_test.dart` | Login, signup, logout |
| Unit | `patient_provider_test.dart` | CRUD patients |
| Widget | `login_screen_test.dart` | UI login, validation |
| Integration | `login_flow_test.dart` | Flow complet login |

---

## 📝 Bonnes Pratiques

1. **Nommer clairement** : `should_returnTrue_whenLoginSuccess`
2. **Arrange-Act-Assert** : Structure AAA pour chaque test
3. **Mock les dépendances** : Utiliser Mockito pour isoler les tests
4. **Tester les erreurs** : Couvrir les cas d'échec
