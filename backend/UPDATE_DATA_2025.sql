-- ============================================================
-- SCRIPT DE MISE À JOUR DES DONNÉES POUR 2025
-- Ajoute des données réalistes pour l'année 2025
-- ============================================================

USE healthcare_dashboard;

-- ============================================================
-- 1. INSERTION DE NOUVEAUX SÉJOURS EN 2025
-- ============================================================
-- Supprimer les séjours 2025 existants s'ils existent
DELETE FROM sejours WHERE numero_sejour LIKE 'SEJ2025%';

INSERT INTO sejours (patient_id, service_id, date_entree, date_sortie, motif, diagnostic, statut, numero_sejour, cout_total) VALUES
-- Janvier 2025
(1, 2, '2025-01-05 09:00:00', '2025-01-08 10:00:00', 'Cholécystectomie', 'Calculs biliaires', 'TERMINE', 'SEJ2025010001', 2800.00),
(3, 3, '2025-01-10 14:00:00', '2025-01-15 10:00:00', 'Arythmie cardiaque', 'Fibrillation auriculaire', 'TERMINE', 'SEJ2025010002', 3200.00),
(5, 1, '2025-01-15 20:00:00', '2025-01-16 08:00:00', 'Intoxication alimentaire', 'Gastro-entérite aiguë', 'TERMINE', 'SEJ2025010003', 420.00),

-- Février 2025
(2, 4, '2025-02-03 11:00:00', '2025-02-06 09:00:00', 'Pneumonie', 'Pneumonie bactérienne', 'TERMINE', 'SEJ2025020001', 1200.00),
(7, 5, '2025-02-14 02:00:00', '2025-02-17 11:00:00', 'Accouchement naturel', 'Naissance normale', 'TERMINE', 'SEJ2025020002', 2500.00),
(9, 2, '2025-02-20 08:00:00', '2025-02-27 10:00:00', 'Prothèse genou', 'Arthrose sévère', 'TERMINE', 'SEJ2025020003', 11000.00),

-- Mars 2025
(4, 6, '2025-03-05 10:00:00', '2025-03-05 16:00:00', 'IRM lombaire', 'Lombalgie chronique', 'TERMINE', 'SEJ2025030001', 480.00),
(6, 7, '2025-03-12 09:00:00', '2025-03-19 10:00:00', 'Chimiothérapie cycle 1', 'Cancer du côlon', 'TERMINE', 'SEJ2025030002', 5800.00),
(11, 3, '2025-03-18 16:00:00', '2025-03-23 09:00:00', 'Angor instable', 'Coronaropathie', 'TERMINE', 'SEJ2025030003', 4500.00),

-- Avril 2025
(8, 1, '2025-04-02 18:00:00', '2025-04-03 10:00:00', 'Entorse cheville', 'Entorse grade 2', 'TERMINE', 'SEJ2025040001', 320.00),
(12, 8, '2025-04-10 09:00:00', '2025-04-15 10:00:00', 'Crise épileptique', 'Épilepsie généralisée', 'TERMINE', 'SEJ2025040002', 2100.00),
(14, 4, '2025-04-22 15:00:00', '2025-04-25 10:00:00', 'Asthme sévère', 'Crise asthmatique', 'TERMINE', 'SEJ2025040003', 890.00),

-- Mai 2025
(10, 2, '2025-05-08 08:00:00', '2025-05-15 09:00:00', 'Hernie inguinale', 'Cure herniaire', 'TERMINE', 'SEJ2025050001', 3400.00),
(13, 6, '2025-05-14 11:00:00', '2025-05-14 17:00:00', 'Scanner abdominal', 'Douleurs abdominales', 'TERMINE', 'SEJ2025050002', 410.00),
(15, 5, '2025-05-20 04:00:00', '2025-05-23 10:00:00', 'Césarienne urgence', 'Souffrance fœtale', 'TERMINE', 'SEJ2025050003', 3800.00),

-- Juin 2025
(1, 7, '2025-06-05 10:00:00', '2025-06-12 09:00:00', 'Chimiothérapie cycle 4', 'Lymphome', 'TERMINE', 'SEJ2025060001', 6200.00),
(3, 3, '2025-06-15 13:00:00', '2025-06-20 10:00:00', 'Insuffisance cardiaque', 'Décompensation cardiaque', 'TERMINE', 'SEJ2025060002', 3800.00),
(9, 1, '2025-06-25 21:00:00', '2025-06-26 09:00:00', 'Plaie profonde main', 'Suture complexe', 'TERMINE', 'SEJ2025060003', 580.00),

