-- ============================================================
-- SCRIPT D'INSERTION DES DONNÉES DE DÉMONSTRATION COMPLÈTES
-- À exécuter après CREATE_TABLES.sql
-- ============================================================

USE healthcare_dashboard;

-- ============================================================
-- 1. INSERTION DES RÔLES
-- ============================================================
INSERT INTO roles (nom, description) VALUES
('ROLE_ADMIN', 'Administrateur système avec accès complet'),
('ROLE_MEDECIN', 'Médecin avec accès aux dossiers patients'),
('ROLE_INFIRMIER', 'Infirmier avec accès limité'),
('ROLE_GESTIONNAIRE', 'Gestionnaire financier et administratif'),
('ROLE_DIRECTION', 'Direction de l\'établissement');

-- ============================================================
-- 2. INSERTION DES UTILISATEURS (Mot de passe: "password123")
-- ============================================================
INSERT INTO users (username, password, email, nom, prenom, actif) VALUES
('admin', '$2a$10$rLZXZLqG3LF2qVhP0KY5L.5oQ6nZQ9sLQvzPZXKx1lRG1HmQ2nqFe', 'admin@hospital.com', 'Admin', 'Système', TRUE),
('dr.martin', '$2a$10$rLZXZLqG3LF2qVhP0KY5L.5oQ6nZQ9sLQvzPZXKx1lRG1HmQ2nqFe', 'martin@hospital.com', 'Martin', 'Jean', TRUE),
('dr.dupont', '$2a$10$rLZXZLqG3LF2qVhP0KY5L.5oQ6nZQ9sLQvzPZXKx1lRG1HmQ2nqFe', 'dupont@hospital.com', 'Dupont', 'Marie', TRUE),
('inf.bernard', '$2a$10$rLZXZLqG3LF2qVhP0KY5L.5oQ6nZQ9sLQvzPZXKx1lRG1HmQ2nqFe', 'bernard@hospital.com', 'Bernard', 'Sophie', TRUE),
('gestionnaire', '$2a$10$rLZXZLqG3LF2qVhP0KY5L.5oQ6nZQ9sLQvzPZXKx1lRG1HmQ2nqFe', 'finance@hospital.com', 'Leroy', 'Pierre', TRUE);

-- ============================================================
-- 3. ASSOCIATION UTILISATEURS-RÔLES
-- ============================================================
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- admin -> ROLE_ADMIN
(2, 2), -- dr.martin -> ROLE_MEDECIN
(3, 2), -- dr.dupont -> ROLE_MEDECIN
(4, 3), -- inf.bernard -> ROLE_INFIRMIER
(5, 4); -- gestionnaire -> ROLE_GESTIONNAIRE

-- ============================================================
-- 4. INSERTION DES SERVICES MÉDICAUX
-- ============================================================
INSERT INTO services (nom, description, type, capacite, lits_disponibles, responsable) VALUES
('Urgences', 'Service des urgences - accueil 24h/24', 'URGENCE', 40, 12, 'Dr. Martin Jean'),
('Chirurgie', 'Service de chirurgie générale et spécialisée', 'CHIRURGIE', 60, 15, 'Dr. Dupont Marie'),
('Cardiologie', 'Service de cardiologie et soins intensifs cardiaques', 'CARDIOLOGIE', 35, 8, 'Dr. Lefevre Paul'),
('Pédiatrie', 'Service de pédiatrie générale', 'PEDIATRIE', 30, 10, 'Dr. Rousseau Claire'),
('Maternité', 'Service de maternité et néonatologie', 'MATERNITE', 25, 3, 'Dr. Lambert Anne'),
('Radiologie', 'Service d\'imagerie médicale', 'RADIOLOGIE', 15, 5, 'Dr. Moreau Thomas'),
('Oncologie', 'Service d\'oncologie et chimiothérapie', 'ONCOLOGIE', 20, 6, 'Dr. Petit Marie'),
('Neurologie', 'Service de neurologie', 'NEUROLOGIE', 18, 4, 'Dr. Simon Jean');

