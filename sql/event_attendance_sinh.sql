
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
-- - Marketing.VW_DM_D_SAF_EVENT: Event metadata and categorization
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
--- CTE 2: Event Types Data
--- Categorizes events into defined types for analysis
--- Based on M&C provided categorization logic (version 6/10/2025)
Event_Types_Attended AS (
    SELECT
        ev.ID [Event_ID],
        -- Eventcategorie
        CASE
            WHEN LOWER(ev.NAME) LIKE '%test%' THEN 'Test event'
            WHEN ev.EVENTTYPE__C LIKE '%Online voorlichting voor ouders%' THEN 'Online voorlichting voor ouders'
            WHEN LOWER(ev.NAME) LIKE 'q&a%' THEN 'Q&A'
            WHEN ev.EVENTTYPE__C LIKE '%Kennismaken op locatie%' OR ev.EVENTTYPE__C LIKE '%Open les op locatie%' THEN 'Kennismaken op locatie'
            WHEN LOWER(ev.EVENTTYPE__C) LIKE '%mastermarkt%' OR ev.NAME LIKE '%Mastermarkt%' THEN 'Mastermarkt'
            WHEN ev.EVENTTYPE__C LIKE '%Meeloopdag op locatie%'
                 OR ev.NAME LIKE '%Online orientation day%'
                 OR ev.NAME LIKE '%Meeloopdag%'
                 OR ev.NAME LIKE '%Orientation day%'
                 OR ev.NAME LIKE '%Online meeloopdag%'
                 OR ev.NAME LIKE '%Online student for a day%'
                 OR ev.NAME LIKE '%Proefstuderen%'
                 OR ev.TYPE__C LIKE '%Guided Tour%'
                 OR ev.TYPE__C LIKE '%Rondleiding%'
            THEN 'Meeloopdag'
            WHEN ev.NAME LIKE '%Wat is een associate degree%'
                 OR ev.NAME LIKE '%Hoe kies ik een studie%'
                 OR ev.NAME LIKE '%Doorstuderen na het%'
            THEN 'HU breed'
            WHEN ev.NAME LIKE '%interessegebied%'
                 OR ev.NAME LIKE 'Online voorlichting: Gezondhei%'
                 OR ev.NAME LIKE 'Online voorlichting: Natuur%'
                 OR ev.NAME LIKE 'Online voorlichting: Media%'
                 OR ev.NAME LIKE 'Online voorlichting: Onderwijs%'
                 OR ev.NAME LIKE 'Online voorlichting: Econo%'
            THEN 'Interessegebied'
            WHEN ev.EVENTTYPE__C LIKE '%Online opleidingspresentatie%' OR ev.EVENTTYPE__C LIKE '%Online presentation%' THEN 'Online opleidingspresentatie'
            WHEN ev.EVENTTYPE__C LIKE '%Online open avond%'
                 OR ev.NAME LIKE '%Online open avond%'
                 OR ev.NAME LIKE '%Online open evening%'
            THEN 'Online open avond'
            WHEN ev.EVENTTYPE__C LIKE '%Open dag op locatie%'
                 OR ev.NAME LIKE '%Online open dag%'
                 OR ev.NAME LIKE '%Online open day%'
                 OR ev.EVENTTYPE__C LIKE '%Online voorlichting%'
            THEN 'Open dag'
            WHEN ev.NAME LIKE '%U-Talent%' THEN 'U-Talent'
            WHEN ev.NAME LIKE '%Online vragenuur%'
                 OR ev.NAME LIKE '%Online chat hour%'
                 OR ev.NAME LIKE '%Inspiratiecollege%'
            THEN 'Online event'
            WHEN ev.NAME LIKE '%Rondleiding%' THEN 'Rondleiding'
            ELSE 'Onbekend'
        END AS EventCategorie

    FROM [Marketing].[VW_DM_D_SAF_EVENT] ev
    WHERE 1 = 1
      AND ev.CONFERENCE360__EVENT_START_DATE__C > '2022-08-24T00:00:00'
      AND ev.META_ACTUEEL_IND = 1
),

