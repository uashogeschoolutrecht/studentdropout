-- This query retrieves student details for first-year students enrolled in full-time bachelor programmes
-- during the propaedeutic phase, covering academic years 2018-2024 (excluding the current running year).
-- Exchange students and minor students are excluded from the results.

WITH CTE_INS AS ( -- CTE: Programme enrollment records per academic year													
		SELECT si.sinh_id AS sinh_id																				
			 , si.ingangsdatum AS ingangsdatum
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
			WHERE ac.actiefcode = '4'					-- Filter: Enrolled students only				
				AND c.croho LIKE '3%'					-- Filter: Bachelor programmes (CROHO codes starting with 3)			
				AND b.bekostiging NOT IN ('U')			-- Filter: Exclude exchange students					
				AND o.opleiding NOT LIKE 'K%'			-- Filter: Exclude minor students					
				AND v.vorm_cd = 'V'						-- Filter: Full-time programmes only		
				AND collegejaar BETWEEN 2018			-- Filter: Academic years 2018-2024					
					AND 2024							-- (Excludes current running year)
				AND collegejaar = cohort_opleiding		-- Filter: First-year students only						
				) SI		
				)									

-- Final selection: Student details with calculated age at study start
SELECT		QUERY_ADDED_STUDENT_DETAILS.sinh_id, 
			QUERY_ADDED_STUDENT_DETAILS.student_number,
			QUERY_ADDED_STUDENT_DETAILS.gender,
			QUERY_ADDED_STUDENT_DETAILS.Dutch_nationality,
			-- Calculate age at study start date, accounting for whether birthday has occurred
			DATEDIFF(YEAR, date_of_birth, ingangsdatum) - 
			CASE WHEN MONTH(ingangsdatum) < MONTH(date_of_birth) OR (MONTH(ingangsdatum) = MONTH(date_of_birth) AND DAY(ingangsdatum) < DAY(date_of_birth)) THEN 1 ELSE 0 END
			[age_start_study]
FROM(
	-- Subquery: Join enrollment data with student demographic information
	SELECT	BASISQUERY.*, 
			student.GESLACHT [gender], 
			CONVERT(DATE, FORMAT(CAST(student.GEBOORTEDATUM AS DATE), 'dd-MM-yyyy'), 105)  [date_of_birth], 
			student.IND_NATIONALITEIT_NL [Dutch_nationality], 
			student.NATIONALITEIT [nationality],
			student.STUDENTNUMMER [student_number]
	FROM (							
		SELECT CI.*																						
		FROM CTE_INS CI													
		WHERE fase = 'D' -- Filter: Propaedeutic phase (fase code 'D')
		) BASISQUERY
	LEFT JOIN DM.D_STUDENT student ON BASISQUERY.D_STUDENT_ID = student.D_STUDENT_ID
	) QUERY_ADDED_STUDENT_DETAILS