-- ============================================================
-- 5. INSERTION DES PATIENTS
-- ============================================================
INSERT INTO patients (nom, prenom, numero_securite_sociale, date_naissance, sexe, adresse, telephone, email) VALUES
('Durand', 'Pierre', '1850465123456', '1985-04-15', 'M', '15 Rue de la Paix, 75001 Paris', '0601020304', 'pierre.durand@email.com'),
('Martin', 'Sophie', '2920378234567', '1992-03-28', 'F', '22 Avenue des Champs, 75008 Paris', '0602030405', 'sophie.martin@email.com'),
('Bernard', 'Luc', '1750612345678', '1975-06-12', 'M', '8 Boulevard Victor Hugo, 75015 Paris', '0603040506', 'luc.bernard@email.com'),
('Petit', 'Marie', '2880925456789', '1988-09-25', 'F', '33 Rue Saint-Denis, 75002 Paris', '0604050607', 'marie.petit@email.com'),
('Dubois', 'Jean', '1940518567890', '1994-05-18', 'M', '7 Place de la République, 75003 Paris', '0605060708', 'jean.dubois@email.com'),
('Moreau', 'Claire', '2870822678901', '1987-08-22', 'F', '12 Rue Lafayette, 75009 Paris', '0606070809', 'claire.moreau@email.com'),
('Laurent', 'Paul', '1961103789012', '1996-11-03', 'M', '45 Avenue Montaigne, 75008 Paris', '0607080910', 'paul.laurent@email.com'),
('Simon', 'Julie', '2900214890123', '1990-02-14', 'F', '18 Rue du Commerce, 75015 Paris', '0608091011', 'julie.simon@email.com'),
('Michel', 'Thomas', '1830707901234', '1983-07-07', 'M', '9 Boulevard Raspail, 75006 Paris', '0609101112', 'thomas.michel@email.com'),
('Leroy', 'Anne', '2950430012345', '1995-04-30', 'F', '21 Rue de Rivoli, 75004 Paris', '0610111213', 'anne.leroy@email.com'),
('Roux', 'Marc', '1980923123456', '1998-09-23', 'M', '5 Avenue Foch, 75016 Paris', '0611121314', 'marc.roux@email.com'),
('Fontaine', 'Emma', '2911205234567', '1991-12-05', 'F', '14 Rue Mouffetard, 75005 Paris', '0612131415', 'emma.fontaine@email.com'),
('Garnier', 'Lucas', '1860816345678', '1986-08-16', 'M', '28 Boulevard Haussmann, 75009 Paris', '0613141516', 'lucas.garnier@email.com'),
('Rousseau', 'Camille', '2930527456789', '1993-05-27', 'F', '6 Rue de Bretagne, 75003 Paris', '0614151617', 'camille.rousseau@email.com'),
('Vincent', 'Hugo', '1770309567890', '1977-03-09', 'M', '31 Avenue de la Grande Armée, 75017 Paris', '0615161718', 'hugo.vincent@email.com');

-- ============================================================
-- 6. INSERTION DES SÉJOURS
-- ============================================================
INSERT INTO sejours (patient_id, service_id, date_entree, date_sortie, motif, diagnostic, statut, numero_sejour, cout_total) VALUES
(1, 1, '2024-12-01 08:30:00', '2024-12-01 14:00:00', 'Douleur thoracique', 'Angine de poitrine', 'TERMINE', 'SEJ2024120001', 450.00),
(2, 2, '2024-12-05 09:00:00', '2024-12-12 10:00:00', 'Appendicite aiguë', 'Appendicectomie réussie', 'TERMINE', 'SEJ2024120002', 3500.00),
(3, 3, '2024-12-08 14:00:00', NULL, 'Insuffisance cardiaque', 'Surveillance continue', 'EN_COURS', 'SEJ2024120003', 2100.00),
(4, 4, '2024-12-10 10:30:00', NULL, 'Bronchite sévère', 'Traitement antibiotique', 'EN_COURS', 'SEJ2024120004', 680.00),
(5, 1, '2024-12-12 16:00:00', '2024-12-13 08:00:00', 'Fracture poignet', 'Fracture du radius', 'TERMINE', 'SEJ2024120005', 890.00),
(6, 5, '2024-12-11 03:00:00', '2024-12-14 11:00:00', 'Accouchement', 'Naissance césarienne', 'TERMINE', 'SEJ2024120006', 4200.00),
(7, 6, '2024-12-13 11:00:00', '2024-12-13 15:00:00', 'IRM cérébrale', 'Examen normal', 'TERMINE', 'SEJ2024120007', 520.00),
(8, 7, '2024-12-09 08:00:00', NULL, 'Chimiothérapie', 'Cancer du sein - cycle 3', 'EN_COURS', 'SEJ2024120008', 5600.00),
(9, 2, '2024-11-25 07:00:00', '2024-12-02 09:00:00', 'Hernie discale', 'Opération réussie', 'TERMINE', 'SEJ2024110001', 6800.00),
(10, 3, '2024-12-14 09:00:00', NULL, 'Infarctus du myocarde', 'Angioplastie urgente', 'EN_COURS', 'SEJ2024120009', 8900.00),
(11, 4, '2024-12-06 14:00:00', '2024-12-09 10:00:00', 'Gastro-entérite sévère', 'Réhydratation IV', 'TERMINE', 'SEJ2024120010', 720.00),
(12, 8, '2024-12-07 10:00:00', NULL, 'AVC ischémique', 'Traitement thrombolyse', 'EN_COURS', 'SEJ2024120011', 4500.00),
(13, 1, '2024-12-13 22:00:00', NULL, 'Traumatisme crânien', 'Observation 48h', 'EN_COURS', 'SEJ2024120012', 1200.00),
(14, 6, '2024-12-11 09:00:00', '2024-12-11 17:00:00', 'Scanner thoracique', 'Examen normal', 'TERMINE', 'SEJ2024120013', 380.00),
(15, 2, '2024-12-02 08:00:00', '2024-12-10 09:00:00', 'Prothèse de hanche', 'Opération réussie', 'TERMINE', 'SEJ2024120014', 12500.00);