-- Juillet 2025
(5, 2, '2025-07-03 09:00:00', '2025-07-10 10:00:00', 'Coloscopie + polypectomie', 'Polypes coliques', 'TERMINE', 'SEJ2025070001', 2900.00),
(7, 4, '2025-07-18 14:00:00', '2025-07-21 10:00:00', 'Méningite virale', 'Syndrome méningé', 'TERMINE', 'SEJ2025070002', 1800.00),
(11, 6, '2025-07-22 09:00:00', '2025-07-22 15:00:00', 'Échographie Doppler', 'Surveillance vasculaire', 'TERMINE', 'SEJ2025070003', 280.00),

-- Août 2025
(2, 1, '2025-08-05 16:00:00', '2025-08-06 08:00:00', 'Crise d\'asthme', 'Exacerbation asthmatique', 'TERMINE', 'SEJ2025080001', 380.00),
(4, 5, '2025-08-12 03:00:00', '2025-08-15 10:00:00', 'Accouchement prématuré', 'Prématurité 35 SA', 'TERMINE', 'SEJ2025080002', 4200.00),
(8, 8, '2025-08-20 10:00:00', '2025-08-25 09:00:00', 'AIT', 'Accident ischémique transitoire', 'TERMINE', 'SEJ2025080003', 2600.00),

-- Septembre 2025
(6, 2, '2025-09-02 08:00:00', '2025-09-09 10:00:00', 'Thyroïdectomie', 'Nodule thyroïdien', 'TERMINE', 'SEJ2025090001', 4100.00),
(10, 3, '2025-09-15 11:00:00', '2025-09-22 09:00:00', 'Pontage coronarien', 'Sténose coronaire', 'TERMINE', 'SEJ2025090002', 18000.00),
(12, 7, '2025-09-25 09:00:00', NULL, 'Chimiothérapie cycle 2', 'Cancer pancréas', 'EN_COURS', 'SEJ2025090003', 7200.00),

-- Octobre 2025
(13, 1, '2025-10-08 19:00:00', '2025-10-09 08:00:00', 'Brûlure 2e degré', 'Brûlure thermique', 'TERMINE', 'SEJ2025100001', 520.00),
(14, 4, '2025-10-12 16:00:00', '2025-10-15 10:00:00', 'Convulsion fébrile', 'Hyperthermie', 'TERMINE', 'SEJ2025100002', 680.00),
(15, 6, '2025-10-20 10:00:00', '2025-10-20 16:00:00', 'Mammographie + échographie', 'Dépistage', 'TERMINE', 'SEJ2025100003', 320.00),

-- Novembre 2025
(1, 2, '2025-11-05 09:00:00', '2025-11-12 10:00:00', 'Prothèse épaule', 'Omarthrose', 'TERMINE', 'SEJ2025110001', 13500.00),
(3, 8, '2025-11-10 14:00:00', '2025-11-17 09:00:00', 'Sclérose en plaques', 'Poussée SEP', 'TERMINE', 'SEJ2025110002', 3200.00),
(5, 3, '2025-11-18 10:00:00', '2025-11-25 09:00:00', 'Valvulopathie', 'Remplacement valve aortique', 'TERMINE', 'SEJ2025110003', 22000.00),

-- Décembre 2025 (mois courant)
(2, 1, '2025-12-02 10:00:00', '2025-12-03 08:00:00', 'Migraine sévère', 'Céphalée en grappe', 'TERMINE', 'SEJ2025120001', 280.00),
(4, 2, '2025-12-05 08:00:00', '2025-12-12 10:00:00', 'Péritonite', 'Appendicite perforée', 'TERMINE', 'SEJ2025120002', 4800.00),
(6, 3, '2025-12-08 15:00:00', NULL, 'Décompensation cardiaque', 'Insuffisance cardiaque aiguë', 'EN_COURS', 'SEJ2025120003', 3500.00),
(7, 4, '2025-12-10 11:00:00', '2025-12-13 10:00:00', 'Bronchiolite', 'Infection respiratoire', 'TERMINE', 'SEJ2025120004', 920.00),
(9, 5, '2025-12-12 01:00:00', NULL, 'Travail en cours', 'Accouchement imminent', 'EN_COURS', 'SEJ2025120005', 2800.00),
(11, 6, '2025-12-14 09:00:00', '2025-12-14 15:00:00', 'IRM cérébrale', 'Céphalées chroniques', 'TERMINE', 'SEJ2025120006', 520.00),
(13, 7, '2025-12-09 08:00:00', NULL, 'Chimiothérapie cycle 5', 'Cancer sein', 'EN_COURS', 'SEJ2025120007', 5600.00),
(14, 8, '2025-12-11 13:00:00', NULL, 'Paralysie faciale', 'Paralysie a frigore', 'EN_COURS', 'SEJ2025120008', 1400.00),
(15, 1, '2025-12-13 22:00:00', NULL, 'Accident voiture', 'Polytraumatisme', 'EN_COURS', 'SEJ2025120009', 3200.00);

