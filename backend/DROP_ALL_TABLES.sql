-- ============================================================
-- SCRIPT DE NETTOYAGE COMPLET DE LA BASE DE DONNÉES
-- À exécuter dans MySQL Workbench
-- ============================================================
-- Ce script supprime TOUTES les tables (y compris les doublons)
-- ============================================================

USE healthcare_dashboard;

-- Désactiver temporairement les contraintes de clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- SUPPRESSION DE TOUTES LES TABLES (y compris doublons)
-- ============================================================

-- Tables principales (noms au singulier ET au pluriel)
DROP TABLE IF EXISTS patient;
DROP TABLE IF EXISTS patients;

DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS services;

DROP TABLE IF EXISTS acte_medical;
DROP TABLE IF EXISTS acte_medicale;
DROP TABLE IF EXISTS actes_medicaux;

DROP TABLE IF EXISTS sejour;
DROP TABLE IF EXISTS sejours;

DROP TABLE IF EXISTS investment;
DROP TABLE IF EXISTS investments;

DROP TABLE IF EXISTS alert;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS alerte;
DROP TABLE IF EXISTS alertes;

DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS rapport;
DROP TABLE IF EXISTS rapports;

DROP TABLE IF EXISTS prediction;
DROP TABLE IF EXISTS predictions;

DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS setting;
DROP TABLE IF EXISTS parametre;
DROP TABLE IF EXISTS parametres;

-- Tables d'authentification
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS utilisateur;
DROP TABLE IF EXISTS utilisateurs;

DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS roles;

DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS utilisateur_roles;

-- Autres tables éventuelles
DROP TABLE IF EXISTS dashboard;
DROP TABLE IF EXISTS dashboards;
DROP TABLE IF EXISTS stat;
DROP TABLE IF EXISTS stats;
DROP TABLE IF EXISTS statistique;
DROP TABLE IF EXISTS statistiques;

-- Réactiver les contraintes de clés étrangères
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- VÉRIFICATION
-- ============================================================
SELECT 'Toutes les tables ont été supprimées avec succès!' AS Status;
SHOW TABLES;