-- ============================================================
-- 7. INSERTION DES ACTES MÉDICAUX
-- ============================================================
INSERT INTO actes_medicaux (sejour_id, code, libelle, type, date_realisation, tarif, medecin, notes) VALUES
-- Séjour 1 (Urgences)
(1, 'CONS001', 'Consultation urgence', 'CONSULTATION', '2024-12-01 08:30:00', 80.00, 'Dr. Martin', 'Patient stable'),
(1, 'ECG001', 'Électrocardiogramme', 'EXAMEN', '2024-12-01 09:00:00', 45.00, 'Dr. Martin', 'ECG normal'),
(1, 'RADIO01', 'Radiographie thorax', 'RADIOLOGIE', '2024-12-01 10:00:00', 75.00, 'Dr. Moreau', 'RAS'),

-- Séjour 2 (Appendicite)
(2, 'CHIR001', 'Appendicectomie sous cœlioscopie', 'CHIRURGIE', '2024-12-05 11:00:00', 2500.00, 'Dr. Dupont', 'Intervention réussie'),
(2, 'ANESTH1', 'Anesthésie générale', 'ANESTHESIE', '2024-12-05 10:30:00', 450.00, 'Dr. Anesthésiste', NULL),
(2, 'HOSPIT1', 'Hospitalisation 7 jours', 'HOSPITALISATION', '2024-12-05 00:00:00', 550.00, NULL, 'Chambre individuelle'),

-- Séjour 3 (Cardiologie)
(3, 'CONS002', 'Consultation cardiologie', 'CONSULTATION', '2024-12-08 14:00:00', 100.00, 'Dr. Lefevre', 'Insuffisance cardiaque confirmée'),
(3, 'ECHO001', 'Échographie cardiaque', 'EXAMEN', '2024-12-08 15:00:00', 180.00, 'Dr. Lefevre', 'Fraction d\'éjection 35%'),
(3, 'BIOL001', 'Bilan biologique complet', 'LABORATOIRE', '2024-12-08 16:00:00', 120.00, NULL, 'NT-proBNP élevé'),

-- Séjour 4 (Pédiatrie)
(4, 'CONS003', 'Consultation pédiatrie', 'CONSULTATION', '2024-12-10 10:30:00', 70.00, 'Dr. Rousseau', 'Enfant 8 ans'),
(4, 'RADIO02', 'Radiographie thorax', 'RADIOLOGIE', '2024-12-10 11:00:00', 65.00, 'Dr. Moreau', 'Foyer infectieux'),

-- Séjour 5 (Fracture)
(5, 'CONS004', 'Consultation traumatologie', 'CONSULTATION', '2024-12-12 16:00:00', 90.00, 'Dr. Martin', 'Fracture déplacée'),
(5, 'RADIO03', 'Radiographie poignet 2 incidences', 'RADIOLOGIE', '2024-12-12 16:30:00', 85.00, 'Dr. Moreau', 'Fracture radius distal'),
(5, 'CHIR002', 'Réduction orthopédique + plâtre', 'CHIRURGIE', '2024-12-12 17:00:00', 350.00, 'Dr. Traumato', 'Bonne réduction'),

