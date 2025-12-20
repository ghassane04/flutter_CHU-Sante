-- Mettre à jour les données budgétaires des services
USE healthcare_dashboard;

-- Désactiver temporairement le mode de mise à jour sécurisé
SET SQL_SAFE_UPDATES = 0;

-- Mettre à jour les services existants avec des valeurs de démonstration
UPDATE services SET 
    budget = CASE 
        WHEN nom = 'Urgences' THEN 150000
        WHEN nom = 'Chirurgie' THEN 220000
        WHEN nom = 'Cardiologie' THEN 110000
        WHEN nom = 'Pédiatrie' THEN 90000
        WHEN nom = 'Radiologie' THEN 100000
        WHEN nom = 'Maternité' THEN 70000
        WHEN nom = 'Neurologie' THEN 130000
        WHEN nom = 'Orthopédie' THEN 95000
        ELSE 80000
    END,
    depense = CASE 
        WHEN nom = 'Urgences' THEN 120000
        WHEN nom = 'Chirurgie' THEN 180000
        WHEN nom = 'Cardiologie' THEN 95000
        WHEN nom = 'Pédiatrie' THEN 75000
        WHEN nom = 'Radiologie' THEN 85000
        WHEN nom = 'Maternité' THEN 55000
        WHEN nom = 'Neurologie' THEN 110000
        WHEN nom = 'Orthopédie' THEN 78000
        ELSE 60000
    END
WHERE id > 0;  -- Ajouter une condition WHERE pour satisfaire le mode sécurisé

-- Réactiver le mode de mise à jour sécurisé
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM services;
