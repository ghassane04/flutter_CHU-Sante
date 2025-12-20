-- ============================================================
-- SCRIPT SIMPLIFIÉ POUR DÉCEMBRE 2025
-- Ajoute uniquement les données nécessaires pour voir des revenus en décembre 2025
-- ============================================================

USE healthcare_dashboard;

-- Supprimer les séjours 2025 existants
DELETE FROM sejours WHERE numero_sejour LIKE 'SEJ2025%';

-- Insérer 9 séjours pour décembre 2025
INSERT INTO sejours (patient_id, service_id, date_entree, date_sortie, motif, diagnostic, statut, numero_sejour, cout_total) VALUES
(2, 1, '2025-12-02 10:00:00', '2025-12-03 08:00:00', 'Migraine sévère', 'Céphalée en grappe', 'TERMINE', 'SEJ2025120001', 280.00),
(4, 2, '2025-12-05 08:00:00', '2025-12-12 10:00:00', 'Péritonite', 'Appendicite perforée', 'TERMINE', 'SEJ2025120002', 4800.00),
(6, 3, '2025-12-08 15:00:00', NULL, 'Décompensation cardiaque', 'Insuffisance cardiaque aiguë', 'EN_COURS', 'SEJ2025120003', 3500.00),
(7, 4, '2025-12-10 11:00:00', '2025-12-13 10:00:00', 'Bronchiolite', 'Infection respiratoire', 'TERMINE', 'SEJ2025120004', 920.00),
(9, 5, '2025-12-12 01:00:00', NULL, 'Travail en cours', 'Accouchement imminent', 'EN_COURS', 'SEJ2025120005', 2800.00),
(11, 6, '2025-12-14 09:00:00', '2025-12-14 15:00:00', 'IRM cérébrale', 'Céphalées chroniques', 'TERMINE', 'SEJ2025120006', 520.00),
(13, 7, '2025-12-09 08:00:00', NULL, 'Chimiothérapie cycle 5', 'Cancer sein', 'EN_COURS', 'SEJ2025120007', 5600.00),
(14, 8, '2025-12-11 13:00:00', NULL, 'Paralysie faciale', 'Paralysie a frigore', 'EN_COURS', 'SEJ2025120008', 1400.00),
(15, 1, '2025-12-13 22:00:00', NULL, 'Accident voiture', 'Polytraumatisme', 'EN_COURS', 'SEJ2025120009', 3200.00);

-- Insérer les actes médicaux pour décembre 2025
INSERT INTO actes_medicaux (sejour_id, code, libelle, type, date_realisation, tarif, medecin, notes)
SELECT s.id, 'CONS020', 'Consultation urgence neurologie', 'CONSULTATION', '2025-12-02 10:00:00', 95.00, 'Dr. Simon', 'Migraine sévère' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120001'
UNION ALL SELECT s.id, 'PERFUS2', 'Perfusion analgésique', 'TRAITEMENT', '2025-12-02 11:00:00', 185.00, 'Inf. Bernard', 'Amélioration rapide' FROM sejours s WHERE s.numero_sejour = 'SEJ2025120001'

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
-- RÉSUMÉ DES REVENUS DE DÉCEMBRE 2025
-- ============================================================
-- Séjour 1: 280€ (Migraine)
-- Séjour 2: 4,800€ (Péritonite)
-- Séour 3: 650€ (Cardiologie EN_COURS)
-- Séjour 4: 920€ (Bronchiolite)
-- Séjour 5: 590€ (Accouchement EN_COURS)
-- Séjour 6: 520€ (IRM)
-- Séjour 7: 5,170€ (Chimiothérapie EN_COURS)
-- Séjour 8: 1,180€ (Paralysie faciale EN_COURS)
-- Séjour 9: 6,510€ (Polytraumatisme EN_COURS)
-- TOTAL DÉCEMBRE 2025: ~20,620€
-- ============================================================