-- Séjour 6 (Accouchement)
(6, 'OBSTET1', 'Accouchement par césarienne', 'CHIRURGIE', '2024-12-11 05:00:00', 3000.00, 'Dr. Lambert', 'Mère et bébé en bonne santé'),
(6, 'ANESTH2', 'Péridurale', 'ANESTHESIE', '2024-12-11 04:30:00', 300.00, 'Dr. Anesthésiste', NULL),
(6, 'HOSPIT2', 'Hospitalisation maternité 3 jours', 'HOSPITALISATION', '2024-12-11 00:00:00', 900.00, NULL, NULL),

-- Séjour 7 (IRM)
(7, 'IRM001', 'IRM cérébrale avec injection', 'RADIOLOGIE', '2024-12-13 11:30:00', 450.00, 'Dr. Moreau', 'Protocole standard'),
(7, 'CONS005', 'Consultation neurologie', 'CONSULTATION', '2024-12-13 14:00:00', 70.00, 'Dr. Simon', 'RAS'),

-- Séjour 8 (Chimiothérapie)
(8, 'CHIMIO1', 'Séance chimiothérapie cycle 3', 'TRAITEMENT', '2024-12-09 09:00:00', 4500.00, 'Dr. Petit', 'Protocole FEC'),
(8, 'BIOL002', 'Bilan pré-chimiothérapie', 'LABORATOIRE', '2024-12-09 08:00:00', 150.00, NULL, 'Hémogramme correct'),
(8, 'CONS006', 'Consultation oncologie', 'CONSULTATION', '2024-12-09 08:30:00', 120.00, 'Dr. Petit', 'Suivi cycle 3'),

-- Séjour 9 (Hernie discale)
(9, 'CHIR003', 'Discectomie L4-L5', 'CHIRURGIE', '2024-11-25 09:00:00', 5500.00, 'Dr. Neurochirurgien', 'Décompression réussie'),
(9, 'ANESTH3', 'Anesthésie générale', 'ANESTHESIE', '2024-11-25 08:30:00', 500.00, 'Dr. Anesthésiste', NULL),
(9, 'HOSPIT3', 'Hospitalisation 7 jours', 'HOSPITALISATION', '2024-11-25 00:00:00', 800.00, NULL, NULL),

-- Séjour 10 (Infarctus)
(10, 'URGENC1', 'Prise en charge USIC', 'URGENCE', '2024-12-14 09:00:00', 500.00, 'Dr. Lefevre', 'Infarctus STEMI'),
(10, 'CORO001', 'Coronarographie + angioplastie', 'CHIRURGIE', '2024-12-14 10:00:00', 7500.00, 'Dr. Cardiologue interventionnel', '2 stents posés'),
(10, 'BIOL003', 'Bilan troponine sérié', 'LABORATOIRE', '2024-12-14 09:15:00', 180.00, NULL, 'Troponine élevée'),

-- Séjour 11 (Gastro-entérite)
(11, 'CONS007', 'Consultation pédiatrie urgence', 'CONSULTATION', '2024-12-06 14:00:00', 75.00, 'Dr. Rousseau', 'Déshydratation modérée'),
(11, 'PERFUS1', 'Réhydratation IV 3 jours', 'TRAITEMENT', '2024-12-06 14:30:00', 350.00, 'Inf. Bernard', 'Amélioration rapide'),

-- Séjour 12 (AVC)
(12, 'URGENC2', 'Prise en charge AVC', 'URGENCE', '2024-12-07 10:00:00', 400.00, 'Dr. Simon', 'AVC ischémique < 4h'),
(12, 'IRM002', 'IRM cérébrale urgente', 'RADIOLOGIE', '2024-12-07 10:30:00', 550.00, 'Dr. Moreau', 'Confirmation AVC'),
(12, 'THROMB1', 'Thrombolyse IV', 'TRAITEMENT', '2024-12-07 11:00:00', 3500.00, 'Dr. Simon', 'rtPA administré'),

