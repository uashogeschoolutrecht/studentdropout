-- ============================================================================== 
-- STUDENT COURSE RESULTS ANALYSIS QUERY
-- ==============================================================================
-- This query analyzes student performance by calculating credits and grades
-- for Block A and Block B courses in the first year (Propedeuse phase)
-- Extra Block A metrics per SINH_ID:
--   1) First Grade: earliest grade by test date (ties resolved by D_TOETS_ID)
--   2) Highest/Lowest Grade: max/min RESULTAAT_NUMERIC in Block A
--   3) Variance Grade Block A: sample variance via VAR(...)
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
		inschrijvingen.SINH_ID,
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
    WHERE 1 = 1
        AND inschrijvingen.[COLLEGEJAAR] >= 2018
        AND inschrijvingen.[COLLEGEJAAR] < 2025
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
        AND blok.[BLOK_LETTER] IN ('A', 'B')  -- Only Block A and B
        AND toets_resultaten.[COLLEGEJAAR] = toets_resultaten.[COHORT_OPLEIDING]  -- First year students
        AND toets_resultaten.[TOETS_POGING_NR] = '1'  -- First attempt only
        AND toets_resultaten.[COLLEGEJAAR] >= 2018
        AND toets_resultaten.[COLLEGEJAAR] < 2025
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
		inschrijvingen.SINH_ID,
        toets_resultaten.[BLOK_LETTER] AS [Block],
        inschrijvingen.[COLLEGEJAAR] AS [Study year],
        inschrijvingen.[CROHO] AS [Croho],
        AVG(toets_resultaten.[RESULTAAT_NUMERIC]) AS [Average Grade],
        COALESCE(SUM(PUNTEN_GELDIG), 0) AS [Total Credits],
        COALESCE(SUM(PUNTEN), 0) AS [Potential Credits],
        CASE WHEN toets_resultaten.[BLOK_LETTER] IS NOT NULL THEN 1 ELSE 0 END AS [Enrolled for at least one exam],
        -- Calculate percentage of credits obtained
        CASE 
            WHEN SUM(PUNTEN) IS NOT NULL AND SUM(PUNTEN) > 0
            THEN ROUND(SUM(PUNTEN_GELDIG) * 100.0 / SUM(PUNTEN), 2)
            ELSE NULL
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
		inschrijvingen.SINH_ID,
        inschrijvingen.[STUDENTNUMMER],
        inschrijvingen.[COLLEGEJAAR],
        inschrijvingen.[CROHO],
        toets_resultaten.[BLOK_LETTER]
),

-- CTE 4: Block A grade stats per enrollment
-- Calculates aggregate grade distribution metrics for Block A only,
-- grouped at the same grain as the final output to avoid mixing grades
-- across different programs and duplicating stats across output rows.
BlockA_grade_stats AS (
    SELECT
        x.SINH_ID,
        x.D_STUDENT_ID,
        x.Ingangsmaand,
        x.D_FASE_ID,
        x.D_VORM_ID,
        x.D_CROHO_ACTUEEL_ID,
        MAX(CASE WHEN x.rn = 1 THEN x.RESULTAAT_NUMERIC END) AS [First Grade],
        MAX(x.RESULTAAT_NUMERIC) AS [Highest Grade Block A],
        MIN(x.RESULTAAT_NUMERIC) AS [Lowest Grade Block A],
        VAR(CAST(x.RESULTAAT_NUMERIC AS FLOAT)) AS [Variance Grade Block A]
    FROM (
        SELECT
            inschrijvingen.SINH_ID,
            inschrijvingen.D_STUDENT_ID,
            inschrijvingen.Ingangsmaand,
            inschrijvingen.D_FASE_ID,
            inschrijvingen.D_VORM_ID,
            inschrijvingen.D_CROHO_ACTUEEL_ID,
            tr.RESULTAAT_NUMERIC,
            ROW_NUMBER() OVER (
                PARTITION BY inschrijvingen.SINH_ID,
                             inschrijvingen.D_STUDENT_ID,
                             inschrijvingen.D_CROHO_ACTUEEL_ID,
                             inschrijvingen.D_FASE_ID,
                             inschrijvingen.D_VORM_ID,
                             inschrijvingen.Ingangsmaand
                -- Earliest test first; D_TOETS_ID is a deterministic tie-breaker.
                ORDER BY tr.D_TIJD_DAG_TOETS_DATUM_ID, tr.D_TOETS_ID
            ) AS rn
        FROM inschrijvingen
            INNER JOIN toets_resultaten tr
                ON inschrijvingen.[D_STUDENT_ID] = tr.[D_STUDENT_ID]
                AND inschrijvingen.[COLLEGEJAAR] = tr.[COLLEGEJAAR]
                AND inschrijvingen.[D_CROHO_ACTUEEL_ID] = tr.[D_CROHO_ACTUEEL_ID]
                AND inschrijvingen.[Ingangsmaand] = tr.[Aanvangsdag_maand]
                AND inschrijvingen.[D_FASE_ID] = tr.[D_FASE_ID]
                AND inschrijvingen.[D_VORM_ID] = tr.[D_VORM_ID]
        WHERE tr.BLOK_LETTER = 'A'
            AND tr.RESULTAAT_NUMERIC IS NOT NULL
            AND inschrijvingen.[TYPE_HO_OMS] = 'BA'           -- Bachelor students only
            AND inschrijvingen.[VORM_CD] = 'V'                -- Full-time students
            AND inschrijvingen.[ACTIEFCODE] = 4               -- Active enrollment
            AND inschrijvingen.[COLLEGEJAAR] = inschrijvingen.[COHORT_OPLEIDING]  -- First year
            AND inschrijvingen.[Ingangsmaand] = '9'           -- September intake
            AND inschrijvingen.[FASE_OMS] = 'Propedeuse'      -- First year phase
    ) x
    GROUP BY x.SINH_ID,
             x.D_STUDENT_ID,
             x.Ingangsmaand,
             x.D_FASE_ID,
             x.D_VORM_ID,
             x.D_CROHO_ACTUEEL_ID
)

