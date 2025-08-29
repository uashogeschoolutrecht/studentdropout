
-- ==============================================================================
-- STUDENT EVENT ATTENDANCE WITH SINH_ID ANALYSIS QUERY
-- ==============================================================================
-- This query combines student event attendance data with enrollment history to provide:
-- - Event attendance metrics per student
-- - Student enrollment identifiers (SINH_ID)
-- - Academic year and program context
-- - Event type analysis with registration dates
--
-- Data Sources:
-- - F_STUDENT_INSCHRIJFHIST: Student enrollment history (for SINH_ID)
-- - F_SAF_EVENT_AANWEZIGE: Event attendance records
-- - D_SAF_EVENT: Event details and types
-- - D_SAF_CONTACT: Student/contact information
-- - D_SAF_AANWEZIGE_STATUS: Attendance status descriptions
-- - D_TIJD_DAG: Time dimension for registration dates
-- ==============================================================================

-- CTE 1: Student Enrollment Data
-- Retrieves SINH_ID and enrollment context for matching with event data
WITH sinh_id AS (
    SELECT 
        inschrijf.[SINH_ID],
        student.[STUDENTNUMMER],
        inschrijf.[COLLEGEJAAR],
        inschrijf.[D_CROHO_ACTUEEL_ID] AS [D_CROHO_ID]
    FROM [DM].[F_STUDENT_INSCHRIJFHIST] AS inschrijf
        LEFT JOIN [DM].[D_STUDENT] AS student 
            ON inschrijf.[D_STUDENT_ID] = student.[D_STUDENT_ID]
	WHERE inschrijf.COLLEGEJAAR >= 2018 and inschrijf.COLLEGEJAAR <= 2023
),

-- CTE 2: SAF Event Attendance Data
-- Aggregates event attendance with academic year derived from registration date
saf_table AS (
    SELECT
        -- Derive academic year from registration date (add 1 to get academic year depending on month within academic year)
		CASE 
			WHEN (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 100) % 100 IN (9, 10, 11, 12)
				THEN (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 10000) + 1
			ELSE (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 10000)
		END AS [COLLEGEJAAR], 
        aanwezige.[D_STUDENT_ID], 
        aanwezige.[D_CROHO_ID],
        contact.[OSIRIS_ID__C] AS [STUDENTNUMMER],
        
        -- Event attendance metrics
        COUNT(*) AS [Number_of_Events_Attended],
        COUNT(DISTINCT [event].[TYPE__C]) AS [Number_of_Event_Types],
        STRING_AGG([event].[TYPE__C], ', ') AS [Event_Types_Attended],
        tijd_dag.[DAG] AS [Event_Date]
        
    FROM [DM].[F_SAF_EVENT_AANWEZIGE] AS aanwezige
        LEFT JOIN [DM].[D_SAF_EVENT] AS [event]
            ON aanwezige.[D_SAF_EVENT_ID] = [event].[D_SAF_EVENT_ID]
        LEFT JOIN [DM].[D_SAF_CONTACT] AS contact
            ON aanwezige.[D_SAF_CONTACT_ID] = contact.[D_SAF_CONTACT_ID]
        LEFT JOIN [DM].[D_SAF_AANWEZIGE_STATUS] AS aanwezige_status
            ON aanwezige.[D_SAF_AANWEZIGE_STATUS_ID] = aanwezige_status.[D_SAF_AANWEZIGE_STATUS_ID]
        LEFT JOIN [DM].[D_TIJD_DAG] AS tijd_dag
            ON aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] = tijd_dag.[D_TIJD_DAG_ID]

    WHERE 1 = 1
        AND contact.[OSIRIS_ID__C] IS NOT NULL              -- Valid student identifiers only
        AND aanwezige_status.[AANWEZIGE_STATUS] = 'Attended' -- Confirmed attendees only

    GROUP BY 
        contact.[OSIRIS_ID__C],
        tijd_dag.[DAG],
        aanwezige.[D_TIJD_DAG_REGISTRATIE_ID], 
        aanwezige.[D_STUDENT_ID], 
        aanwezige.[D_CROHO_ID]
)

-- Final Results: Event Attendance with Student Enrollment Context
SELECT 
    sinh_id.[SINH_ID],                          -- Student enrollment history identifier
    saf_table.[STUDENTNUMMER],                  -- Student number
    saf_table.[Number_of_Events_Attended],      -- Count of events attended
    saf_table.[Number_of_Event_Types],          -- Count of distinct event types
    saf_table.[Event_Types_Attended],           -- Comma-separated list of event types
    saf_table.[Event_Date]                      -- Event registration date

FROM saf_table
    LEFT JOIN sinh_id 
        ON saf_table.[STUDENTNUMMER] = sinh_id.[STUDENTNUMMER] 
        AND saf_table.[COLLEGEJAAR] = sinh_id.[COLLEGEJAAR] 
        AND saf_table.[D_CROHO_ID] = sinh_id.[D_CROHO_ID]

WHERE saf_table.COLLEGEJAAR >= 2018 and saf_table.COLLEGEJAAR <= 2023

ORDER BY 
    saf_table.[STUDENTNUMMER],
	sinh_id.[SINH_ID],
    saf_table.[Event_Date]

-- ==============================================================================