-- ============================================================
-- DONNÉES DE TEST POUR LES RAPPORTS
-- Healthcare Dashboard
-- ============================================================

USE healthcare_dashboard;

-- Désactiver le mode safe update temporairement
SET SQL_SAFE_UPDATES = 0;

-- Nettoyage des données existantes
DELETE FROM reports;

-- Réactiver le mode safe update
SET SQL_SAFE_UPDATES = 1;

-- Insertion de rapports de test
INSERT INTO reports (titre, type, periode, resume, date_debut, date_fin, genere_par, statut) VALUES
('Rapport Mensuel des Coûts - Janvier 2024', 'COUTS', 'Janvier 2024', 
 'Analyse détaillée des coûts hospitaliers pour le mois de janvier 2024. Répartition par service et catégorie de dépenses.',
 '2024-01-01', '2024-01-31', 'admin', 'PUBLIE'),

('Prédictions Financières Q1 2024', 'PREDICTIONS', 'Q1 2024',
 'Prévisions financières pour le premier trimestre 2024 basées sur les tendances historiques et l\'analyse des données.',
 '2024-01-01', '2024-03-31', 'admin', 'PUBLIE'),

('Analyse des Anomalies - Décembre 2023', 'ANOMALIES', 'Décembre 2023',
 'Détection et analyse des anomalies dans les dépenses et les processus hospitaliers pour décembre 2023.',
 '2023-12-01', '2023-12-31', 'admin', 'PUBLIE'),

('Rapport Annuel 2023', 'PERSONNALISE', 'Année 2023',
 'Synthèse complète de l\'activité hospitalière et des performances financières pour l\'année 2023.',
 '2023-01-01', '2023-12-31', 'admin', 'ARCHIVE'),

('Budget Prévisionnel 2024', 'COUTS', 'Année 2024',
 'Élaboration du budget prévisionnel pour l\'année 2024 avec répartition par service et catégorie.',
 '2024-01-01', '2024-12-31', 'admin', 'BROUILLON'),

('Rapport Mensuel des Coûts - Février 2024', 'COUTS', 'Février 2024',
 'Analyse des coûts pour le mois de février 2024, comparaison avec janvier et tendances observées.',
 '2024-02-01', '2024-02-29', 'admin', 'PUBLIE'),

('Optimisation des Ressources Q2 2024', 'PREDICTIONS', 'Q2 2024',
 'Recommandations pour l\'optimisation des ressources et la réduction des coûts au deuxième trimestre.',
 '2024-04-01', '2024-06-30', 'admin', 'BROUILLON'),

('Audit des Dépenses Pharmaceutiques', 'ANOMALIES', 'Q4 2023',
 'Audit complet des dépenses pharmaceutiques avec identification des surconsommations et des opportunités d\'économie.',
 '2023-10-01', '2023-12-31', 'admin', 'PUBLIE');

-- Affichage des rapports insérés
SELECT * FROM reports ORDER BY date_debut DESC;
