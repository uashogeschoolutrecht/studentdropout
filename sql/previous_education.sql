-- ==============================================================================
-- STUDENT PREVIOUS EDUCATION ANALYSIS QUERY
-- ==============================================================================
-- This query retrieves previous education information for students including:
-- - Previous education level and type
-- - Previous school postal code
-- - Foreign education indicator (yes/no)
-- - Final exam date from previous education
-- ==============================================================================

-- CTE 1: School Postal Code and Exam Date Data
-- Retrieves postal codes of previous schools and exam dates, with fallback for missing data
WITH school_postcode_examdate AS (
    SELECT 
        voor.[STUDENTNUMMER],
        voor.[EINDEXAMENDATUM],
        school.[SCHOOL],
        CASE 
            WHEN school.[POSTCODE] IS NOT NULL 
            THEN school.[POSTCODE] 
            ELSE null  -- Default postal code for missing data
        END AS previous_school_postcode
    FROM [ODS].[OSS_STUDENT_VOOROPLEIDING] AS voor
        LEFT JOIN [DM].[D_SCHOOL] AS school
            ON voor.[SCHOOL] = school.[SCHOOL]
    GROUP BY 
        voor.[STUDENTNUMMER],
        voor.[EINDEXAMENDATUM],
        school.[SCHOOL],
        school.[POSTCODE]  
)

-- Final Results: Student Previous Education Summary
SELECT
	inschrijfhist.SINH_ID,
	inschrijfhist.COLLEGEJAAR,
	inschrijfhist.D_TIJD_DAG_INGANG_ID,
    vooropleiding.[TYPE_VOOROPLEIDING] AS [Previous Education Type],
    
    -- Foreign education indicator based on education type
    CASE 
        WHEN vooropleiding.[TYPE_VOOROPLEIDING] = 'BUITENL_SL' 
        THEN 1
        ELSE 0
    END AS [Previous Education Foreign],
    
    school_postcode_examdate.[previous_school_postcode] AS [Previous School Postal Code],
    school_postcode_examdate.[SCHOOL] AS [Previous School],
    MAX(school_postcode_examdate.[EINDEXAMENDATUM]) AS [Final Exam Date]
    
FROM [DM].[F_STUDENT_INSCHRIJFHIST] AS inschrijfhist
    LEFT JOIN [DM].[D_VOOROPLEIDING] AS vooropleiding
        ON inschrijfhist.[D_VOOROPLEIDING_ID] = vooropleiding.[D_VOOROPLEIDING_ID]
    LEFT JOIN [DM].[D_STUDENT] AS student
        ON inschrijfhist.[D_STUDENT_ID] = student.[D_STUDENT_ID]
    LEFT JOIN school_postcode_examdate
        ON student.[STUDENTNUMMER] = school_postcode_examdate.[STUDENTNUMMER]
WHERE inschrijfhist.COLLEGEJAAR >= 2018 and inschrijfhist.COLLEGEJAAR <= 2023 AND
-- Only select previous education with an exam date before the start of the HU study
    TRY_CONVERT(DATE, [EINDEXAMENDATUM]) <= 
    TRY_CONVERT(DATE, FORMAT([D_TIJD_DAG_INGANG_ID], '0000-00-00'))
GROUP BY 
	inschrijfhist.SINH_ID,
	inschrijfhist.COLLEGEJAAR,
	inschrijfhist.D_TIJD_DAG_INGANG_ID,
    vooropleiding.[TYPE_VOOROPLEIDING], 
    school_postcode_examdate.[previous_school_postcode], 
    school_postcode_examdate.[SCHOOL]

-- ==============================================================================  