------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- Events
-- Within M&C "online opendag" is also treated as an "open day" you could debate this because there are relativily high numbers in attending online opendays.
-- maybe for the analysis it is better to treat it as a separate category
-- Salesforce does not have date from 2019 so the data set is limited.
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- Event time and event type
select distinct
st.STUDENTNUMMER,
left(e.[CONFERENCE360__EVENT_START_DATE__C],10) Event_start_datum,
CASE
    WHEN e.EVENTTYPE__C LIKE '%Online voorlichting voor ouders%' THEN 'Online voorlichting voor ouders'
    WHEN e.[NAME] LIKE '%TEST EVENT%' OR e.[NAME] LIKE '%Test%' THEN 'Test event'
    WHEN e.EVENTTYPE__C LIKE '%Kennismaken op locatie%' OR e.EVENTTYPE__C LIKE '%Open les op locatie%' THEN 'Kennismaken op locatie'
    WHEN e.EVENTTYPE__C LIKE '%Mastermarkt%' OR e.[NAME] LIKE '%Mastermarkt%' THEN 'Mastermarkt'
    WHEN e.EVENTTYPE__C LIKE '%Meeloopdag op locatie%' 
         OR e.[NAME] LIKE '%Online orientation day%' 
         OR e.[NAME] LIKE '%Meeloopdag%' 
         OR e.[NAME] LIKE '%Orientation day%' 
         OR e.[NAME] LIKE '%Online meeloopdag%' 
         OR e.[NAME] LIKE '%Online student for a day%' 
         OR e.[NAME] LIKE '%Proefstuderen%' 
         OR e.TYPE__C LIKE '%Guided Tour%' 
         OR e.TYPE__C LIKE '%Rondleiding%'
                              OR e.[NAME] LIKE '%Rondleiding%' THEN 'Meeloopdag'
    WHEN e.EVENTTYPE__C LIKE '%Online opleidingspresentatie%' OR e.EVENTTYPE__C LIKE '%Online presentation%' THEN 'Online opleidingspresentatie'
    WHEN e.EVENTTYPE__C LIKE '%Online open avond%' 
         OR e.[NAME] LIKE '%Online open avond%' 
         OR e.[NAME] LIKE '%Online open evening%' THEN 'Online open avond'
    WHEN e.EVENTTYPE__C LIKE '%Open dag op locatie%' 
         OR e.[NAME] LIKE '%Online open dag%' 
         OR e.[NAME] LIKE '%Online open day%' THEN 'Open dag'
    WHEN e.[NAME] LIKE '%U-Talent%' THEN 'U-Talent'
    WHEN e.[NAME] LIKE '%Online vragenuur%' 
         OR e.[NAME] LIKE '%Online chat hour%' 
         OR e.[NAME] LIKE '%Inspiratiecollege%' THEN 'Online event'
    ELSE 'Onbekend'
END AS EventCategorie

FROM
[Marketing].[VW_DM_F_SAF_EVENT_AANWEZIGE] ea
JOIN [Marketing].[VW_DM_D_STUDENT] st on ea.d_student_id = st.d_student_id
JOIN [Marketing].VW_DM_D_SAF_EVENT e on ea.D_SAF_EVENT_ID = e.D_SAF_EVENT_ID
JOIN [Marketing].[VW_DM_D_SAF_AANWEZIGE_STATUS] eas on eas.D_SAF_AANWEZIGE_STATUS_ID = ea.D_SAF_AANWEZIGE_STATUS_ID
WHERE 1=1
AND st.D_STUDENT_ID <> -1
AND eas.AANWEZIGE_STATUS = 'attended' 
AND [CONFERENCE360__EVENT_START_DATE__C] >= '2018-01-01T00:00:00'
AND (e.[NAME] NOT LIKE '%TEST EVENT%' OR e.[NAME] NOT LIKE '%Test%')
AND st.META_ACTUEEL_IND = 1
AND e.META_ACTUEEL_IND = 1
AND eas.META_ACTUEEL_IND = 1;
