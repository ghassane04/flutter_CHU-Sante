# Healthcare Dashboard Frontend

Application React + TypeScript + Vite pour le tableau de bord Healthcare.

## Technologies

- React 18
- TypeScript
- Vite
- Tailwind CSS
- Shadcn/ui Components

## Installation

```bash
cd frontend
npm install
```

## Développement

```bash
npm run dev
```

L'application sera disponible sur `http://localhost:5173`

## Build

```bash
npm run build
```

## Structure

```
frontend/
├── src/
│   ├── components/       # Composants React
│   ├── pages/           # Pages de l'application
│   ├── data/            # Données mock
│   ├── styles/          # Styles CSS
│   └── App.tsx          # Composant principal
├── index.html
├── package.json
└── vite.config.ts
```

## Configuration API

Modifier l'URL de l'API dans les services pour pointer vers le backend:
```typescript
const API_URL = 'http://localhost:8080/api';
```