-- ============================================================
-- 2. INSERTION DES ACTES MÉDICAUX 2025
-- ============================================================

-- Supprimer d'abord les actes existants pour les séjours 2025
DELETE FROM actes_medicaux WHERE sejour_id IN (SELECT id FROM sejours WHERE numero_sejour LIKE 'SEJ2025%');

-- Actes pour décembre 2025 (utiliser les numéros de séjour pour retrouver les IDs)
INSERT INTO actes_medicaux (sejour_id, code, libelle, type, date_realisation, tarif, medecin, notes)
SELECT s.id, 'CONS020', 'Consultation urgence neurologie', 'CONSULTATION', '2025-12-02 10:00:00', 95.00, 'Dr. Simon', 'Migraine sévère'
FROM sejours s WHERE s.numero_sejour = 'SEJ2025120001'
UNION ALL
SELECT s.id, 'PERFUS2', 'Perfusion analgésique', 'TRAITEMENT', '2025-12-02 11:00:00', 185.00, 'Inf. Bernard', 'Amélioration rapide'
FROM sejours s WHERE s.numero_sejour = 'SEJ2025120001'

UNION ALL SELECT s.id, 'CHIR010', 'Appendicectomie en urgence', 'CHIRURGIE', '2025-12-05 10:00:00', 3200.00, 'Dr. Dupont', 'Péritonite localisée' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120002'
UNION ALL SELECT s.id, 'ANESTH5', 'Anesthésie générale urgence', 'ANESTHESIE', '2025-12-05 09:30:00', 550.00, 'Dr. Anesthésiste', NULL FROM sejours s WHERE s.numero_sejour = 'SEJ2025120002'
UNION ALL SELECT s.id, 'HOSPIT6', 'Hospitalisation 7 jours USI', 'HOSPITALISATION', '2025-12-05 00:00:00', 1050.00, NULL, 'Surveillance rapprochée' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120002'

UNION ALL SELECT s.id, 'CONS021', 'Consultation cardiologie urgence', 'CONSULTATION', '2025-12-08 15:00:00', 110.00, 'Dr. Lefevre', 'Décompensation aiguë' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120003'
UNION ALL SELECT s.id, 'ECHO002', 'Échographie cardiaque', 'EXAMEN', '2025-12-08 16:00:00', 190.00, 'Dr. Lefevre', 'FEVG 30%' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120003'
UNION ALL SELECT s.id, 'BIOL004', 'Bilan biologique complet', 'LABORATOIRE', '2025-12-08 17:00:00', 130.00, NULL, 'BNP très élevé' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120003'
UNION ALL SELECT s.id, 'PERFUS3', 'Traitement IV diurétiques', 'TRAITEMENT', '2025-12-09 08:00:00', 220.00, 'Dr. Lefevre', 'Furosémide' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120003'

UNION ALL SELECT s.id, 'CONS022', 'Consultation pédiatrie urgence', 'CONSULTATION', '2025-12-10 11:00:00', 75.00, 'Dr. Rousseau', 'Détresse respiratoire' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120004'
UNION ALL SELECT s.id, 'RADIO04', 'Radiographie thorax', 'RADIOLOGIE', '2025-12-10 12:00:00', 70.00, 'Dr. Moreau', 'Bronchiolite confirmée' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120004'
UNION ALL SELECT s.id, 'OXYGENO', 'Oxygénothérapie 3 jours', 'TRAITEMENT', '2025-12-10 13:00:00', 420.00, 'Inf. Bernard', 'SpO2 normalisée' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120004'
UNION ALL SELECT s.id, 'HOSPIT7', 'Hospitalisation pédiatrie', 'HOSPITALISATION', '2025-12-10 00:00:00', 355.00, NULL, NULL FROM sejours s WHERE s.numero_sejour = 'SEJ2025120004'

