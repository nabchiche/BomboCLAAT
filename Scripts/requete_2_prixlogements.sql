
-- Vérifier si les logements les plus chers (Haut de gamme/Saison Haute) sont ceux qui tombent le moins souvent en panne. C'est une analyse qualité/prix.
SELECT 
    tl.DESCRIPTION AS TYPE_LOGEMENT,
    -- On classe par tranches de prix (ex: Moyenne des prix haute saison)
    ROUND(AVG(l.PRIX_SEMAINE_SAIS_HAUTE), 2) AS PRIX_MOYEN_HAUTE_SAISON,
    COUNT(m.NUM_MAINTENANCE) AS NOMBRE_TOTAL_PANNES,
    -- Calcul du nombre de pannes par logement de ce type (Densité de pannes)
    ROUND(CAST(COUNT(m.NUM_MAINTENANCE) AS DECIMAL) / NULLIF(COUNT(DISTINCT l.NUM_LOGEMENT), 0), 2) AS RATIO_PANNE_PAR_LOGEMENT
FROM LOGEMENTS l
JOIN TYPES_LOGEMENT tl ON l.CODE_TYPE = tl.CODE_TYPE
LEFT JOIN MAINTENANCE m ON l.NUM_LOGEMENT = m.NUM_LOGEMENT
GROUP BY tl.DESCRIPTION
ORDER BY PRIX_MOYEN_HAUTE_SAISON DESC;