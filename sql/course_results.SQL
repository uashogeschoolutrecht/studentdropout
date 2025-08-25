-- ==============================================================================
-- STUDENT COURSE RESULTS ANALYSIS QUERY
-- ==============================================================================
-- This query analyzes student performance by calculating credits and grades
-- for Block A and Block B courses in the first year (Propedeuse phase)
-- ==============================================================================

-- CTE 1: Student Enrollment Data
-- Retrieves basic student enrollment information with study program details
WITH inschrijvingen AS (
    SELECT 
        inschrijvingen.[D_STUDENT_ID],
        inschrijvingen.[D_CROHO_ACTUEEL_ID],
        inschrijvingen.[COHORT_OPLEIDING],
        inschrijvingen.[D_FASE_ID],
        inschrijvingen.[D_VORM_ID],
        student.[STUDENTNUMMER],
        inschrijvingen.[COLLEGEJAAR],
        studievorm.[VORM_CD],
        croho.[TYPE_HO_OMS],
        croho.[CROHO],
        fase.[FASE_OMS],
        tijd_dag_ingang.[MAAND] AS Ingangsmaand,
        actiefcode_opleiding.[ACTIEFCODE]
    FROM [DM].[VW_DM_F_STUDENT_INSCHRIJFHIST] AS inschrijvingen
        LEFT JOIN [DM].[VW_DM_D_FASE] AS fase 
            ON inschrijvingen.[D_FASE_ID] = fase.[D_FASE_ID]
        LEFT JOIN [DM].[VW_DM_D_VORM] AS studievorm 
            ON inschrijvingen.[D_VORM_ID] = studievorm.[D_VORM_ID]
        LEFT JOIN [DM].[VW_DM_D_STUDENT] AS student 
            ON inschrijvingen.[D_STUDENT_ID] = student.[D_STUDENT_ID]
        LEFT JOIN [DM].[VW_DM_D_CROHO] AS croho 
            ON inschrijvingen.[D_CROHO_ACTUEEL_ID] = croho.[D_CROHO_ID]
        LEFT JOIN [DM].[VW_DM_D_ACTIEFCODE] AS actiefcode_opleiding 
            ON inschrijvingen.[D_ACTIEFCODE_OPLEIDING_ID] = actiefcode_opleiding.[D_ACTIEFCODE_ID]
        LEFT JOIN [DM].[VW_DM_D_TIJD_DAG] AS tijd_dag_ingang 
            ON inschrijvingen.[D_TIJD_DAG_INGANG_ID] = tijd_dag_ingang.[D_TIJD_DAG_ID]
),

-- CTE 2: Test Results Data
-- Retrieves student test results with credits and grades, filtered for Block A and B
toets_resultaten AS (
    SELECT 
        toets_resultaten.[COLLEGEJAAR],
        toets_resultaten.[D_STUDENT_ID],
        toets_resultaten.[D_CROHO_ACTUEEL_ID],
        toets_resultaten.[D_TOETS_ID],
        toets_resultaten.[D_FASE_ID],
        toets_resultaten.[D_VORM_ID],
        blok.[BLOK_LETTER],
        toets_resultaten.[PUNTEN],
        toets_resultaten.[RESULTAAT_NUMERIC],
        toets_resultaten.[GELDEND_RESULTAAT],
        toets_resultaten.[TOETS_POGING_NR],
        toets_resultaten.[VOLDOENDE],
        toets_resultaten.[D_TIJD_DAG_TOETS_DATUM_ID],
        tijd_dag_aanvangsdag.[MAAND] AS Aanvangsdag_maand,
        -- Calculate valid credits (only for passed courses)
        CASE 
            WHEN toets_resultaten.[VOLDOENDE] = 'J' 
            THEN toets_resultaten.[PUNTEN] 
            ELSE 0 
        END AS PUNTEN_GELDIG
    FROM [DM].[VW_DM_F_STUDENT_TOETS_RESULTAAT] AS toets_resultaten
        LEFT JOIN [DM].[VW_DM_D_BLOK] AS blok 
            ON toets_resultaten.[D_BLOK_ID] = blok.[D_BLOK_ID]
        LEFT JOIN [DM].[VW_DM_D_TIJD_DAG] AS tijd_dag_aanvangsdag 
            ON toets_resultaten.[D_TIJD_DAG_AANVANGSDATUM_ID] = tijd_dag_aanvangsdag.[D_TIJD_DAG_ID]
    WHERE 1 = 1
        AND (blok.[BLOK_LETTER] = 'A' OR blok.[BLOK_LETTER] = 'B')  -- Only Block A and B
        AND toets_resultaten.[COLLEGEJAAR] = toets_resultaten.[COHORT_OPLEIDING]  -- First year students
        AND toets_resultaten.[TOETS_POGING_NR] = '1'  -- First attempt only
),