UNION ALL SELECT s.id, 'CONS023', 'Consultation obstétrique', 'CONSULTATION', '2025-12-12 01:00:00', 90.00, 'Dr. Lambert', 'Travail phase active' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120005'
UNION ALL SELECT s.id, 'MONITOR', 'Monitoring fœtal continu', 'EXAMEN', '2025-12-12 02:00:00', 180.00, 'Sage-femme', 'RCF normal' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120005'
UNION ALL SELECT s.id, 'PERIDUL', 'Analgésie péridurale', 'ANESTHESIE', '2025-12-12 03:00:00', 320.00, 'Dr. Anesthésiste', 'Analgésie efficace' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120005'

UNION ALL SELECT s.id, 'IRM003', 'IRM cérébrale avec injection', 'RADIOLOGIE', '2025-12-14 10:00:00', 460.00, 'Dr. Moreau', 'Examen normal' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120006'
UNION ALL SELECT s.id, 'CONS024', 'Consultation neurologie', 'CONSULTATION', '2025-12-14 14:00:00', 60.00, 'Dr. Simon', 'Céphalées de tension' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120006'

UNION ALL SELECT s.id, 'CHIMIO2', 'Séance chimiothérapie cycle 5', 'TRAITEMENT', '2025-12-09 09:00:00', 4800.00, 'Dr. Petit', 'Protocole AC-T' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120007'
UNION ALL SELECT s.id, 'BIOL005', 'Bilan pré-chimiothérapie', 'LABORATOIRE', '2025-12-09 08:00:00', 160.00, NULL, 'NFS correcte' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120007'
UNION ALL SELECT s.id, 'CONS025', 'Consultation oncologie', 'CONSULTATION', '2025-12-09 08:30:00', 125.00, 'Dr. Petit', 'Tolérance correcte' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120007'
UNION ALL SELECT s.id, 'ANTIEMSE', 'Traitement anti-émétique', 'TRAITEMENT', '2025-12-09 10:00:00', 85.00, 'Inf. Bernard', 'Prévention nausées' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120007'

UNION ALL SELECT s.id, 'CONS026', 'Consultation neurologie urgence', 'CONSULTATION', '2025-12-11 13:00:00', 100.00, 'Dr. Simon', 'Paralysie faciale périphérique' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120008'
UNION ALL SELECT s.id, 'IRM004', 'IRM cérébrale et de l\'oreille interne', 'RADIOLOGIE', '2025-12-11 15:00:00', 580.00, 'Dr. Moreau', 'Pas de lésion' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120008'
UNION ALL SELECT s.id, 'CORTICO', 'Corticothérapie 7 jours', 'TRAITEMENT', '2025-12-11 17:00:00', 220.00, 'Dr. Simon', 'Prednisolone' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120008'
UNION ALL SELECT s.id, 'REEDUCATION', 'Séances de rééducation faciale', 'TRAITEMENT', '2025-12-12 09:00:00', 280.00, 'Kinésithérapeute', '3 séances' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120008'

UNION ALL SELECT s.id, 'URGENC4', 'Prise en charge polytraumatisme', 'URGENCE', '2025-12-13 22:00:00', 650.00, 'Dr. Martin', 'Patient stable' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120009'
UNION ALL SELECT s.id, 'SCAN003', 'Scanner corps entier', 'RADIOLOGIE', '2025-12-13 22:30:00', 780.00, 'Dr. Moreau', 'Fractures multiples' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120009'
UNION ALL SELECT s.id, 'CHIR011', 'Ostéosynthèse fémur', 'CHIRURGIE', '2025-12-14 01:00:00', 4500.00, 'Dr. Orthopédiste', 'Enclouage centromédullaire' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120009'
UNION ALL SELECT s.id, 'ANESTH6', 'Anesthésie générale', 'ANESTHESIE', '2025-12-14 00:30:00', 580.00, 'Dr. Anesthésiste', NULL FROM sejours s WHERE s.numero_sejour = 'SEJ2025120009';

-- ============================================================
-- Actes pour janvier à novembre 2025
-- ============================================================

INSERT INTO actes_medicaux (sejour_id, code, libelle, type, date_realisation, tarif, medecin, notes)
SELECT s.id, 'CHIR005', 'Cholécystectomie cœlioscopique', 'CHIRURGIE', '2025-01-05 10:00:00', 2100.00, 'Dr. Dupont', 'Intervention standard' FROM sejours s WHERE s.numero_sejour = 'SEJ2025010001'
UNION ALL SELECT s.id, 'ANESTH7', 'Anesthésie générale', 'ANESTHESIE', '2025-01-05 09:30:00', 400.00, 'Dr. Anesthésiste', NULL FROM sejours s WHERE s.numero_sejour = 'SEJ2025010001'
UNION ALL SELECT s.id, 'HOSPIT8', 'Hospitalisation 3 jours', 'HOSPITALISATION', '2025-01-05 00:00:00', 300.00, NULL, NULL FROM sejours s WHERE s.numero_sejour = 'SEJ2025010001'