-- CTE 3: SAF Event Attendance Data
-- Aggregates event attendance with academic year derived from registration date
saf_table AS (
    SELECT
        -- Derive academic year from registration date (add 1 to get academic year depending on month within academic year)
		CASE 
			WHEN (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 100) % 100 IN (9, 10, 11, 12)
				THEN (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 10000) + 1
			ELSE (aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] / 10000)
		END AS [COLLEGEJAAR], 
        aanwezige.[D_CROHO_ID],
        contact.[OSIRIS_ID__C] AS [STUDENTNUMMER],
        -- Select the event type: use EventCategorie from CTE if available, else fallback to event.TYPE__C
        CASE
            WHEN evt.EventCategorie is NULL THEN event.TYPE__C ELSE evt.EventCategorie
        END AS [Event_Type],
        tijd_dag.[DAG] AS [Event_Date]
        
    FROM [DM].[F_SAF_EVENT_AANWEZIGE] AS aanwezige
        LEFT JOIN [DM].[D_SAF_EVENT] AS [event]
            ON aanwezige.[D_SAF_EVENT_ID] = [event].[D_SAF_EVENT_ID]
        LEFT JOIN Event_Types_Attended AS evt
            ON [event].[ID] = evt.[Event_ID]
        LEFT JOIN [DM].[D_SAF_CONTACT] AS contact
            ON aanwezige.[D_SAF_CONTACT_ID] = contact.[D_SAF_CONTACT_ID]
        LEFT JOIN [DM].[D_SAF_AANWEZIGE_STATUS] AS aanwezige_status
            ON aanwezige.[D_SAF_AANWEZIGE_STATUS_ID] = aanwezige_status.[D_SAF_AANWEZIGE_STATUS_ID]
        LEFT JOIN [DM].[D_TIJD_DAG] AS tijd_dag
            ON aanwezige.[D_TIJD_DAG_REGISTRATIE_ID] = tijd_dag.[D_TIJD_DAG_ID]

    WHERE 1 = 1
        AND contact.[OSIRIS_ID__C] IS NOT NULL                          -- Valid student identifiers only
        AND aanwezige_status.[AANWEZIGE_STATUS] = 'Attended'            -- Confirmed attendees only
)

-- Final Results: Event Attendance with Student Enrollment Context
SELECT 
    sinh_id.[SINH_ID],                          -- Student enrollment history identifier
    saf_table.[STUDENTNUMMER],                  -- Student number
    -- Event attendance metrics
    MIN(saf_table.[Event_Date]) AS [First_Event_Date],                  -- Date of first event attended
    MAX(saf_table.[Event_Date]) AS [Last_Event_Date],                   -- Date of last event attended
    COUNT(*) AS [Number_of_Events_Attended],                            -- Total number of events attended
    COUNT(DISTINCT saf_table.Event_Type) AS [Number_of_Event_Types],    -- Count of distinct event types attended
    STRING_AGG(saf_table.Event_Type, ', ') AS [Event_Types_Attended]    -- Comma-separated list of event types attended


FROM saf_table
    LEFT JOIN sinh_id 
        ON saf_table.[STUDENTNUMMER] = sinh_id.[STUDENTNUMMER] 
        AND saf_table.[COLLEGEJAAR] = sinh_id.[COLLEGEJAAR] 
        AND saf_table.[D_CROHO_ID] = sinh_id.[D_CROHO_ID]

WHERE saf_table.COLLEGEJAAR >= 2018 and saf_table.COLLEGEJAAR <= 2023
GROUP BY 
    sinh_id.[SINH_ID],
    saf_table.[STUDENTNUMMER]
ORDER BY 
    saf_table.[STUDENTNUMMER],
	sinh_id.[SINH_ID]
-- ==============================================================================