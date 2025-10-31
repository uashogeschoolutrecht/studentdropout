SELECT	  MIN(si.sinh_id) AS sinh_d											
		, si.collegejaar										
		, MIN(si.ingangsdatum) AS ingangsdatum	
		, MAX(si.afloopdatum) AS afloopdatum										
		, si.naam_en AS opl_naam_en										
		, si.opleiding										
		, MAX(si.fase_cd) AS fase -- propaedeutic fase (D) > bachelor fase (B)										
		, MAX(si.examendatum) AS p_examendatum					-- propaedeutic exam date					
        , MAX(si.ind_propedeuse_behaald) AS p_behaald													
        , MAX(si.uitstroom_zonder_diploma) AS uit_zonder_dip	--indicator for leaving the university without a diploma												
		, MAX(si.opleiding_switch_uit) AS degree_switch		-- indicator for switching to another degree
		, CASE WHEN MAX(si.uitstroom_zonder_diploma) = 1 OR MAX(si.opleiding_switch_uit) = 1 THEN 1 ELSE 0 END drop_out -- a drop-out is someone who either switches degree within the HU or leaves the HU without a degree
FROM (													
        SELECT 	i.sinh_id								
            , i.cohort_opleiding													
            , i.collegejaar													
            , CONVERT(DATE, CAST(i.d_tijd_dag_ingang_id AS CHAR(8)), 112) AS ingangsdatum													
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
			AND fase_cd = 'D'						-- propaedeutic phase			
		) SI		
WHERE MONTH(ingangsdatum) = 9						-- start month is september
	AND DAY(ingangsdatum) = 1						-- start day is the first of the month
GROUP BY  cohort_opleiding										
		, collegejaar										
		, naam_en										
		, opleiding										
		, croho										
		, type_ho_oms										
		, vorm_oms										
		, actiefcode	
ORDER BY collegejaar, OPLEIDING