-- Février 2025
(19, 'CONS027', 'Consultation pédiatrie', 'CONSULTATION', '2025-02-03 11:00:00', 75.00, 'Dr. Rousseau', 'Pneumonie'),
(19, 'RADIO05', 'Radiographie thorax', 'RADIOLOGIE', '2025-02-03 12:00:00', 70.00, 'Dr. Moreau', 'Foyer infectieux'),
(19, 'ANTIBIO1', 'Antibiothérapie IV 3 jours', 'TRAITEMENT', '2025-02-03 13:00:00', 480.00, 'Dr. Rousseau', 'Amoxicilline'),
(19, 'HOSPIT9', 'Hospitalisation 3 jours', 'HOSPITALISATION', '2025-02-03 00:00:00', 575.00, NULL, NULL),

-- Mars 2025
(22, 'IRM005', 'IRM lombaire', 'RADIOLOGIE', '2025-03-05 11:00:00', 420.00, 'Dr. Moreau', 'Hernie discale L5-S1'),
(22, 'CONS028', 'Consultation rhumatologie', 'CONSULTATION', '2025-03-05 15:00:00', 60.00, 'Dr. Rhumatologue', 'Infiltration proposée'),

-- Avril 2025
(25, 'CONS029', 'Consultation urgence traumato', 'CONSULTATION', '2025-04-02 18:00:00', 85.00, 'Dr. Martin', 'Entorse cheville'),
(25, 'RADIO06', 'Radiographie cheville 3 incidences', 'RADIOLOGIE', '2025-04-02 19:00:00', 95.00, 'Dr. Moreau', 'Pas de fracture'),
(25, 'IMMOBILIS', 'Immobilisation + attelle', 'TRAITEMENT', '2025-04-02 19:30:00', 140.00, 'Dr. Martin', 'Repos 3 semaines'),

-- Mai 2025
(28, 'CHIR006', 'Cure hernie inguinale', 'CHIRURGIE', '2025-05-08 09:00:00', 2400.00, 'Dr. Dupont', 'Technique Lichtenstein'),
(28, 'ANESTH8', 'Anesthésie locale', 'ANESTHESIE', '2025-05-08 08:45:00', 280.00, 'Dr. Anesthésiste', NULL),
(28, 'HOSPIT10', 'Hospitalisation ambulatoire + 6j', 'HOSPITALISATION', '2025-05-08 00:00:00', 720.00, NULL, 'Sortie J7'),

-- Juin 2025
(31, 'CHIMIO3', 'Chimiothérapie cycle 4 lymphome', 'TRAITEMENT', '2025-06-05 10:00:00', 5400.00, 'Dr. Petit', 'R-CHOP'),
(31, 'BIOL006', 'Bilan sanguin complet', 'LABORATOIRE', '2025-06-05 08:00:00', 150.00, NULL, 'Leucopénie'),
(31, 'HOSPIT11', 'Hospitalisation de jour + surveillance', 'HOSPITALISATION', '2025-06-05 00:00:00', 650.00, NULL, NULL),

-- Juillet 2025
(34, 'COLOSCO1', 'Coloscopie diagnostique', 'EXAMEN', '2025-07-03 10:00:00', 580.00, 'Dr. Gastro-entérologue', '3 polypes réséqués'),
(34, 'POLYPECT', 'Polypectomie endoscopique', 'CHIRURGIE', '2025-07-03 10:30:00', 1800.00, 'Dr. Gastro-entérologue', 'Polypes bénins'),
(34, 'ANESTH9', 'Sédation', 'ANESTHESIE', '2025-07-03 09:45:00', 220.00, 'Dr. Anesthésiste', 'Propofol'),
(34, 'HOSPIT12', 'Hospitalisation de jour', 'HOSPITALISATION', '2025-07-03 00:00:00', 300.00, NULL, NULL),

-- Août 2025
(37, 'CONS030', 'Consultation urgence pédiatrie', 'CONSULTATION', '2025-08-05 16:00:00', 80.00, 'Dr. Rousseau', 'Crise asthmatique'),
(37, 'NEBULISA', 'Nébulisation bronchodilatateurs', 'TRAITEMENT', '2025-08-05 16:30:00', 120.00, 'Inf. Bernard', 'Ventolin'),
(37, 'HOSPIT13', 'Surveillance 12h', 'HOSPITALISATION', '2025-08-05 00:00:00', 180.00, NULL, 'Amélioration'),