-- Final Results: Pivot Block A and B results into separate columns
-- One output row per distinct combination of SINH_ID and the grouped
-- student/enrollment attributes within the selected study population.
SELECT
	cr.SINH_ID,
    cr.[Enrolled for at least one exam],
    
    -- Block A Results
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN cr.[Block] = 'A' THEN cr.[Total Credits] ELSE 0 END), NULL), 2)) AS [Total Credits Block A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN cr.[Block] = 'A' THEN cr.[Potential Credits] ELSE NULL END), NULL), 2)) AS [Potential Credits A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN cr.[Block] = 'A' THEN cr.[Percentage Credits] ELSE NULL END), NULL), 2)) AS [Percentage Credits A],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN cr.[Block] = 'A' THEN cr.[Average Grade] ELSE NULL END), NULL), 2)) AS [Average Grade A],
    
    -- Block B Results
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN cr.[Block] = 'B' THEN cr.[Total Credits] ELSE 0 END), 0), 2)) AS [Total Credits Block B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(SUM(CASE WHEN cr.[Block] = 'B' THEN cr.[Potential Credits] ELSE NULL END), NULL), 2)) AS [Potential Credits B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN cr.[Block] = 'B' THEN cr.[Percentage Credits] ELSE NULL END), NULL), 2)) AS [Percentage Credits B],
    CONVERT(DECIMAL(10,2), ROUND(COALESCE(AVG(CASE WHEN cr.[Block] = 'B' THEN cr.[Average Grade] ELSE NULL END), NULL), 2)) AS [Average Grade B],

    -- Additional Block A grade columns
    CONVERT(DECIMAL(10,2), MAX(bas.[First Grade])) AS [First Grade],
    CONVERT(DECIMAL(10,2), MAX(bas.[Highest Grade Block A])) AS [Highest Grade Block A],
    CONVERT(DECIMAL(10,2), MAX(bas.[Lowest Grade Block A])) AS [Lowest Grade Block A],
    CONVERT(DECIMAL(18,4), MAX(bas.[Variance Grade Block A])) AS [Variance Grade Block A]
    
FROM Credit_results cr
    LEFT JOIN BlockA_grade_stats bas
        ON cr.SINH_ID = bas.SINH_ID
        AND cr.D_STUDENT_ID = bas.D_STUDENT_ID
        AND cr.Ingangsmaand = bas.Ingangsmaand
        AND cr.D_FASE_ID = bas.D_FASE_ID
        AND cr.D_VORM_ID = bas.D_VORM_ID
        AND cr.D_CROHO_ACTUEEL_ID = bas.D_CROHO_ACTUEEL_ID
WHERE 1 = 1
    --AND cr.[Study year] = 2022           -- 2022 cohort (for testing purposes)
    --AND (cr.[Student number] = '1835931' OR cr.[Student number] = '1833704')  -- specific students (for testing purposes)
    --AND cr.[Croho] = '39280'
    
GROUP BY cr.D_STUDENT_ID,
    cr.Ingangsmaand,
    cr.D_FASE_ID,
    cr.D_VORM_ID,
    cr.D_CROHO_ACTUEEL_ID,
    cr.[Enrolled for at least one exam],
    cr.SINH_ID

-- ==============================================================================