-- Séjour 13 (Traumatisme)
(13, 'URGENC3', 'Consultation urgence trauma', 'URGENCE', '2024-12-13 22:00:00', 100.00, 'Dr. Martin', 'Glasgow 14'),
(13, 'SCAN001', 'Scanner cérébral', 'RADIOLOGIE', '2024-12-13 22:30:00', 380.00, 'Dr. Moreau', 'Pas d\'hémorragie'),
(13, 'HOSPIT4', 'Surveillance continue 48h', 'HOSPITALISATION', '2024-12-13 23:00:00', 720.00, NULL, 'UHCD'),

-- Séjour 14 (Scanner thoracique)
(14, 'SCAN002', 'Scanner thoracique avec injection', 'RADIOLOGIE', '2024-12-11 10:00:00', 320.00, 'Dr. Moreau', 'Examen normal'),
(14, 'CONS008', 'Consultation pneumologie', 'CONSULTATION', '2024-12-11 16:00:00', 60.00, 'Dr. Pneumologue', 'RAS'),

-- Séjour 15 (Prothèse hanche)
(15, 'CHIR004', 'Prothèse totale de hanche', 'CHIRURGIE', '2024-12-02 09:00:00', 10000.00, 'Dr. Orthopédiste', 'PTH cimentée'),
(15, 'ANESTH4', 'Rachianesthésie', 'ANESTHESIE', '2024-12-02 08:30:00', 400.00, 'Dr. Anesthésiste', NULL),
(15, 'HOSPIT5', 'Hospitalisation 8 jours + rééducation', 'HOSPITALISATION', '2024-12-02 00:00:00', 1200.00, NULL, 'Rééducation intensive');

-- ============================================================
-- 8. INSERTION DES INVESTISSEMENTS
-- ============================================================
INSERT INTO investments (nom, categorie, description, montant, date_investissement, date_fin_prevue, statut, fournisseur, responsable, benefices_attendus, retour_investissement) VALUES
('Nouveau scanner IRM', 'EQUIPEMENT', 'Acquisition d\'un scanner IRM de dernière génération pour le service de radiologie.', 450000.00, '2024-01-15', '2025-12-31', 'EN_COURS', 'Siemens Medical', 'Dr. Radiology', 'Amélioration des diagnostics, réduction des temps d\'attente', 18.0),
('Rénovation bloc opératoire', 'INFRASTRUCTURE', 'Modernisation complète du bloc opératoire principal.', 280000.00, '2024-06-01', '2026-06-30', 'PLANIFIE', 'Construction Médicale SA', 'Direction Technique', 'Augmentation de la capacité chirurgicale', 12.0),
('Système de gestion informatisé', 'TECHNOLOGIE', 'Mise en place d\'un système de gestion des dossiers patients nouvelle génération.', 125000.00, '2024-09-01', '2025-03-31', 'EN_COURS', 'SoftMed Solutions', 'DSI', 'Optimisation des processus, réduction des erreurs', 25.0),
('Formation continue du personnel', 'FORMATION', 'Programme de formation continue pour l\'ensemble du personnel soignant sur 12 mois.', 85000.00, '2024-11-01', '2025-11-30', 'EN_COURS', 'Institut Formation Santé', 'DRH', 'Amélioration de la qualité des soins', 15.0),
('Extension service urgences', 'INFRASTRUCTURE', 'Agrandissement et modernisation du service des urgences.', 550000.00, '2023-03-15', '2024-08-31', 'TERMINE', 'BTP Santé', 'Direction Générale', 'Augmentation de 40% de la capacité d\'accueil', 20.0),
('Équipement télémédecine', 'TECHNOLOGIE', 'Déploiement de solutions de télémédecine dans tous les services.', 95000.00, '2023-09-01', '2024-02-29', 'TERMINE', 'TeleMed Pro', 'DSI', 'Suivi à distance des patients chroniques', 22.0),
('Robot chirurgical Da Vinci', 'EQUIPEMENT', 'Acquisition robot chirurgical dernière génération', 1200000.00, '2025-01-01', '2025-12-31', 'PLANIFIE', 'Intuitive Surgical', 'Direction Médicale', 'Chirurgie mini-invasive de précision', 15.0),
('Système IA diagnostic', 'TECHNOLOGIE', 'Solution d\'intelligence artificielle pour aide au diagnostic', 180000.00, '2024-10-01', '2025-06-30', 'EN_COURS', 'MedTech AI', 'DSI', 'Détection précoce des pathologies', 30.0);

