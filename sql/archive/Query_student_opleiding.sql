WITH CTE_INS AS ( -- records of programme enrolment per academic year													
		SELECT si.studentnummer											
			 , si.d_student_id										
		     , MIN(si.sinh_id) AS sinh_d											
		 	 , si.cohort_opleiding -- first academic year for current programme										
			 , si.collegejaar										
			 , MIN(si.ingangsdatum) AS ingangsdatum										
			 , MAX(si.afloopdatum) AS afloopdatum										
			 , si.naam_en AS opl_naam_en										
			 , si.opleiding										
			 , si.croho										
			 , si.type_ho_oms as type_ho										
			 , si.vorm_oms AS vorm										
			 , MAX(si.fase_cd) AS fase -- propaedeutic fase (D) > bachelor fase (B)										
			 , si.actiefcode										
			 , MAX(si.examendatum) AS p_examendatum					-- propaedeutic exam date					
             , MAX(si.ind_propedeuse_behaald) AS p_behaald													
             , MAX(si.uitstroom_zonder_diploma) AS uit_zonder_dip													
			 , MAX(si.opleiding_switch_uit) AS opleiding_switch		-- indicator for switching to another study programme								
       FROM (													
              SELECT  s.studentnummer													
                    , i.d_student_id													
					, i.sinh_id								
                    , i.cohort_opleiding													
                    , i.collegejaar													
                    , FORMAT(CONVERT(DATE, CAST(i.d_tijd_dag_ingang_id AS CHAR(8)), 112), 'dd-MM-yyyy') AS ingangsdatum													
					, FORMAT(CONVERT(DATE, CAST(i.d_tijd_dag_afloop_id AS CHAR(8)), 112), 'dd-MM-yyyy') AS afloopdatum								
                    , o.naam_en													
                    , o.opleiding													
                    , c.croho													
                    , c.type_ho_oms													
                    , v.vorm_oms													
                    , f.fase_cd													
                    , ac.actiefcode													
					, CASE WHEN i.d_tijd_dag_examen_id > 0								
			 			   THEN FORMAT(CONVERT(DATE, CAST(i.d_tijd_dag_examen_id AS CHAR(8)), 112), 'dd-MM-yyyy') 							
			   			   ELSE NULL							
					  END examendatum								
                    , i.ind_propedeuse_behaald													
                    , i.uitstroom_zonder_diploma													
                    , i.opleiding_switch_uit													
                FROM DM.VW_DM_F_STUDENT_INSCHRIJFHIST i													
					JOIN DM.VW_DM_D_OPLEIDING o ON i.d_opleiding_id = o.d_opleiding_id								
					JOIN DM.VW_DM_D_VORM v ON i.d_vorm_id = v.d_vorm_id								
					JOIN DM.VW_DM_D_FASE f ON i.d_fase_id = f.d_fase_id								
					JOIN DM.VW_DM_D_BEKOSTIGING b ON i.d_bekostiging_id = b.d_bekostiging_id								
					JOIN DM.VW_DM_D_STUDENT s ON i.d_student_id = s.d_student_id								
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
        GROUP BY studentnummer													
			   , d_student_id										
		 	   , cohort_opleiding										
			   , collegejaar										
			   , naam_en										
			   , opleiding										
			   , croho										
			   , type_ho_oms										
			   , vorm_oms										
			   , actiefcode										
)													
													
SELECT CI.*													
	 , CASE WHEN uit_zonder_dip = 1 												
				AND p_behaald = 1	  THEN 1 ELSE 0 END 'C1'	-- Left HU but successfully obtained a degree (grade P).							
	 , CASE WHEN uit_zonder_dip = 1   THEN 1 ELSE 0 END 'C2'	-- Left HU unsuccessfully, without obtaining a degree (grade failed).											
	 , CASE WHEN opleiding_switch = 1 THEN 1 ELSE 0 END 'C3'	-- Did not leave HU but switched internally to a different study program.											
FROM CTE_INS CI													
WHERE fase = 'D' -- propaedeutic phase													
ORDER BY opleiding, collegejaar, studentnummer													