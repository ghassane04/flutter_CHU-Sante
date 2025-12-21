# 🏥 Healthcare Dashboard (Intelligent ERP)

> **Système de Gestion Hospitalière Centralisé assisté par Intelligence Artificielle**

Le **Healthcare Dashboard** est une plateforme complète ("Full Stack") conçue pour moderniser la gestion hospitalière. Destinée aux administrateurs et directeurs d'hôpitaux, elle centralise la gestion opérationnelle, médicale et financière tout en offrant des outils d'aide à la décision basés sur l'IA prédictive.

---

## 🚀 Fonctionnalités Clés

### 1. 🔑 Gestion Administrative & Sécurité (Admin Unique)
- **Authentification Sécurisée** : Connexion JWT sécurisée pour l'administrateur.
- **Gestion RH 360°** :
    - Administration des profils **Médecins** (Spécialités, affectations).
    - Gestion du **Personnel** paramédical et administratif.
- **Paramétrage** : Configuration globale de l'établissement.

### 2. 🏥 Gestion Hospitalière (Cœur de Métier)
- **Dossiers Patients Numériques** : Historique complet, informations civiles et suivi médical.
- **Pilotage des Séjours** :
    - Gestion des **Admissions** et **Sorties**.
    - Suivi en temps réel de l'**Occupation des lits** et de la saturation des services.
- **Services Médicaux** : Organisation par départements (Urgences, Cardiologie, Pédiatrie...).
- **Actes Médicaux** : Traçabilité des soins et interventions pour la facturation.

### 3. 💰 Gestion Financière & Investissements
- **Module Investissements** :
    - Suivi des achats d'équipements lourds (IRM, Scanners).
    - Gestion des budgets par service et calcul d'amortissement.
- **Rentabilité** : Analyse comparative des revenus générés vs coûts opérationnels.

### 4. 🧠 Intelligence Artificielle & Prédictions
Ce module transforme les données en décisions stratégiques :
- **🔮 Prédictions d'Activité** : Estimation du flux de patients et taux d'occupation à J+30.
- **📉 Prédictions Financières** : Anticipation des coûts futurs.
- **🌤️ Facteurs Externes** : Prise en compte de la **Météo**, des **Saisons** et des **Jours Fériés** pour affiner les modèles.

---

## 🛠️ Architecture Technique

Le projet repose sur une architecture **3-Tiers Modulaire** :

1.  **Frontend (Mobile & Web)** : Développé en **Flutter**, offrant une expérience fluide et unifiée.
2.  **Backend (API Core)** : Développé avec **Spring Boot**, assurant la sécurité et la logique métier.
3.  **Intelligence (Data)** : Module **Python (Scikit-Learn)** pour le traitement des données et les prédictions ML.

### Stack Technologique

| Composant | Technologie | Description |
| :--- | :--- | :--- |
| **Backend** | ![Java](https://img.shields.io/badge/Java-21-orange) ![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.x-green) | API REST, Spring Security, JPA |
| **Frontend** | ![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![Dart](https://img.shields.io/badge/Dart-3.x-cyan) | Interface Cross-platform (Android/Web) |
| **Base de Données** | ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue) | Persistance des données relationnelles |
| **Intelligence Artificielle** | ![Python](https://img.shields.io/badge/Python-3.x-yellow) ![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-F7931E) | Random Forest, Pandas, Analyse de données |
| **Outils** | ![Docker](https://img.shields.io/badge/Docker-Enabled-blue) ![Git](https://img.shields.io/badge/Git-SCM-red) | Conteneurisation et Versionning |

---

## 📦 Installation & Démarrage

### Prérequis
- JDK 21+
- Flutter SDK
- Python 3.9+
- Docker (optionnel, pour la DB)

### 1️⃣ Backend (Spring Boot)
```bash
cd backend
# Configurer application.properties (Base de données)
./mvnw spring-boot:run
```
*Le serveur démarrera sur `http://localhost:8080`*

### 2️⃣ Frontend (Flutter)
```bash
cd flutter_app
flutter pub get
flutter run
```
*L'application se lancera sur votre émulateur ou navigateur.*

### 3️⃣ Module ML (Python)
```bash
cd ml
pip install -r requirements.txt
python test_ml_predictions.py
```
*L'API de prédiction sera accessible pour le backend.*

---

## 📊 Structure du Projet

```
healthcare-dashboard/
├── 📂 backend/          # Code Source Spring Boot (API)
│   ├── src/main/java   # Controllers, Services, Entities
│   └── pom.xml         # Dépendances Maven
├── 📂 flutter_app/      # Code Source Flutter (Mobile/Web)
│   ├── lib/screens     # Écrans (Dashboard, Patients, Login...)
│   └── pubspec.yaml    # Dépendances Dart
├── 📂 ml/               # Scripts Python & Dataset
│   ├── healthcare_dataset.csv  # Données historiques
│   └── healthcare_ml_predictions.ipynb # Notebook d'entraînement
└── 📄 README.md         # Documentation du projet
```

---

## 👥 Auteurs
Projet réalisé dans le cadre du rapport technique de fin d'études.