-- ============================================================
-- 9. INSERTION DES ALERTES
-- ============================================================
INSERT INTO alerts (titre, message, type, priorite, categorie, lu, resolu, assignee_a, date_resolution, commentaire, created_at) VALUES
('Dépassement budgétaire prévu de 12%', 'Le service Chirurgie montre une tendance de dépassement significative due à une augmentation du nombre d\'interventions complexes.', 'ERROR', 'CRITIQUE', 'FINANCIER', false, false, 'Direction Financière', NULL, NULL, '2024-12-14 14:30:00'),
('Consommation anormale de matériel médical', 'Une augmentation de 35% de la consommation de matériel médical a été détectée par rapport à la moyenne aux Urgences.', 'WARNING', 'HAUTE', 'MEDICAL', false, false, 'Responsable Achats', NULL, 'Analyse en cours par le responsable des achats', '2024-12-14 10:15:00'),
('Coûts de maintenance supérieurs à la normale', 'Les coûts de maintenance des équipements d\'imagerie sont 20% plus élevés que prévu ce mois-ci en Radiologie.', 'WARNING', 'MOYENNE', 'TECHNIQUE', false, false, 'Service Biomédical', NULL, NULL, '2024-12-13 16:45:00'),
('Capacité maximale atteinte', 'Le service Maternité a atteint 98% de sa capacité d\'accueil. Prévoir une gestion des admissions.', 'ERROR', 'HAUTE', 'MEDICAL', false, false, 'Dr. Maternité', NULL, NULL, '2024-12-14 08:20:00'),
('Budget annuel respecté', 'Le service Pédiatrie maintient son budget dans les limites prévues avec une marge de 3%.', 'SUCCESS', 'BASSE', 'FINANCIER', true, true, NULL, '2024-12-10 14:00:00', 'Objectifs respectés', '2024-12-10 09:00:00'),
('Maintenance préventive planifiée', 'Maintenance du système informatique prévue le 20 décembre de 22h à 2h.', 'INFO', 'MOYENNE', 'TECHNIQUE', true, false, 'DSI', NULL, NULL, '2024-12-12 11:30:00'),
('Satisfaction patients en hausse', 'Le taux de satisfaction des patients du service Cardiologie est passé de 87% à 92%.', 'SUCCESS', 'BASSE', 'MEDICAL', true, true, NULL, '2024-12-11 15:00:00', NULL, '2024-12-11 09:00:00'),
('Stock de médicaments critique', 'Le stock d\'antibiotiques critiques est inférieur au seuil de sécurité (15 jours restants).', 'ERROR', 'CRITIQUE', 'MEDICAL', false, false, 'Pharmacie', NULL, NULL, '2024-12-14 07:45:00'),
('Turnover du personnel élevé', 'Le taux de turnover du service Urgences a augmenté de 5% ce trimestre.', 'WARNING', 'MOYENNE', 'ADMINISTRATIF', false, false, 'DRH', NULL, NULL, '2024-12-13 13:20:00'),
('Certification HAS obtenue', 'Le service Chirurgie a obtenu la certification HAS avec mention Très Satisfaisant.', 'SUCCESS', 'BASSE', 'ADMINISTRATIF', true, true, NULL, '2024-12-09 16:00:00', NULL, '2024-12-09 10:00:00'),
('Délai d\'attente Urgences élevé', 'Le délai d\'attente moyen aux Urgences a dépassé 3h ce weekend.', 'WARNING', 'HAUTE', 'MEDICAL', false, false, 'Chef Service Urgences', NULL, NULL, '2024-12-14 06:00:00'),
('Nouvel équipement opérationnel', 'Le nouveau scanner IRM est maintenant pleinement opérationnel.', 'SUCCESS', 'BASSE', 'TECHNIQUE', true, true, NULL, '2024-12-12 10:00:00', 'Formation du personnel terminée', '2024-12-12 08:00:00');

-- ============================================================
-- 10. INSERTION DES RAPPORTS
-- ============================================================
INSERT INTO reports (titre, type, periode, resume, date_debut, date_fin, genere_par, donnees_principales, conclusions, recommandations, statut) VALUES
('Rapport mensuel - Novembre 2024', 'FINANCIER', 'MENSUEL', 'Analyse financière complète du mois de novembre 2024', '2024-11-01', '2024-11-30', 'Système', 
    '{"revenus": 1250000, "depenses": 1180000, "marge": 70000, "patients": 1580}', 
    'Performance financière conforme aux objectifs avec une marge bénéficiaire de 5.6%.', 
    'Maintenir les efforts sur l\'optimisation des coûts opérationnels.', 'PUBLIE'),