-- Septembre 2025
(40, 'CHIR007', 'Thyroïdectomie totale', 'CHIRURGIE', '2025-09-02 09:00:00', 3200.00, 'Dr. ORL', 'Exérèse complète'),
(40, 'ANESTH10', 'Anesthésie générale', 'ANESTHESIE', '2025-09-02 08:30:00', 450.00, 'Dr. Anesthésiste', NULL),
(40, 'HOSPIT14', 'Hospitalisation 7 jours', 'HOSPITALISATION', '2025-09-02 00:00:00', 450.00, NULL, NULL),

(41, 'PONTCORO', 'Pontage aorto-coronarien triple', 'CHIRURGIE', '2025-09-15 09:00:00', 15000.00, 'Dr. Cardio chirurgien', '3 pontages'),
(41, 'CEC001', 'Circulation extracorporelle', 'TRAITEMENT', '2025-09-15 09:30:00', 2500.00, 'Perfusionniste', 'CEC 120 min'),
(41, 'REANIM1', 'Réanimation 48h', 'HOSPITALISATION', '2025-09-15 00:00:00', 500.00, NULL, 'Surveillance intensive'),

-- Octobre 2025
(43, 'URGENC5', 'Prise en charge brûlure', 'URGENCE', '2025-10-08 19:00:00', 120.00, 'Dr. Martin', 'Brûlure 15% surface'),
(43, 'PANSEMT', 'Pansements spécialisés', 'TRAITEMENT', '2025-10-08 20:00:00', 280.00, 'Inf. Bernard', 'Flammazine'),
(43, 'HOSPIT15', 'Hospitalisation 24h', 'HOSPITALISATION', '2025-10-08 00:00:00', 120.00, NULL, 'Surveillance'),

-- Novembre 2025
(46, 'PROTHEP', 'Prothèse totale épaule', 'CHIRURGIE', '2025-11-05 09:00:00', 11000.00, 'Dr. Orthopédiste', 'PTH inversée'),
(46, 'ANESTH11', 'Anesthésie générale + bloc', 'ANESTHESIE', '2025-11-05 08:30:00', 550.00, 'Dr. Anesthésiste', 'Bloc interscalénique'),
(46, 'HOSPIT16', 'Hospitalisation 7 jours + rééducation', 'HOSPITALISATION', '2025-11-05 00:00:00', 1950.00, NULL, 'Kiné intensive'),

(48, 'VALVAORT', 'Remplacement valve aortique', 'CHIRURGIE', '2025-11-18 09:00:00', 18000.00, 'Dr. Cardio chirurgien', 'Prothèse mécanique'),
(48, 'CEC002', 'Circulation extracorporelle', 'TRAITEMENT', '2025-11-18 09:30:00', 3000.00, 'Perfusionniste', 'CEC 150 min'),
(48, 'REANIM2', 'Réanimation 72h', 'HOSPITALISATION', '2025-11-18 00:00:00', 1000.00, NULL, 'Surveillance post-op');

