# Guide de Mise à Jour de l'Interface Flutter

## ✅ TERMINÉ

### 1. Écran Médecins (`medecins_screen.dart`)
- ✅ Design moderne avec cards blanches
- ✅ Recherche fonctionnelle
- ✅ Responsive (mobile/desktop)
- ✅ Badge "ACTIF" vert
- ✅ Boutons "Modifier" (teal) et "Supprimer" (rouge)
- ✅ Affichage des informations (téléphone, email, spécialité, service)

### 2. Composants Réutilisables (`widgets/responsive_layout.dart`)
- ✅ ResponsiveLayout avec breakpoints
- ✅ ScreenHeader
- ✅ SearchBarWidget

### 3. Écran Services (`services_screen_new.dart`)
- ✅ Cards avec occupation en pourcentage
- ✅ Barre de progression colorée (vert<70%, orange 70-85%, rouge>85%)
- ✅ Stats de capacité et lits disponibles
- ✅ Responsable affiché

## 📋 À FAIRE

Remplacez les fichiers suivants en utilisant services_screen_new.dart comme modèle:

### 4. Patients Screen
```dart
// Structure similaire à medecins_screen.dart
- Cards avec avatar bleu
- NSS, Date de naissance, âge
- Téléphone, email
- Genre (icône homme/femme)
- Boutons Modifier/Supprimer
```

### 5. Séjours Screen
```dart
// Cards horizontales avec:
- Nom patient
- Service (icône hôpital)
- Dates entrée/sortie + durée
- Motif + Diagnostic
- Coût en € (texte bleu)
- Badge statut: TERMINE (violet) ou EN_COURS (vert)
- Boutons Modifier/Supprimer
```

### 6. Investissements Screen
```dart
// En-tête avec 3 cards de stats:
- Budget total disponible: 7 015 000 € (icône $)
- ROI estimé total: 1 252 500 € (icône tendance)
- Projets actifs: 4 (icône calendrier)

// Section "Répartition du budget" (PieChart)
// Liste d'investissements avec:
- Titre + description
- Montant, ROI estimé %, Catégorie, Échéance
- Badge risque: Risque Moyen (orange), En cours (vert), En attente (bleu)
- Boutons "Voir détails", Modifier, Supprimer
```

### 7. Alertes Screen
```dart
// En-tête avec 4 cards de stats:
- Total alertes: 12
- Critiques: 2 (rouge)
- Résolues: 9 (vert)
- Taux résolution: 75% (bleu)

// Filtres: Date, Priorité (dropdown), Statut (dropdown)

// Table des alertes:
- Date + heure
- Service (FINANCIER, etc)
- Message (titre + détails)
- Montant (rouge si erreur)
- Gravité: badge Critique (rouge), etc
- Statut: badge Résolu (vert)
- Bouton "Details"
```

## 🎨 Couleurs à Utiliser

```dart
// Primaire
const primaryBlue = Color(0xFF0284C7);
const darkGray = Color(0xFF1F2937);

// Status
const success = Color(0xFF10B981); // Vert
const warning = Color(0xFFF97316); // Orange
const error = Color(0xFFEF4444);   // Rouge
const info = Color(0xFF0284C7);    // Bleu

// Boutons
const teal = Color(0xFF14B8A6);    // Modifier

// Backgrounds
const bgGray = Color(0xFFF5F7FA);
const cardWhite = Colors.white;
```

## 📱 Responsive Rules

```dart
// Mobile: < 650px → 1 colonne
// Tablet: 650-1100px → 2 colonnes
// Desktop: > 1100px → 3 colonnes

ResponsiveLayout.getGridCrossAxisCount(context)
```

## 🔄 Prochaines Étapes

1. Remplacer `services_screen.dart` par `services_screen_new.dart`
2. Adapter `patients_screen.dart` 
3. Adapter `sejours_screen.dart`
4. Adapter `investments_screen.dart`
5. Adapter `alerts_screen.dart`
6. Tester sur mobile et desktop
7. Vérifier les transitions et animations

## 📝 Notes

- Tous les écrans doivent avoir le même header style
- Bouton "Nouveau X" toujours bleu primaire
- Cards toujours avec `elevation: 0` et `border: grey[200]`
- Espacements: 8, 12, 16, 20, 24px
- BorderRadius: 8px (boutons), 12px (cards), 4px (badges)
