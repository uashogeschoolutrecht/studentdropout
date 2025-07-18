-- This SQL script retrieves student details for those enrolled in bachelor programmes at a specific university, 
-- focusing on the propaedeutic phase of their studies.

WITH CTE_INS AS ( -- records of programme enrolment per academic year													
		SELECT MIN(si.sinh_id) AS sinh_id																				
			 , MIN(si.ingangsdatum) AS ingangsdatum
			 , FASE_CD [fase]
			 , D_STUDENT_ID
		FROM (													
            SELECT i.sinh_id	
                    , CONVERT(DATE, CAST(i.d_tijd_dag_ingang_id AS CHAR(8)), 112) AS ingangsdatum	
					, f.FASE_CD
					, i.D_STUDENT_ID
			FROM DM.VW_DM_F_STUDENT_INSCHRIJFHIST i													
				JOIN DM.VW_DM_D_OPLEIDING o ON i.d_opleiding_id = o.d_opleiding_id								
				JOIN DM.VW_DM_D_VORM v ON i.d_vorm_id = v.d_vorm_id				
				JOIN DM.VW_DM_D_FASE f ON i.D_FASE_ID = f.D_FASE_ID
				JOIN DM.VW_DM_D_BEKOSTIGING b ON i.d_bekostiging_id = b.d_bekostiging_id								
				JOIN DM.VW_DM_D_CROHO c ON i.d_croho_id = c.d_croho_id								
				JOIN DM.VW_DM_D_ACTIEFCODE ac ON i.d_actiefcode_opleiding_id = ac.d_actiefcode_id
			WHERE ac.actiefcode = '4'					-- enrolled students				
				AND c.croho LIKE '3%'					-- bachelor programmes			
				AND b.bekostiging NOT IN ('U')			-- exclude exchange students					
				AND o.opleiding NOT LIKE 'K%'			-- excude minor students					
				AND v.vorm_cd = 'V'						-- fulltime programmes		
				AND collegejaar BETWEEN 2018			-- scope query					
					AND 2023							-- not including running year
				AND collegejaar = cohort_opleiding		-- first year students						
				) SI		
		GROUP BY 
		FASE_CD
		, D_STUDENT_ID
)									

-- Final selection with student details
SELECT		QUERY_ADDED_STUDENT_DETAILS.sinh_id, 
			QUERY_ADDED_STUDENT_DETAILS.gender,
			QUERY_ADDED_STUDENT_DETAILS.Dutch_nationality,
			QUERY_ADDED_STUDENT_DETAILS.[postal_code_PLACEHOLDER],
			DATEDIFF(YEAR, date_of_birth, ingangsdatum) - 
			CASE WHEN MONTH(ingangsdatum) < MONTH(date_of_birth) OR (MONTH(ingangsdatum) = MONTH(date_of_birth) AND DAY(ingangsdatum) < DAY(date_of_birth)) THEN 1 ELSE 0 END
			[age_start_study]
FROM(
	SELECT	BASISQUERY.*, 
			student.GESLACHT [gender], 
			CONVERT(DATE, FORMAT(CAST(student.GEBOORTEDATUM AS DATE), 'dd-MM-yyyy'), 105)  [date_of_birth], 
			student.IND_NATIONALITEIT_NL [Dutch_nationality], 
			student.NATIONALITEIT [nationality],
			student.POSTCODE [postal_code_PLACEHOLDER]
	FROM (							
		SELECT CI.*																						
		FROM CTE_INS CI													
		WHERE fase = 'D' -- propaedeutic phase
		) BASISQUERY
	LEFT JOIN DM.D_STUDENT student ON BASISQUERY.D_STUDENT_ID = student.D_STUDENT_ID
	) QUERY_ADDED_STUDENT_DETAILS