-- ============================================================
-- 3. INSERTION D'INVESTISSEMENTS 2025
-- ============================================================
INSERT INTO investments (nom, categorie, description, montant, date_investissement, date_fin_prevue, statut, fournisseur, responsable, benefices_attendus, retour_investissement) VALUES
('Équipement urgences vitales', 'EQUIPEMENT', 'Achat de 5 défibrillateurs nouvelle génération et 3 respirateurs', 85000.00, '2025-02-15', '2025-06-30', 'TERMINE', 'Philips Healthcare', 'Direction Urgences', 'Amélioration prise en charge arrêts cardiaques', 20.0),
('Bloc opératoire robotisé', 'EQUIPEMENT', 'Installation système de chirurgie assistée par robot', 450000.00, '2025-03-01', '2026-03-01', 'EN_COURS', 'Stryker Surgical', 'Direction Chirurgie', 'Chirurgie mini-invasive de précision', 18.0),
('Salle cathétérisme cardiaque', 'INFRASTRUCTURE', 'Rénovation complète salle de cathétérisme', 320000.00, '2025-04-01', '2025-10-31', 'EN_COURS', 'GE Healthcare', 'Dr. Lefevre', 'Augmentation capacité interventions', 22.0),
('IRM 3 Tesla', 'EQUIPEMENT', 'Remplacement IRM 1.5T par IRM 3T', 680000.00, '2025-05-15', '2026-05-15', 'EN_COURS', 'Siemens Healthineers', 'Dr. Moreau', 'Imagerie haute résolution', 16.0),
('Unité ambulatoire oncologie', 'INFRASTRUCTURE', 'Création unité ambulatoire de chimiothérapie 12 places', 280000.00, '2025-06-01', '2025-12-31', 'EN_COURS', 'Aménagement Santé SA', 'Dr. Petit', 'Confort patients et flux optimisés', 25.0),
('Équipement pédiatrie', 'EQUIPEMENT', 'Renouvellement moniteurs pédiatriques et pompes seringues', 65000.00, '2025-07-01', '2025-09-30', 'TERMINE', 'Dräger Medical', 'Dr. Rousseau', 'Sécurité et précision doses pédiatriques', 28.0),
('Plateforme télémédecine neurologie', 'TECHNOLOGIE', 'Solution de téléconsultation et télésurveillance neurologique', 95000.00, '2025-08-15', '2026-02-15', 'EN_COURS', 'MedTech Solutions', 'Dr. Simon', 'Suivi patients AVC et épilepsie à distance', 30.0),
('Rénovation maternité', 'INFRASTRUCTURE', 'Modernisation salles de naissance et chambres', 185000.00, '2025-09-01', '2026-03-01', 'EN_COURS', 'Bouygues Construction', 'Dr. Lambert', 'Confort et sécurité accouchements', 15.0),
('Système IA aide diagnostic', 'TECHNOLOGIE', 'IA pour analyse images médicales et aide décision', 220000.00, '2025-10-01', '2026-04-01', 'EN_COURS', 'IBM Watson Health', 'DSI', 'Détection précoce pathologies', 35.0),
('Formation staff médical 2025', 'FORMATION', 'Programme formation continue tout le personnel médical', 125000.00, '2025-11-01', '2026-11-30', 'EN_COURS', 'Centre Formation Santé', 'DRH', 'Mise à jour compétences et certifications', 20.0);

-- ============================================================
-- 4. INSERTION D'ALERTES RÉCENTES 2025
-- ============================================================
INSERT INTO alerts (titre, message, type, priorite, categorie, lu, resolu, assignee_a, date_resolution, commentaire, created_at) VALUES
('Affluence Urgences élevée décembre', 'Le nombre de passages aux urgences est en hausse de 22% par rapport à décembre 2024', 'WARNING', 'HAUTE', 'MEDICAL', false, false, 'Chef Service Urgences', NULL, NULL, '2025-12-10 08:00:00'),
('Budget chirurgie dépassé', 'Le service Chirurgie a dépassé son budget annuel de 8% en novembre', 'ERROR', 'CRITIQUE', 'FINANCIER', false, false, 'Direction Financière', NULL, NULL, '2025-12-01 14:00:00'),
('Nouvelle salle cathétérisme opérationnelle', 'La nouvelle salle de cathétérisme cardiaque est maintenant fonctionnelle', 'SUCCESS', 'BASSE', 'TECHNIQUE', true, true, NULL, '2025-12-05 10:00:00', 'Inaugurée avec succès', '2025-12-05 09:00:00'),
('Délai IRM prolongé', 'Le délai moyen pour obtenir une IRM est passé à 18 jours, seuil d\'alerte atteint', 'WARNING', 'HAUTE', 'MEDICAL', false, false, 'Dr. Moreau', NULL, NULL, '2025-12-12 11:00:00'),
('Stock chimiothérapie faible', 'Stock de médicaments de chimiothérapie inférieur à 20 jours', 'ERROR', 'CRITIQUE', 'MEDICAL', false, false, 'Pharmacie', NULL, NULL, '2025-12-13 07:00:00'),
('Épidémie bronchiolite', 'Pic épidémique de bronchiolite, service pédiatrie à 95% de capacité', 'ERROR', 'HAUTE', 'MEDICAL', false, false, 'Dr. Rousseau', NULL, NULL, '2025-12-14 09:00:00'),
('Formation IA terminée', 'Formation du personnel médical au système d\'IA diagnostic terminée avec succès', 'SUCCESS', 'BASSE', 'TECHNIQUE', true, true, NULL, '2025-12-08 16:00:00', '85% de satisfaction', '2025-12-08 10:00:00'),
('Taux réussite interventions cardiologie', 'Taux de réussite des angioplasties coronaires à 97.5% ce trimestre', 'SUCCESS', 'BASSE', 'MEDICAL', true, true, NULL, '2025-12-11 15:00:00', 'Excellent résultat', '2025-12-11 10:00:00'),
('Cybersécurité: mise à jour urgente', 'Mise à jour de sécurité critique à appliquer sur tous les systèmes avant le 20/12', 'ERROR', 'CRITIQUE', 'TECHNIQUE', false, false, 'DSI', NULL, NULL, '2025-12-14 07:30:00'),
('Maternité: satisfaction patients 96%', 'Enquête de satisfaction maternité: 96% de patients très satisfaits', 'SUCCESS', 'BASSE', 'ADMINISTRATIF', true, true, NULL, '2025-12-13 14:00:00', 'Record historique', '2025-12-13 10:00:00');

