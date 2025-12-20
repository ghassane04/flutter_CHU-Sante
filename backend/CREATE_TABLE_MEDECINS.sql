-- ============================================================
-- SCRIPT POUR AJOUTER LA TABLE MEDECINS
-- À exécuter dans la base healthcare_dashboard
-- ============================================================

USE healthcare_dashboard;

-- ============================================================
-- TABLE: MEDECINS
-- ============================================================
CREATE TABLE IF NOT EXISTS medecins (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    numero_inscription VARCHAR(50) NOT NULL UNIQUE,
    specialite VARCHAR(100) NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(100),
    service_id BIGINT,
    statut VARCHAR(20) DEFAULT 'ACTIF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL,
    INDEX idx_specialite (specialite),
    INDEX idx_statut (statut),
    INDEX idx_service (service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DONNÉES DE TEST
-- ============================================================

-- Insertion de médecins de test
INSERT INTO medecins (nom, prenom, numero_inscription, specialite, telephone, email, service_id, statut) VALUES
('Dupont', 'Marie', 'MED-001-2020', 'Cardiologie', '01 23 45 67 89', 'marie.dupont@chu-sante.fr', 1, 'ACTIF'),
('Martin', 'Jean', 'MED-002-2018', 'Chirurgie', '01 23 45 67 90', 'jean.martin@chu-sante.fr', 2, 'ACTIF'),
('Bernard', 'Sophie', 'MED-003-2019', 'Pédiatrie', '01 23 45 67 91', 'sophie.bernard@chu-sante.fr', 3, 'ACTIF'),
('Dubois', 'Pierre', 'MED-004-2021', 'Urgences', '01 23 45 67 92', 'pierre.dubois@chu-sante.fr', 5, 'ACTIF'),
('Thomas', 'Claire', 'MED-005-2017', 'Neurologie', '01 23 45 67 93', 'claire.thomas@chu-sante.fr', NULL, 'ACTIF'),
('Robert', 'Michel', 'MED-006-2022', 'Oncologie', '01 23 45 67 94', 'michel.robert@chu-sante.fr', 4, 'ACTIF'),
('Petit', 'Anne', 'MED-007-2016', 'Radiologie', '01 23 45 67 95', 'anne.petit@chu-sante.fr', NULL, 'ACTIF'),
('Durand', 'François', 'MED-008-2020', 'Anesthésie', '01 23 45 67 96', 'francois.durand@chu-sante.fr', 2, 'ACTIF'),
('Moreau', 'Isabelle', 'MED-009-2019', 'Dermatologie', '01 23 45 67 97', 'isabelle.moreau@chu-sante.fr', NULL, 'CONGE'),
('Simon', 'Laurent', 'MED-010-2023', 'Psychiatrie', '01 23 45 67 98', 'laurent.simon@chu-sante.fr', NULL, 'ACTIF');

-- Vérification
SELECT COUNT(*) as 'Nombre de médecins' FROM medecins;

-- Afficher les médecins avec leurs services
SELECT 
    m.id,
    CONCAT(m.prenom, ' ', m.nom) as 'Médecin',
    m.specialite,
    s.nom as 'Service',
    m.statut
FROM medecins m
LEFT JOIN services s ON m.service_id = s.id
ORDER BY m.nom, m.prenom;
