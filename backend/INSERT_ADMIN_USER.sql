-- ============================================================
-- SCRIPT D'INSERTION D'UN UTILISATEUR ADMIN PAR DÉFAUT
-- Healthcare Dashboard
-- ============================================================

USE healthcare_dashboard;

-- ============================================================
-- 1. Insérer les rôles de base (si pas déjà présents)
-- ============================================================
INSERT IGNORE INTO roles (nom, description) VALUES
('ROLE_ADMIN', 'Administrateur du système - Accès complet'),
('ROLE_GESTIONNAIRE', 'Gestionnaire Financier - Accès au dashboard et rapports'),
('ROLE_MEDECIN', 'Médecin - Accès aux patients et actes médicaux'),
('ROLE_UTILISATEUR', 'Utilisateur standard - Accès en lecture seule');

-- ============================================================
-- 2. Insérer un utilisateur admin par défaut
-- ============================================================
-- Mot de passe: admin123
-- Hash BCrypt généré pour "admin123"
INSERT IGNORE INTO users (username, password, email, nom, prenom, enabled) VALUES
('admin', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'admin@chu-sante.fr', 'Admin', 'Système', TRUE);

-- ============================================================
-- 3. Assigner le rôle ADMIN à l'utilisateur
-- ============================================================
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'admin' AND r.nom = 'ROLE_ADMIN';

-- ============================================================
-- 4. Insérer un gestionnaire financier pour les tests
-- ============================================================
-- Mot de passe: gestionnaire123
-- Hash BCrypt généré pour "gestionnaire123"
INSERT IGNORE INTO users (username, password, email, nom, prenom, enabled) VALUES
('gestionnaire', '$2a$10$N.n7F7xXP6OVHqLGN8qYCO3dqF8rJ5p9pKYxH3xYj8fZRjW8rK3sC', 'gestionnaire@chu-sante.fr', 'Martin', 'Dupont', TRUE);

-- Assigner le rôle GESTIONNAIRE
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'gestionnaire' AND r.nom = 'ROLE_GESTIONNAIRE';

-- ============================================================
-- CONFIRMATION
-- ============================================================
SELECT 'Utilisateurs créés avec succès!' AS Status;

SELECT 
    u.id,
    u.username,
    u.email,
    u.nom,
    u.prenom,
    GROUP_CONCAT(r.nom) AS roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.username, u.email, u.nom, u.prenom;
