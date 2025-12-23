# Tests Selenium E2E - Frontend React

## 📋 Description

Suite complète de tests End-to-End (E2E) utilisant Selenium WebDriver pour tester le frontend React de l'application CHU Santé.

## 🔧 Prérequis

### 1. Installation des dépendances

```bash
cd frontend
npm install
```

Les dépendances suivantes sont déjà incluses dans `package.json` :
- `selenium-webdriver`: ^4.17.0
- `mocha`: Pour exécuter les tests

### 2. Installation de ChromeDriver

**Option 1 - Installation automatique (recommandée):**
```bash
npm install -g chromedriver
```

**Option 2 - Installation manuelle:**
1. Télécharger ChromeDriver depuis: https://chromedriver.chromium.org/downloads
2. Choisir la version correspondant à votre Chrome
3. Ajouter ChromeDriver au PATH système

**Vérifier l'installation:**
```bash
chromedriver --version
```

### 3. Démarrer les services

**Terminal 1 - Backend:**
```bash
cd backend
mvn spring-boot:run
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

Attendre que le frontend soit accessible sur `http://localhost:5173`

## 🧪 Structure des Tests

```
frontend/src/tests/functional/
├── README.md                  # Ce fichier
├── run-all-tests.js          # Script pour exécuter tous les tests
├── selenium-test.js          # Test de base (legacy)
├── login.test.js             # Tests d'authentification
├── dashboard.test.js         # Tests du tableau de bord
├── navigation.test.js        # Tests de navigation
├── patients.test.js          # Tests CRUD patients
├── sejours.test.js           # Tests gestion séjours
├── actes.test.js             # Tests actes médicaux
└── services.test.js          # Tests gestion services
```

## ▶️ Exécution des Tests

### Tous les tests
```bash
npm run test:e2e
```

ou

```bash
node src/tests/functional/run-all-tests.js
```

### Test individuel
```bash
npx mocha src/tests/functional/login.test.js
npx mocha src/tests/functional/dashboard.test.js
npx mocha src/tests/functional/patients.test.js
```

### Mode headless (sans interface graphique)
Modifier le fichier de test pour utiliser:
```javascript
driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(new chrome.Options().headless())
    .build();
```

## 📊 Tests Couverts

### 1. login.test.js
- ✅ Chargement de la page de connexion
- ✅ Validation avec identifiants invalides
- ✅ Connexion réussie avec identifiants valides
- ✅ Validation des champs obligatoires

### 2. dashboard.test.js
- ✅ Chargement du tableau de bord
- ✅ Affichage des statistiques (cartes)
- ✅ Présence du menu de navigation
- ✅ Navigation entre les pages
- ✅ Affichage des graphiques

### 3. navigation.test.js
- ✅ Présence de la barre de navigation
- ✅ Navigation entre différentes pages
- ✅ Liens de navigation fonctionnels
- ✅ Indicateur de page active
- ✅ Maintien de l'authentification
- ✅ Fonctionnalité de déconnexion

### 4. patients.test.js
- ✅ Navigation vers la page patients
- ✅ Affichage de la liste/tableau
- ✅ Fonctionnalité de recherche
- ✅ Bouton d'ajout de patient
- ✅ Modal de création
- ✅ Vue détails patient
- ✅ Pagination

### 5. sejours.test.js
- ✅ Navigation vers la page séjours
- ✅ Affichage de la liste des séjours
- ✅ Options de filtrage
- ✅ Badges de statut
- ✅ Ajout de séjour
- ✅ Détails des séjours

### 6. actes.test.js
- ✅ Navigation vers les actes médicaux
- ✅ Affichage de la liste des actes
- ✅ Types d'actes
- ✅ Informations de coût
- ✅ Recherche/filtrage

### 7. services.test.js
- ✅ Navigation vers la page services
- ✅ Affichage de la liste des services
- ✅ Informations de capacité
- ✅ Cartes/items de service

## 🎯 Identifiants de Test

Par défaut, les tests utilisent:
- **Email:** admin@chu.com
- **Mot de passe:** admin123

Modifier ces valeurs dans chaque fichier de test si nécessaire.

## 🔧 Configuration

### Timeout
Par défaut: 30 secondes par test
```javascript
this.timeout(30000);
```

### URL de base
Par défaut: `http://localhost:5173`

Modifier dans chaque test si nécessaire:
```javascript
await driver.get('http://localhost:5173/dashboard');
```

## 📝 Bonnes Pratiques

1. **Toujours démarrer les services** avant d'exécuter les tests
2. **Utiliser des timeouts appropriés** pour les éléments dynamiques
3. **Nettoyer après chaque test** (fermer le navigateur)
4. **Utiliser des sélecteurs robustes** (data-testid, aria-labels)
5. **Vérifier l'état de l'application** avant les assertions

## 🐛 Dépannage

### Erreur: "ChromeDriver not found"
```bash
npm install -g chromedriver
# ou
brew install chromedriver  # macOS
```

### Erreur: "Unable to connect to localhost:5173"
- Vérifier que le frontend est lancé: `npm run dev`
- Vérifier le port dans la console de démarrage

### Erreur: "Element not found"
- Augmenter les timeouts
- Vérifier les sélecteurs CSS
- Ajouter des `await driver.sleep(2000)` si nécessaire

### Tests qui échouent de façon intermittente
- Augmenter les délais d'attente
- Utiliser `driver.wait(until.elementLocated())` au lieu de `sleep()`
- Vérifier la stabilité du backend

## 📈 Rapports de Tests

Pour générer un rapport HTML:
```bash
npm install --save-dev mochawesome
npx mocha src/tests/functional/*.test.js --reporter mochawesome
```

Le rapport sera dans: `mochawesome-report/mochawesome.html`

## 🚀 CI/CD

Exemple pour GitHub Actions (`.github/workflows/e2e-tests.yml`):
```yaml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      - name: Install dependencies
        run: cd frontend && npm install
      - name: Start Backend
        run: cd backend && mvn spring-boot:run &
      - name: Start Frontend
        run: cd frontend && npm run dev &
      - name: Run E2E Tests
        run: cd frontend && npm run test:e2e
```

## 📚 Ressources

- [Selenium WebDriver Documentation](https://www.selenium.dev/documentation/)
- [Mocha Test Framework](https://mochajs.org/)
- [ChromeDriver Downloads](https://chromedriver.chromium.org/)

## 🤝 Contribution

Pour ajouter de nouveaux tests:
1. Créer un nouveau fichier `feature.test.js`
2. Suivre la structure existante
3. Ajouter le fichier à `run-all-tests.js`
4. Documenter les cas de test

## 📞 Support

Pour toute question ou problème:
- Vérifier la documentation Selenium
- Consulter les logs du navigateur (F12 DevTools)
- Activer le mode verbose de ChromeDriver