('Prévisions financières Q1 2026', 'FINANCIER', 'ANNUEL', 'Prévisions et projections financières pour le premier trimestre 2026', '2026-01-01', '2026-03-31', 'Direction Financière', 
    '{"previsionsRevenus": 3800000, "previsionsDepenses": 3550000}', 
    'Prévision d\'une croissance de 8% des revenus par rapport à Q1 2025.', 
    'Anticiper les investissements nécessaires pour soutenir la croissance.', 'PUBLIE'),

('Analyse des anomalies - Octobre 2024', 'QUALITE', 'MENSUEL', 'Détection et analyse des anomalies financières d\'octobre 2024', '2024-10-01', '2024-10-31', 'Contrôle Qualité', 
    '{"anomaliesDetectees": 12, "anomaliesResolues": 10}', 
    '12 anomalies détectées dont 10 ont été résolues. Taux de résolution: 83%.', 
    'Renforcer les contrôles préventifs pour réduire les anomalies récurrentes.', 'PUBLIE'),

('Rapport budgétaire annuel 2024', 'FINANCIER', 'ANNUEL', 'Bilan financier complet de l\'année 2024', '2024-01-01', '2024-12-31', 'Direction Financière', 
    '{"revenuAnnuel": 14800000, "depenseAnnuelle": 13950000}', 
    'Année 2024 positive avec un bénéfice net de 850000€ (5.7% de marge).', 
    'Poursuivre la stratégie de croissance tout en maintenant la maîtrise des coûts.', 'BROUILLON'),

('Analyse comparative des services', 'ACTIVITE', 'ANNUEL', 'Comparaison des performances entre les différents services hospitaliers', '2024-01-01', '2024-12-31', 'Direction Médicale', 
    '{"services": 8, "indicateurs": 15}', 
    'Chirurgie et Cardiologie affichent les meilleures performances. Urgences nécessite un renforcement.', 
    'Allouer des ressources supplémentaires au service Urgences.', 'PUBLIE'),

('Rapport de satisfaction patients Q4', 'QUALITE', 'ANNUEL', 'Enquête de satisfaction auprès des patients du 4ème trimestre', '2024-10-01', '2024-12-31', 'Service Qualité', 
    '{"tauxSatisfaction": 88, "repondants": 450}', 
    'Taux de satisfaction global de 88%, en hausse de 3 points par rapport à Q3.', 
    'Continuer les efforts d\'amélioration de la qualité d\'accueil.', 'PUBLIE'),

('Performance Décembre 2024', 'ACTIVITE', 'MENSUEL', 'Activité médicale et financière de décembre 2024', '2024-12-01', '2024-12-14', 'Système',
    '{"patients": 156, "actes": 78, "revenus": 145230, "tauxOccupation": 87}',
    'Forte activité en chirurgie et cardiologie. Taux d\'occupation élevé.',
    'Anticiper les besoins en personnel pour les fêtes.', 'BROUILLON');

-- ============================================================
-- 11. INSERTION DES PRÉDICTIONS
-- ============================================================
INSERT INTO predictions (type, titre, description, periode_prevue, donnees_historiques, resultat_prediction, confiance, methodologie, facteurs_cles, recommandations, genere_par) VALUES
('REVENUS', 'Prévision revenus Janvier-Juin 2025', 'Prédiction des revenus pour le premier semestre 2025 basée sur les tendances actuelles', '2025-06-30', 
    '{"decembre": 625000, "baseline": 610000}', 
    '{"janvier": 630000, "fevrier": 645000, "mars": 655000, "avril": 640000, "mai": 660000, "juin": 670000, "tendance": "HAUSSE", "intervalleConfiance": {"min": 600000, "max": 690000}}', 
    91.5, 'Analyse prédictive basée sur séries temporelles et facteurs saisonniers', 
    'Volume d\'activité, Saisonnalité, Tendances historiques', 
    'Anticiper une hausse progressive des revenus. Prévoir les ressources nécessaires.', 'Système IA'),

