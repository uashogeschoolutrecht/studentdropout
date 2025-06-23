-- AVG cijfer eind blok A
-- AVG cijfer eind blok B
-- Totaal aantal studiepunten eind blok A
-- Maximaal haalbaar studiepunten eind blok A
-- Totaal aantal studiepunten eind blok B
-- Maximaal haalbaar studiepunten eind blok B

-- WHERE
-- COHORT_OPLEIDING = COLLEGEJAR
-- BACHELOR (fase)
-- FULL TIME (vorm)
-- INGESCHREVEN (actiefcode 4)
-- STARTDATUM 1 September 


WITH toets_resultaten AS (


SELECT toets_resultaten.[D_STUDENT_ID]
    ,toets_resultaten.[COLLEGEJAAR]
    ,studievorm.[VORM_CD]
    ,croho.[TYPE_HO_OMS]
    ,croho.[CROHO]
    ,toets_resultaten.[D_FASE_ID] 
    ,toets.[TOETS_BK]
    ,fase.[FASE_OMS]
    ,blok.[BLOK_LETTER]
    ,examenonderdeel.[EXAMENONDERDEEL]
    ,examenonderdeel.[MINIMUM_PUNTEN]
    ,toets_resultaten.[PUNTEN]
    ,toets_resultaten.[RESULTAAT_NUMERIC]
    ,toets_resultaten.[GELDEND_RESULTAAT]
    ,toets_resultaten.[TOETS_POGING_NR]
    ,toets_resultaten.[VOLDOENDE]
    ,toets_resultaten.[D_TIJD_DAG_TOETS_DATUM_ID]
    ,tijd_dag_aanvangsdag.[MAAND] 
    ,CASE WHEN toets_resultaten.[VOLDOENDE] = 'J' THEN toets_resultaten.[PUNTEN] ELSE 0 END AS PUNTEN_GELDIG
FROM [DM].[VW_DM_F_STUDENT_TOETS_RESULTAAT] AS toets_resultaten
LEFT JOIN [DM].[VW_DM_D_EXAMENPROGRAMMA] AS examenprogramma ON toets_resultaten.[D_EXAMENPROGRAMMA_ID] = examenprogramma.[D_EXAMENPROGRAMMA_ID]
LEFT JOIN [DM].[VW_DM_D_FASE] AS fase ON toets_resultaten.[D_FASE_ID] = fase.[D_FASE_ID]
LEFT JOIN [DM].[VW_DM_D_VORM] AS studievorm ON toets_resultaten.[D_VORM_ID] = studievorm.[D_VORM_ID]
LEFT JOIN [DM].[VW_DM_D_BLOK] AS blok ON toets_resultaten.[D_BLOK_ID] = blok.[D_BLOK_ID]
LEFT JOIN [DM].[VW_DM_D_STUDENT] AS student ON toets_resultaten.[D_STUDENT_ID] = student.[D_STUDENT_ID]
LEFT JOIN [DM].[VW_DM_D_CROHO] AS croho ON toets_resultaten.[D_CROHO_ACTUEEL_ID] = croho.[D_CROHO_ID]
LEFT JOIN [DM].[VW_DM_D_EXAMENONDERDEEL] AS examenonderdeel ON toets_resultaten.[D_EXAMENONDERDEEL_ID] = examenonderdeel.[D_EXAMENONDERDEEL_ID]
LEFT JOIN [DM].[VW_DM_D_TIJD_DAG] AS tijd_dag_aanvangsdag ON toets_resultaten.[D_TIJD_DAG_AANVANGSDATUM_ID] = tijd_dag_aanvangsdag.[D_TIJD_DAG_ID]
LEFT JOIN [DM].[VW_DM_D_TOETS] AS toets ON toets_resultaten.[D_TOETS_ID] = toets.[D_TOETS_ID]
WHERE 1 = 1
    AND blok.[BLOK_LETTER] = 'A' -- OR blok.[BLOK_LETTER] = 'B')
    AND croho.[TYPE_HO_OMS] = 'BA'
    AND studievorm.[VORM_CD] = 'V'
    -- AND toets_resultaten.[ACTIEFCODE_OPLEIDING_CSA] = 4
    -- AND toets_resultaten.[CURSUS_GELDIG] = 1
    AND toets_resultaten.[COLLEGEJAAR] = toets_resultaten.[COHORT_OPLEIDING]
    AND toets_resultaten.[D_STUDENT_ID] = 587655
    -- AND tijd_dag_aanvangsdag.[MAAND] = '9' 
    -- AND toets_resultaten.[COLLEGEJAAR] = '2023'
    -- AND croho.[CROHO] = '39280'
    -- and fase.[FASE_OMS] = 'Propedeuse'
    -- AND toets.[TOETS_BK] = 'TBBE-V01REKI-172017VTOETS2'
    -- AND toets_resultaten.[TOETS_POGING_NR] = '1'

)





SELECT 
    BLOK_LETTER as [Block],
    COLLEGEJAAR as [Study year],
    CROHO as [Croho],
    D_STUDENT_ID,
    AVG(RESULTAAT_NUMERIC) AS [Average Grade],
    SUM(PUNTEN_GELDIG) AS [Total Credits],
    SUM(PUNTEN) AS [Potential Credits]
FROM toets_resultaten
GROUP BY 
    BLOK_LETTER,
    COLLEGEJAAR,
    CROHO,
    D_STUDENT_ID