-- ============================================================
-- 5. INSERTION DE RAPPORTS 2025
-- ============================================================
INSERT INTO reports (titre, type, periode, resume, date_debut, date_fin, genere_par, donnees_principales, conclusions, recommandations, statut) VALUES
('Rapport annuel 2024', 'FINANCIER', 'ANNUEL', 'Bilan financier complet de l\'année 2024', '2024-01-01', '2024-12-31', 'Système', 
'{"revenus_total": 2850000, "couts_total": 2420000, "marge": 430000, "taux_occupation": 82.5, "nb_patients": 8420, "nb_actes": 15680}',
'Année 2024 bénéficiaire avec une marge de 15.1%. Croissance de l\'activité de 8% par rapport à 2023.',
'Poursuivre les investissements en équipements. Renforcer la capacité du service Urgences.',
'PUBLIE'),

('Rapport T1 2025', 'ACTIVITE', 'TRIMESTRIEL', 'Rapport d\'activité du 1er trimestre 2025', '2025-01-01', '2025-03-31', 'Système',
'{"nb_sejours": 842, "nb_actes": 3950, "revenus": 875000, "duree_moyenne_sejour": 4.2, "taux_occupation": 78.5}',
'Démarrage d\'année avec une activité soutenue. Légère baisse du taux d\'occupation en janvier.',
'Anticiper la période creuse estivale. Planifier les maintenances préventives.',
'PUBLIE'),

('Rapport T2 2025', 'ACTIVITE', 'TRIMESTRIEL', 'Rapport d\'activité du 2ème trimestre 2025', '2025-04-01', '2025-06-30', 'Système',
'{"nb_sejours": 798, "nb_actes": 3720, "revenus": 820000, "duree_moyenne_sejour": 4.0, "taux_occupation": 75.2}',
'Activité stable au T2. Baisse saisonnière attendue en mai-juin.',
'Optimiser la gestion des lits pendant la période estivale.',
'PUBLIE'),

('Rapport T3 2025', 'ACTIVITE', 'TRIMESTRIEL', 'Rapport d\'activité du 3ème trimestre 2025', '2025-07-01', '2025-09-30', 'Système',
'{"nb_sejours": 715, "nb_actes": 3280, "revenus": 765000, "duree_moyenne_sejour": 3.8, "taux_occupation": 71.5}',
'Baisse d\'activité estivale conforme aux prévisions. Reprise progressive en septembre.',
'Planifier les recrutements pour la période hivernale.',
'PUBLIE'),

('Rapport activité Chirurgie 2025', 'ACTIVITE', 'ANNUEL', 'Bilan d\'activité du service de chirurgie pour 2025', '2025-01-01', '2025-11-30', 'Dr. Dupont',
'{"nb_interventions": 1250, "taux_reussite": 98.5, "duree_moyenne_intervention": 125, "taux_occupation": 88.5, "revenus": 3250000}',
'Excellente année pour le service chirurgie. Record d\'interventions atteint.',
'Investir dans un deuxième bloc robotisé pour 2026.',
'PUBLIE'),

('Rapport Cardiologie novembre 2025', 'MEDICAL', 'MENSUEL', 'Rapport médical du service de cardiologie pour novembre', '2025-11-01', '2025-11-30', 'Dr. Lefevre',
'{"nb_consultations": 285, "nb_hospitalisations": 65, "angioplasties": 22, "echocardiographies": 180, "taux_reussite_interventions": 97.5}',
'Activité intense en novembre avec un taux de réussite élevé des procédures interventionnelles.',
'Maintenir le niveau d\'excellence. Prévoir renfort personnel pour décembre.',
'PUBLIE'),

('Rapport investissements 2025', 'FINANCIER', 'ANNUEL', 'Suivi des investissements réalisés en 2025', '2025-01-01', '2025-12-14', 'Direction Financière',
'{"investissements_planifies": 2505000, "investissements_realises": 1830000, "taux_realisation": 73, "roi_moyen": 22.5}',
'Programme d\'investissements en bonne voie. Plusieurs projets majeurs en cours.',
'Accélérer le déploiement de l\'IRM 3T et de l\'unité ambulatoire oncologie.',
'PUBLIE');

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
