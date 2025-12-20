# Guide de personnalisation de l'application

## Personnalisation du titre et du logo

L'application permet maintenant de personnaliser facilement le titre et le logo affichés dans le menu latéral via l'interface de paramètres.

### Accès aux paramètres

1. Connectez-vous à l'application
2. Naviguez vers **Paramètres** dans le menu latéral
3. Cliquez sur l'onglet **Système**

### Configuration disponible

#### Section "Apparence de l'application"

Cette section se trouve en haut de l'onglet Système et permet de configurer :

##### 1. Titre de l'application
- **Champ** : Texte libre
- **Par défaut** : "CHU Santé"
- **Description** : Ce titre apparaîtra en haut du menu latéral
- **Exemple** : "Hôpital Central", "Clinique du Nord", etc.

##### 2. Sous-titre de l'application
- **Champ** : Texte libre
- **Par défaut** : "Finance Dashboard"
- **Description** : Texte affiché sous le titre principal
- **Exemple** : "Gestion Hospitalière", "Dashboard Médical", etc.

##### 3. Logo de l'application
- **Champ** : URL de l'image
- **Par défaut** : Vide (utilise l'icône par défaut)
- **Formats supportés** : PNG, JPG, SVG
- **Description** : URL publique de l'image du logo
- **Exemple** : `https://votre-site.com/logo.png`
- **Aperçu** : Un aperçu en temps réel s'affiche si l'URL est valide

### Enregistrement des modifications

1. Modifiez les champs souhaités
2. Cliquez sur le bouton bleu **"Enregistrer les modifications"** en bas de la page
3. Un message de confirmation s'affichera
4. Les changements seront visibles après rechargement de l'application

### Stockage des données

- Les paramètres sont sauvegardés dans la base de données MySQL via l'API SpringBoot
- Table utilisée : `settings`
- Clés des paramètres :
  - `app_title` : Titre de l'application
  - `app_subtitle` : Sous-titre de l'application
  - `app_logo_url` : URL du logo

### Conseils pour le logo

1. **Taille recommandée** : 200x200 pixels minimum
2. **Format** : PNG avec fond transparent pour un meilleur rendu
3. **Hébergement** : Utilisez un CDN ou serveur fiable pour garantir la disponibilité
4. **Aspect ratio** : Carré (1:1) de préférence
5. **Poids** : Optimisez l'image (< 100 KB) pour un chargement rapide

### Exemple d'URL de logo

```
Hébergement local (avec serveur web) :
http://localhost:8085/images/logo.png

Hébergement externe :
https://cdn.example.com/hospital-logo.png

Google Drive (lien public) :
https://drive.google.com/uc?export=view&id=VOTRE_ID

Imgur :
https://i.imgur.com/VOTRE_ID.png
```

### Dépannage

**Le logo ne s'affiche pas ?**
- Vérifiez que l'URL est accessible publiquement
- Vérifiez que l'URL pointe directement vers l'image (pas vers une page)
- Testez l'URL dans un navigateur
- Vérifiez les permissions CORS si l'image est hébergée ailleurs

**Les modifications ne sont pas visibles ?**
- Actualisez complètement l'application (F5 ou Ctrl+R)
- Vérifiez que le message de confirmation s'est affiché
- Consultez les logs du backend pour détecter d'éventuelles erreurs

**Le titre est trop long ?**
- Limitez le titre à 20 caractères maximum pour un affichage optimal
- Utilisez le sous-titre pour plus d'informations

### API Backend

Les endpoints suivants sont utilisés :

```
GET    /api/settings              - Récupérer tous les paramètres
GET    /api/settings/cle/{cle}    - Récupérer un paramètre par clé
POST   /api/settings              - Créer un nouveau paramètre
PUT    /api/settings/{id}         - Mettre à jour un paramètre
```

### Structure de données

```json
{
  "id": 1,
  "cle": "app_title",
  "categorie": "Apparence",
  "libelle": "Titre de l'application",
  "valeur": "CHU Santé",
  "typeValeur": "STRING",
  "description": "Titre principal affiché dans le menu latéral"
}
```

## Support

Pour toute question ou problème, consultez la documentation technique ou contactez l'équipe de développement.
