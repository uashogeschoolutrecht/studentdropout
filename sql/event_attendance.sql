-- ==============================================================================
-- STUDENT EVENT ATTENDANCE ANALYSIS QUERY
-- ==============================================================================
-- This query retrieves event attendance information for students including:
-- - Number of events attended per student
-- - Type of events attended
-- - Event timestamps and details
-- Uses F_SAF_EVENT_AANWEZIGE as the main fact table for actual attendance records
-- ==============================================================================

SELECT
    contact.[OSIRIS_ID__C] AS [STUDENTNUMMER],
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
    AND contact.[OSIRIS_ID__C] IS NOT NULL
    AND aanwezige_status.[AANWEZIGE_STATUS] ='Attended'

GROUP BY 
    contact.[OSIRIS_ID__C],
    tijd_dag.[DAG]
    
ORDER BY 
    contact.[OSIRIS_ID__C]

-- ==============================================================================
