-- SQL query to retrieve student degree and drop-out information
-- for first-year bachelor students at HU University of Applied Sciences Utrecht
-- from 2018 to 2023, including their address at the start of the degree

WITH AddressAtStart AS (
    SELECT 
        s.STUDENTNUMMER,
        ad.POSTCODE,
		ad.LAND,
        ad.MUTATIE_DATUM,
        i.D_TIJD_DAG_INGANG_ID,
        ROW_NUMBER() OVER (
            PARTITION BY s.STUDENTNUMMER, i.D_TIJD_DAG_INGANG_ID
            ORDER BY ad.MUTATIE_DATUM DESC
        ) AS rn
    FROM [DM].[F_STUDENT_INSCHRIJFHIST] i
    LEFT JOIN DM.VW_DM_D_STUDENT s ON i.d_student_id = s.d_student_id
    LEFT JOIN ODS.OSS_H_S_ADRES ad ON ad.STUDENTNUMMER = s.STUDENTNUMMER
    WHERE ad.ADRESTYPE = 'ST'
      AND ad.MUTATIE_DATUM <= CAST(CONVERT(VARCHAR, i.D_TIJD_DAG_INGANG_ID) AS DATE)
)
SELECT
      i.SINH_ID
	, i.COLLEGEJAAR
    , o.naam_en AS degree
    , o.opleiding AS degree_code_letters
    , c.croho AS degree_code
    , i.D_TIJD_DAG_VERZOEK_INS_ID AS enrollment_date
    , i.D_TIJD_DAG_INGANG_ID AS degree_start_date
    , i.uitstroom_zonder_diploma AS drop_out_without_degree
    , i.uitstroom_met_diploma AS drop_out_with_degree
    , i.opleiding_switch_uit AS drop_out_to_other_degree_in_HU
    , CASE 
        WHEN i.UITSTROOM_ZONDER_DIPLOMA = 1 
          OR i.OPLEIDING_SWITCH_UIT = 1 
          OR i.UITSTROOM_MET_DIPLOMA = 1 
        THEN 1 ELSE 0 
      END AS drop_out
    , aa.POSTCODE
	, aa.LAND
FROM [DM].[F_STUDENT_INSCHRIJFHIST] i
LEFT JOIN DM.VW_DM_D_OPLEIDING o ON i.d_opleiding_id = o.d_opleiding_id
LEFT JOIN DM.VW_DM_D_VORM v ON i.d_vorm_id = v.d_vorm_id
LEFT JOIN DM.VW_DM_D_FASE f ON i.d_fase_id = f.d_fase_id
LEFT JOIN DM.VW_DM_D_BEKOSTIGING b ON i.d_bekostiging_id = b.d_bekostiging_id
LEFT JOIN DM.VW_DM_D_STUDENT s ON i.d_student_id = s.d_student_id
LEFT JOIN DM.VW_DM_D_CROHO c ON i.d_croho_id = c.d_croho_id
LEFT JOIN DM.VW_DM_D_ACTIEFCODE ac ON i.d_actiefcode_opleiding_id = ac.d_actiefcode_id
LEFT JOIN AddressAtStart aa 
    ON aa.STUDENTNUMMER = s.STUDENTNUMMER 
    AND aa.D_TIJD_DAG_INGANG_ID = i.D_TIJD_DAG_INGANG_ID 
    AND aa.rn = 1
WHERE ac.actiefcode = '4'					-- enrolled students
  AND c.croho LIKE '3%'						-- bachelor programmes
  AND b.bekostiging NOT IN ('U')			-- exclude exchange students
  AND o.opleiding NOT LIKE 'K%'				-- excude minor students	
  AND v.vorm_cd = 'V'						-- fulltime programmes	
  AND collegejaar BETWEEN 2018 AND 2023		-- scope query
  AND collegejaar = cohort_opleiding		-- first year students
  AND fase_cd = 'D'							-- propaedeutic phase		
  AND i.D_TIJD_DAG_INGANG_ID % 10000 = 901	-- degrees starting on 1st of september (9)
ORDER BY i.SINH_ID;
