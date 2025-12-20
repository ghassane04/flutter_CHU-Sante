-- ============================================================
-- SCRIPT DE CRÉATION COMPLÈTE DE LA BASE DE DONNÉES
-- Healthcare Dashboard - Version finale
-- À exécuter après DROP_ALL_TABLES.sql
-- ============================================================

USE healthcare_dashboard;

-- ============================================================
-- TABLE: SERVICES MÉDICAUX
-- ============================================================
CREATE TABLE services (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    capacite INT,
    lits_disponibles INT,
    responsable VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: PATIENTS
-- ============================================================
CREATE TABLE patients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    numero_securite_sociale VARCHAR(15) NOT NULL UNIQUE,
    date_naissance DATE NOT NULL,
    sexe VARCHAR(1),
    adresse TEXT,
    telephone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom_prenom (nom, prenom),
    INDEX idx_nss (numero_securite_sociale)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: SÉJOURS
-- ============================================================
CREATE TABLE sejours (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    patient_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    date_entree TIMESTAMP NOT NULL,
    date_sortie TIMESTAMP,
    motif TEXT NOT NULL,
    diagnostic TEXT,
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_COURS',
    numero_sejour VARCHAR(50) UNIQUE,
    cout_total DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_patient (patient_id),
    INDEX idx_service (service_id),
    INDEX idx_statut (statut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: ACTES MÉDICAUX
-- ============================================================
CREATE TABLE actes_medicaux (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sejour_id BIGINT NOT NULL,
    code VARCHAR(20) NOT NULL,
    libelle VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    date_realisation TIMESTAMP NOT NULL,
    tarif DECIMAL(10, 2) NOT NULL,
    medecin VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sejour_id) REFERENCES sejours(id) ON DELETE CASCADE,
    INDEX idx_sejour (sejour_id),
    INDEX idx_type (type),
    INDEX idx_date (date_realisation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: INVESTISSEMENTS
-- ============================================================
CREATE TABLE investments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    categorie VARCHAR(50) NOT NULL,
    description TEXT,
    montant DECIMAL(12, 2) NOT NULL,
    date_investissement DATE NOT NULL,
    date_fin_prevue DATE,
    statut VARCHAR(20) NOT NULL DEFAULT 'PLANIFIE',
    fournisseur VARCHAR(255),
    responsable VARCHAR(100),
    benefices_attendus TEXT,
    retour_investissement DECIMAL(5, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_categorie (categorie),
    INDEX idx_statut (statut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: ALERTES
-- ============================================================
CREATE TABLE alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL,
    priorite VARCHAR(20) NOT NULL,
    categorie VARCHAR(50) NOT NULL,
    lu BOOLEAN DEFAULT FALSE,
    resolu BOOLEAN DEFAULT FALSE,
    assignee_a VARCHAR(100),
    date_resolution TIMESTAMP NULL,
    commentaire TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_priorite (priorite),
    INDEX idx_resolu (resolu)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: RAPPORTS
-- ============================================================
CREATE TABLE reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    periode VARCHAR(20) NOT NULL,
    resume TEXT,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    genere_par VARCHAR(100),
    donnees_principales JSON,
    conclusions TEXT,
    recommandations TEXT,
    statut VARCHAR(20) NOT NULL DEFAULT 'BROUILLON',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_periode (periode),
    INDEX idx_statut (statut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: PRÉDICTIONS
-- ============================================================
CREATE TABLE predictions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    type VARCHAR(50) NOT NULL,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    periode_prevue DATE NOT NULL,
    donnees_historiques JSON,
    resultat_prediction JSON,
    confiance DECIMAL(5, 2),
    methodologie TEXT,
    facteurs_cles TEXT,
    recommandations TEXT,
    genere_par VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: PARAMÈTRES
-- ============================================================
CREATE TABLE settings (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cle VARCHAR(100) NOT NULL UNIQUE,
    valeur TEXT,
    type VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: RÔLES
-- ============================================================
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: UTILISATEURS
-- ============================================================
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: ASSOCIATION UTILISATEURS-RÔLES
-- ============================================================
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- CONFIRMATION
-- ============================================================
SELECT 'Toutes les tables ont été créées avec succès!' AS Status;
SHOW TABLES;
