-- =============================================================
-- SCRIPT D'INSERTION DE DONNÉES COMPLET
-- =============================================================

-- Nettoyage préalable
DELETE FROM PARTIS_CONFLIT;
DELETE FROM CONFLIT;
DELETE FROM MAINTENANCE;
DELETE FROM PARTICIPE;
DELETE FROM FAIT_PARTI;
DELETE FROM ACTIVITEES;
DELETE FROM RESERVATIONS;
DELETE FROM LOGEMENTS;
DELETE FROM GROUPE;
DELETE FROM TYPES_ACTIVITE;
DELETE FROM TYPE_INTERVENTION;
DELETE FROM VILLES;
DELETE FROM RESIDENTS;
DELETE FROM TYPES_LOGEMENT;

-- 1. TYPES DE LOGEMENT
INSERT INTO TYPES_LOGEMENT (CODE_TYPE, DESCRIPTION) VALUES
('T2', 'Appartement T2'),
('T3', 'Appartement T3'),
('T4', 'Appartement T4'),
('VILLA', 'Villa individuelle'),
('MAISON', 'Maison mitoyenne'),
('CHEZ_HAB', 'Chez l’habitant');

-- 2. VILLES
INSERT INTO VILLES (NUM_VILLE, NOM_VILLE) VALUES
(1, 'Paris'), (2, 'Lyon'), (3, 'Marseille'),
(4, 'Bordeaux'), (5, 'Toulouse'), (6, 'Nantes');

-- 3. TYPES D’INTERVENTION (MAINTENANCE)
INSERT INTO TYPE_INTERVENTION (NUM_URGENCE, NOM) VALUES
(1, 'Plomberie'), (2, 'Electricité'), (3, 'Chauffage'),
(4, 'Serrurerie'), (5, 'Peinture');

-- 4. TYPES D’ACTIVITÉ
INSERT INTO TYPES_ACTIVITE (TYPE_ACTIVITE, NOM_TYPE_ACTIVITE) VALUES
(1, 'Sport'), (2, 'Culture'), (3, 'Repas collectif'),
(4, 'Bien-être'), (5, 'Atelier');

-- 5. GROUPES
INSERT INTO GROUPE (NUM_GROUPE, NOM) VALUES
(1, 'Groupe Alpha'), (2, 'Groupe Beta');

-- 6. RÉSIDENTS
INSERT INTO RESIDENTS (NUM_RESIDENT, NOM, PRENOM) VALUES
(1, 'Dupont', 'Jean'), (2, 'Martin', 'Claire'), (3, 'Durand', 'Paul'),
(4, 'Bernard', 'Lucie'), (5, 'Petit', 'Antoine'), (6, 'Robert', 'Emma'),
(7, 'Richard', 'Hugo'), (8, 'Moreau', 'Sarah'), (9, 'Fournier', 'Louis'),
(10, 'Girard', 'Manon');

-- 7. LOGEMENTS
-- Ordre DDL : NUM, NB_CHAMBRES, EQUIP, PRIX_BAS, PRIX_HAUT, GROUPE, VILLE, TYPE
INSERT INTO LOGEMENTS (NUM_LOGEMENT, NOMBRE_CHAMBRES, EQUIPEMENT, PRIX_SEMAINE_SAIS_BASSE, PRIX_SEMAINE_SAIS_HAUTE, NUM_GROUPE, NUM_VILLE, CODE_TYPE) VALUES
(1, 2, 'WiFi, TV', 450.00, 650.00, 1, 1, 'T2'),
(2, 3, 'WiFi, Balcon', 520.00, 720.00, 1, 1, 'T3'),
(3, 4, 'WiFi, Terrasse', 600.00, 820.00, 1, 1, 'T4'),
(4, 2, 'WiFi', 430.00, 630.00, 2, 2, 'T2'),
(5, 3, 'WiFi, Parking', 500.00, 700.00, 2, 2, 'T3'),
(6, 4, 'Jardin, Parking', 620.00, 850.00, NULL, 2, 'MAISON'),
(7, 2, 'WiFi', 400.00, 580.00, NULL, 3, 'T2'),
(8, 3, 'WiFi, TV', 510.00, 710.00, NULL, 3, 'T3'),
(9, 5, 'Terrasse, Piscine', 800.00, 1200.00, NULL, 3, 'VILLA');

-- 8. RÉSERVATIONS
INSERT INTO RESERVATIONS (NUM_LOGEMENT, DATE_ARRIVE, DATE_DEPART) VALUES
(1, '2024-03-01 14:00:00', '2024-03-31 10:00:00'),
(3, '2024-06-01 14:00:00', '2024-06-30 10:00:00'),
(5, '2024-02-01 14:00:00', '2024-02-28 10:00:00'),
(9, '2024-07-15 14:00:00', '2024-08-15 10:00:00');

-- 9. FAIT_PARTI (Lien Résidents <-> Réservations)
INSERT INTO FAIT_PARTI (NUM_LOGEMENT, DATE_ARRIVE, NUM_RESIDENT) VALUES
(1, '2024-03-01 14:00:00', 1),
(1, '2024-03-01 14:00:00', 2),
(3, '2024-06-01 14:00:00', 4),
(9, '2024-07-15 14:00:00', 8),
(9, '2024-07-15 14:00:00', 9);

-- 10. ACTIVITÉES
-- Ordre DDL : NUM, NOM, JOUR, GROUPE, TYPE, LOGEMENT
INSERT INTO ACTIVITEES (NUM_ACTIVITE, NOM_ACTIVITE, JOUR_SEMAINE, NUM_GROUPE, TYPE_ACTIVITE, NUM_LOGEMENT) VALUES
(1, 'Yoga Matinal', 'Lundi', 1, 4, 1),
(2, 'Tournoi Foot', 'Mercredi', NULL, 1, 3),
(3, 'Barbecue Commun', 'Vendredi', NULL, 3, 5),
(4, 'Atelier Poterie', 'Samedi', 2, 5, 4);

-- 11. PARTICIPE (Lien Résidents <-> Activités)
INSERT INTO PARTICIPE (NUM_RESIDENT, NUM_ACTIVITE) VALUES
(1, 1), (2, 1), (4, 2), (8, 3), (9, 3);

-- 12. MAINTENANCE
INSERT INTO MAINTENANCE (NUM_MAINTENANCE, NIVEAU_URGENCE, DATE_PLANIFIEE, NUM_URGENCE, NUM_LOGEMENT) VALUES
(1, 2, '2024-04-05', 1, 1),
(2, 5, '2024-05-10', 4, 2),
(3, 1, '2024-01-15', 3, 5);

-- 13. CONFLITS
INSERT INTO CONFLIT (NUM_CONFLIT, DATE_CONFLIT, DESCRIPTION) VALUES
(1, '2024-03-15', 'Nuisance sonore nocturne'),
(2, '2024-07-20', 'Dégradation matériel piscine');

-- 14. PARTIS_CONFLIT
INSERT INTO PARTIS_CONFLIT (NUM_RESIDENT, NUM_CONFLIT) VALUES
(1, 1), (2, 1), (8, 2);