-- CTE 3: Credit Results Calculation
-- Aggregates credits and grades per student per block
Credit_results AS (
    SELECT inschrijvingen.[D_STUDENT_ID],
        inschrijvingen.[Ingangsmaand],
        inschrijvingen.[D_FASE_ID],
        inschrijvingen.[D_VORM_ID],
        inschrijvingen.[D_CROHO_ACTUEEL_ID],
        inschrijvingen.[STUDENTNUMMER] AS [Student number],
        toets_resultaten.[BLOK_LETTER] AS [Block],
        inschrijvingen.[COLLEGEJAAR] AS [Study year],
        inschrijvingen.[CROHO] AS [Croho],
        AVG(toets_resultaten.[RESULTAAT_NUMERIC]) AS [Average Grade],
        COALESCE(SUM(PUNTEN_GELDIG), 0) AS [Total Credits],
        COALESCE(SUM(PUNTEN), 0) AS [Potential Credits],
        CASE WHEN toets_resultaten.[BLOK_LETTER] IS NOT NULL THEN 1 ELSE 0 END AS [Enrolled],
        -- Calculate percentage of credits obtained
        CASE 
            WHEN SUM(PUNTEN) IS NOT NULL 
            THEN ROUND(SUM(PUNTEN_GELDIG)/SUM(PUNTEN)*100, 2) 
            ELSE 0 
        END AS [Percentage Credits]
    FROM inschrijvingen
        LEFT JOIN toets_resultaten
            ON inschrijvingen.[D_STUDENT_ID] = toets_resultaten.[D_STUDENT_ID]
            AND inschrijvingen.[COLLEGEJAAR] = toets_resultaten.[COLLEGEJAAR]
            AND inschrijvingen.[D_CROHO_ACTUEEL_ID] = toets_resultaten.[D_CROHO_ACTUEEL_ID]
            AND inschrijvingen.[Ingangsmaand] = toets_resultaten.[Aanvangsdag_maand]
            AND inschrijvingen.[D_FASE_ID] = toets_resultaten.[D_FASE_ID]
            AND inschrijvingen.[D_VORM_ID] = toets_resultaten.[D_VORM_ID]
    WHERE 1 = 1
        -- Filter criteria for specific student population
        AND inschrijvingen.[TYPE_HO_OMS] = 'BA'           -- Bachelor students only
        AND inschrijvingen.[VORM_CD] = 'V'                -- Full-time students
        AND inschrijvingen.[ACTIEFCODE] = 4               -- Active enrollment
        AND inschrijvingen.[COLLEGEJAAR] = inschrijvingen.[COHORT_OPLEIDING]  -- First year
        AND inschrijvingen.[Ingangsmaand] = '9'           -- September intake
        AND inschrijvingen.[FASE_OMS] = 'Propedeuse'      -- First year phase
    GROUP BY inschrijvingen.[D_STUDENT_ID],
        inschrijvingen.[Ingangsmaand],
        inschrijvingen.[D_FASE_ID],
        inschrijvingen.[D_VORM_ID],
        inschrijvingen.[D_CROHO_ACTUEEL_ID],
        inschrijvingen.[STUDENTNUMMER],
        inschrijvingen.[COLLEGEJAAR],
        inschrijvingen.[CROHO],
        toets_resultaten.[BLOK_LETTER]
)

-- Final Results: Pivot Block A and B results into separate columns
SELECT 
    D_STUDENT_ID,
    D_FASE_ID,
    D_VORM_ID,
    D_CROHO_ACTUEEL_ID,
    Ingangsmaand,
    enrolled AS [Enrolled in course],
    
    -- Block A Results
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN [Block] = 'A' THEN [Total Credits] ELSE 0 END), 0), 2)) AS [Total Credits Block A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN [Block] = 'A' THEN [Potential Credits] ELSE 0 END), 0), 2)) AS [Potential Credits A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN [Block] = 'A' THEN [Percentage Credits] ELSE NULL END), 0), 2)) AS [Percentage Credits A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN [Block] = 'A' THEN [Average Grade] ELSE NULL END), 0), 2)) AS [Average Grade A],
    
    -- Block B Results
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN [Block] = 'B' THEN [Total Credits] ELSE 0 END), 0), 2)) AS [Total Credits Block B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN [Block] = 'B' THEN [Potential Credits] ELSE 0 END), 0), 2)) AS [Potential Credits B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN [Block] = 'B' THEN [Percentage Credits] ELSE NULL END), 0), 2)) AS [Percentage Credits B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN [Block] = 'B' THEN [Average Grade] ELSE NULL END), 0), 2)) AS [Average Grade B]
    
FROM Credit_results
WHERE 1 = 1
    AND [Study year] = 2022           -- 2022 cohort (for testing purposes)
    AND ([Student number] = '1835931' OR [Student number] = '1833704')  -- specific students (for testing purposes)      
    AND [Croho] = '39280'
    
GROUP BY D_STUDENT_ID,
    Ingangsmaand,
    D_FASE_ID,
    D_VORM_ID,
    D_CROHO_ACTUEEL_ID,
    [enrolled]

-- ==============================================================================





