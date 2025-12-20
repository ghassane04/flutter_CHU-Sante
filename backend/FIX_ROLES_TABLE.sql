-- Script pour corriger la table roles
-- Supprime la table existante et la recrée correctement

USE healthcare_dashboard;

-- Supprimer d'abord les contraintes de clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- Supprimer la table roles existante
DROP TABLE IF EXISTS roles;

-- Recréer la table roles avec la bonne structure
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insérer les rôles par défaut
INSERT INTO roles (nom, description) VALUES 
('ROLE_ADMIN', 'Administrateur système avec tous les droits'),
('ROLE_DIRECTION', 'Direction avec accès aux rapports et statistiques'),
('ROLE_GESTIONNAIRE', 'Gestionnaire avec accès à la gestion des ressources'),
('ROLE_MEDECIN', 'Médecin avec accès aux dossiers patients'),
('ROLE_INFIRMIER', 'Infirmier avec accès aux soins'),
('ROLE_USER', 'Utilisateur standard');

-- Réactiver les contraintes
SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM roles;
