-- Paramètres par exemple :
-- Ville : Paris (ID 1), Type : T2, Période : 01/06/2024 au 15/06/2024

SELECT 
    l.NUM_LOGEMENT, 
    v.NOM_VILLE, 
    l.PRIX_SEMAINE_SAIS_HAUTE
FROM LOGEMENTS l
JOIN VILLES v ON l.NUM_VILLE = v.NUM_VILLE
WHERE v.NOM_VILLE = 'Paris' 
  AND l.CODE_TYPE = 'T2'
  AND NOT EXISTS (
      SELECT 1 
      FROM RESERVATIONS r 
      WHERE r.NUM_LOGEMENT = l.NUM_LOGEMENT
      AND r.DATE_ARRIVE < '2024-06-15' -- Date fin souhaitée
      AND r.DATE_DEPART > '2024-06-01' -- Date début souhaitée
  );