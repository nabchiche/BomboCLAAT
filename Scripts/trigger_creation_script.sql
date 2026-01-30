-- =============================================================
-- TRIGGER 1 : EMPÊCHER RÉSERVATION PENDANT MAINTENANCE
-- =============================================================
CREATE OR REPLACE FUNCTION check_maintenance_before_reservation()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifie s'il existe une maintenance planifiée qui chevauche les dates de réservation
    IF EXISTS (
        SELECT 1
        FROM MAINTENANCE m
        WHERE m.NUM_LOGEMENT = NEW.NUM_LOGEMENT
          -- Casting en DATE car DATE_ARRIVE est en DATETIME
          AND NEW.DATE_ARRIVE::DATE <= m.DATE_PLANIFIEE
          AND NEW.DATE_DEPART::DATE >= m.DATE_PLANIFIEE
    ) THEN
        RAISE EXCEPTION
        'Réservation impossible : le logement % est en maintenance à cette période',
        NEW.NUM_LOGEMENT;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_maintenance ON RESERVATIONS;
CREATE TRIGGER trg_check_maintenance
BEFORE INSERT OR UPDATE ON RESERVATIONS
FOR EACH ROW EXECUTE FUNCTION check_maintenance_before_reservation();


-- =============================================================
-- TRIGGER 2 : VÉRIFICATION DE LA CAPACITÉ DU LOGEMENT
-- =============================================================
CREATE OR REPLACE FUNCTION check_logement_capacity()
RETURNS TRIGGER AS $$
DECLARE
    capacite INT;
    nb_residents INT;
BEGIN
    -- Récupération de la capacité (Nombre de chambres) du logement
    SELECT NOMBRE_CHAMBRES
    INTO capacite
    FROM LOGEMENTS
    WHERE NUM_LOGEMENT = NEW.NUM_LOGEMENT;

    -- Comptage des résidents DÉJÀ enregistrés pour cette réservation (ce couple Logement/Date)
    SELECT COUNT(*)
    INTO nb_residents
    FROM FAIT_PARTI
    WHERE NUM_LOGEMENT = NEW.NUM_LOGEMENT
      AND DATE_ARRIVE = NEW.DATE_ARRIVE;

    -- Si l'ajout du nouveau résident dépasse la capacité
    IF nb_residents + 1 > capacite THEN
        RAISE EXCEPTION
        'Capacité dépassée : le logement % ne possède que % chambres.',
        NEW.NUM_LOGEMENT, capacite;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_capacity ON FAIT_PARTI;
CREATE TRIGGER trg_check_capacity
BEFORE INSERT ON FAIT_PARTI
FOR EACH ROW EXECUTE FUNCTION check_logement_capacity();


-- =============================================================
-- TRIGGER 3 : VÉRIFICATION COHÉRENCE DATES (DÉPART > ARRIVÉE)
-- =============================================================
CREATE OR REPLACE FUNCTION check_reservation_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.DATE_DEPART <= NEW.DATE_ARRIVE THEN
        RAISE EXCEPTION
        'Date de départ invalide : elle doit être strictement postérieure à la date d’arrivée.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_dates ON RESERVATIONS;
CREATE TRIGGER trg_check_dates
BEFORE INSERT OR UPDATE ON RESERVATIONS
FOR EACH ROW EXECUTE FUNCTION check_reservation_dates();


-- =============================================================
-- TRIGGER 4 : VÉRIFICATION PARTICIPATION ACTIVITÉ
-- (Le résident doit loger dans le bâtiment où se passe l'activité)
-- =============================================================
CREATE OR REPLACE FUNCTION check_activity_participation()
RETURNS TRIGGER AS $$
DECLARE
    logement_activite INT;
BEGIN
    -- 1. Trouver dans quel logement se déroule l'activité
    SELECT NUM_LOGEMENT INTO logement_activite
    FROM ACTIVITEES
    WHERE NUM_ACTIVITE = NEW.NUM_ACTIVITE;
    
    -- 2. Vérifier si le résident est bien rattaché à ce logement via FAIT_PARTI
    IF NOT EXISTS (
        SELECT 1
        FROM FAIT_PARTI fp
        WHERE fp.NUM_RESIDENT = NEW.NUM_RESIDENT
          AND fp.NUM_LOGEMENT = logement_activite
    ) THEN
        RAISE EXCEPTION
        'Participation refusée : le résident % ne réside pas dans le logement % (Lieu de l''activité %)',
        NEW.NUM_RESIDENT, logement_activite, NEW.NUM_ACTIVITE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_participation ON PARTICIPE;
CREATE TRIGGER trg_check_participation
BEFORE INSERT ON PARTICIPE
FOR EACH ROW EXECUTE FUNCTION check_activity_participation();


-- =============================================================
-- TRIGGER 5 : VÉRIFICATION NIVEAU URGENCE POSITIF
-- =============================================================
CREATE OR REPLACE FUNCTION check_urgence_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.NIVEAU_URGENCE <= 0 THEN
        RAISE EXCEPTION
        'Niveau d’urgence invalide : doit être strictement positif (reçu : %)', NEW.NIVEAU_URGENCE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_urgence ON MAINTENANCE;
CREATE TRIGGER trg_check_urgence
BEFORE INSERT OR UPDATE ON MAINTENANCE
FOR EACH ROW EXECUTE FUNCTION check_urgence_level();


-- =============================================================
-- TRIGGER 6 : EMPÊCHER SUPPRESSION LOGEMENT SI HISTORIQUE
-- =============================================================
CREATE OR REPLACE FUNCTION prevent_logement_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier s'il y a des réservations passées ou futures
    IF EXISTS (
        SELECT 1 FROM RESERVATIONS WHERE NUM_LOGEMENT = OLD.NUM_LOGEMENT
    )
    -- Vérifier s'il y a un historique de maintenance
    OR EXISTS (
        SELECT 1 FROM MAINTENANCE WHERE NUM_LOGEMENT = OLD.NUM_LOGEMENT
    ) THEN
        RAISE EXCEPTION
        'Suppression impossible : le logement % possède un historique (Réservations ou Maintenance).',
        OLD.NUM_LOGEMENT;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_delete ON LOGEMENTS;
CREATE TRIGGER trg_prevent_delete
BEFORE DELETE ON LOGEMENTS
FOR EACH ROW EXECUTE FUNCTION prevent_logement_delete();