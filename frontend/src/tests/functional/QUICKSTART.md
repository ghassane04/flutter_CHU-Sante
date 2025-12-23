# 🚀 Tests Selenium E2E - Guide de Démarrage Rapide

## Installation (5 minutes)

```bash
# 1. Installer les dépendances
cd frontend
npm install

# 2. Vérifier l'environnement
npm run test:e2e:check
```

## Lancement des Tests

### ✅ Vérification de base (30 secondes)
```bash
npm run test:e2e:smoke
```

### 🎯 Tests complets (tous les modules)
```bash
npm run test:e2e
```

### 📋 Tests par module
```bash
npm run test:e2e:login        # Authentification
npm run test:e2e:dashboard    # Tableau de bord
npm run test:e2e:patients     # Gestion patients
npm run test:e2e:sejours      # Gestion séjours
```

## Prérequis

| Service | URL | Commande |
|---------|-----|----------|
| **Frontend** | http://localhost:5173 | `npm run dev` |
| **Backend** | http://localhost:8080 | `mvn spring-boot:run` |
| **Chrome** | - | [Installer](https://www.google.com/chrome/) |

## Structure des Tests

```
frontend/src/tests/functional/
├── 📖 README.md                 Guide complet
├── 🔧 TROUBLESHOOTING.md        Résolution de problèmes
├── 📝 QUICKSTART.md            Ce fichier
├── ⚙️  check-environment.js     Vérification environnement
├── 🏃 run-all-tests.js         Exécution complète
├── 🧪 smoke.test.js            Test de base (rapide)
├── 🔐 login.test.js            Tests authentification
├── 📊 dashboard.test.js        Tests tableau de bord
├── 🧭 navigation.test.js       Tests navigation
├── 👥 patients.test.js         Tests CRUD patients
├── 🏥 sejours.test.js          Tests gestion séjours
├── 💉 actes.test.js            Tests actes médicaux
└── 🏢 services.test.js         Tests gestion services
```

## Résolution Rapide des Problèmes

### ❌ ChromeDriver not found
```bash
npm install -g chromedriver
```

### ❌ Frontend not accessible
```bash
cd frontend
npm run dev
# Attendre: "Local: http://localhost:5173/"
```

### ❌ Backend not accessible
```bash
cd backend
mvn spring-boot:run
# Attendre: "Started Application in X seconds"
```

### ❌ Tests échouent
1. Vérifier que les deux serveurs sont lancés
2. Attendre le démarrage complet (30 secondes)
3. Tester manuellement dans le navigateur
4. Consulter [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

## 📊 Résultats Attendus

✅ **Smoke Test:** 7 tests passent (~10 secondes)
✅ **Login Tests:** 4 tests passent (~15 secondes)
✅ **Dashboard Tests:** 5 tests passent (~20 secondes)
✅ **Patients Tests:** 7 tests passent (~30 secondes)
✅ **Tous les tests:** ~50 tests passent (~3-5 minutes)

## 🎓 Premiers Pas

1. **Vérifier l'environnement**
   ```bash
   npm run test:e2e:check
   ```

2. **Exécuter le test de fumée**
   ```bash
   npm run test:e2e:smoke
   ```

3. **Tester l'authentification**
   ```bash
   npm run test:e2e:login
   ```

4. **Lancer tous les tests**
   ```bash
   npm run test:e2e
   ```

## 💡 Astuces

- **Mode silencieux:** Les tests s'exécutent en arrière-plan
- **Voir le navigateur:** Commenter `--headless` dans webdriver-config.js
- **Screenshots:** Sauvegardés dans `screenshots/` en cas d'échec
- **Logs:** Affichés dans la console pendant l'exécution

## 📚 Documentation Complète

- **Guide détaillé:** [README.md](./README.md)
- **Dépannage:** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Selenium Docs:** https://www.selenium.dev/documentation/

## ✨ C'est tout !

Vous êtes prêt à tester ! 🎉

```bash
npm run test:e2e:check && npm run test:e2e
```