('PATIENTS', 'Affluence par service - Prochains mois', 'Prévision du nombre de patients par service pour les 3 prochains mois', '2025-03-31', 
    '{"urgences": 120000, "chirurgie": 180000, "cardiologie": 95000, "pediatrie": 75000, "radiologie": 85000, "maternite": 55000}', 
    '{"urgences": {"prediction": 128000, "variation": 6.7, "risque": "MOYENNE"}, "chirurgie": {"prediction": 195000, "variation": 8.3, "risque": "HAUTE"}, "cardiologie": {"prediction": 98000, "variation": 3.2, "risque": "BASSE"}, "pediatrie": {"prediction": 77000, "variation": 2.7, "risque": "BASSE"}, "radiologie": {"prediction": 89000, "variation": 4.7, "risque": "MOYENNE"}, "maternite": {"prediction": 57000, "variation": 3.6, "risque": "BASSE"}}', 
    88.2, 'Modèle prédictif multi-services avec analyse des tendances par spécialité', 
    'Capacité des services, Saisonnalité, Événements épidémiologiques', 
    'Chirurgie nécessite une attention particulière (variation +8.3%). Prévoir renforcement des équipes.', 'Système IA'),

('COUTS', 'Prévision coûts opérationnels Q1 2025', 'Estimation des coûts opérationnels pour le premier trimestre 2025', '2025-03-31', 
    '{"coutsMoyensActuels": 1150000, "tendance": "STABLE"}', 
    '{"janvier": 1180000, "fevrier": 1175000, "mars": 1190000, "total": 3545000, "tendance": "HAUSSE_LEGERE"}', 
    86.8, 'Projection basée sur historique des coûts et inflation prévue', 
    'Masse salariale, Consommables médicaux, Énergie, Inflation', 
    'Anticiper une hausse modérée de 2.5%. Optimiser les achats groupés.', 'Système IA'),

('ACTIVITE', 'Volume d\'actes médicaux 2025', 'Prévision du nombre d\'actes médicaux par type pour 2025', '2025-12-31',
    '{"chirurgie": 1200, "consultation": 4500, "radiologie": 2300, "laboratoire": 5600}',
    '{"chirurgie": 1320, "consultation": 4950, "radiologie": 2530, "laboratoire": 6160, "croissance": 10}',
    89.3, 'Modèle de régression basé sur historique 3 ans',
    'Démographie, Épidémiologie, Capacité des services',
    'Prévoir augmentation de 10% des actes. Renforcer les équipes techniques.', 'Système IA');

-- ============================================================
-- 12. INSERTION DES PARAMÈTRES
-- ============================================================
INSERT INTO settings (cle, valeur, type, description) VALUES
('app.nom', 'Healthcare Dashboard', 'STRING', 'Nom de l\'application'),
('app.version', '1.0.0', 'STRING', 'Version de l\'application'),
('hospital.nom', 'Centre Hospitalier Universitaire', 'STRING', 'Nom de l\'établissement'),
('hospital.adresse', '123 Avenue de la Santé, 75000 Paris', 'STRING', 'Adresse de l\'établissement'),
('hospital.telephone', '01 23 45 67 89', 'STRING', 'Téléphone principal'),
('dashboard.refresh_interval', '60', 'NUMBER', 'Intervalle de rafraîchissement en secondes'),
('alerts.critiques_enabled', 'true', 'BOOLEAN', 'Activer les alertes critiques'),
('ai.enabled', 'true', 'BOOLEAN', 'Activer l\'assistant IA'),
('reports.auto_generation', 'true', 'BOOLEAN', 'Génération automatique des rapports');

-- ============================================================
-- STATISTIQUES FINALES
-- ============================================================
SELECT '======================================== DONNÉES INSÉRÉES ========================================' AS '';
SELECT COUNT(*) AS 'Rôles' FROM roles;
SELECT COUNT(*) AS 'Utilisateurs' FROM users;
SELECT COUNT(*) AS 'Services' FROM services;
SELECT COUNT(*) AS 'Patients' FROM patients;
SELECT COUNT(*) AS 'Séjours' FROM sejours;
SELECT COUNT(*) AS 'Actes médicaux' FROM actes_medicaux;
SELECT COUNT(*) AS 'Investissements' FROM investments;
SELECT COUNT(*) AS 'Alertes' FROM alerts;
SELECT COUNT(*) AS 'Rapports' FROM reports;
SELECT COUNT(*) AS 'Prédictions' FROM predictions;
SELECT COUNT(*) AS 'Paramètres' FROM settings;
SELECT '===================================================================================================' AS '';
SELECT 'BASE DE DONNÉES INITIALISÉE AVEC SUCCÈS!' AS 'STATUS';
