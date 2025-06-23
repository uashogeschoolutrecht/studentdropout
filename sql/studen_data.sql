WITH 
-- Base query for student course results with case logic for course points
base_student_cursus AS (
	SELECT student_course_results.[D_CROHO_ACTUEEL_ID]
		,student_course_results.[D_OPLEIDING_ID]
		,student_course_results.[D_STUDENT_ID]
		,student_course_results.[D_STUDIEJAAR_ID]
		,student_course_results.[D_VORM_ID]
		,student_course_results.[D_FASE_ID]
		,student_course_results.[COHORT_OPLEIDING]
		,student_course_results.[CURSUS_COLLEGEJAAR]
		,student_course_results.[D_EXAMENPROGRAMMA_ID]
		,student_course_results.[D_COOR_OND_ORGANISATIE_ID]
		,student_course_results.[CURSUS_GELDIG]
		,student_course_results.[CURSUS_RESULTAAT]
		,student_course_results.[D_TIJD_DAG_STUD_OPL_AANVANGSDATUM_ID]
		,exam_program.[MINIMUM_PUNTEN]
		,CASE 
			WHEN student_course_results.[CURSUS_PUNTEN] IS NULL
				THEN 0
			WHEN [CURSUS_VOLDOENDE_GR] <> 1
				THEN 0
			ELSE student_course_results.[CURSUS_PUNTEN]
			END AS [CURSUS_PUNTEN]
	FROM [DM].[VW_DM_F_STUDENT_CURSUS_RESULTAAT] AS student_course_results
	LEFT JOIN [DM].[VW_DM_D_EXAMENPROGRAMMA] AS exam_program ON student_course_results.[D_EXAMENPROGRAMMA_ID] = exam_program.[D_EXAMENPROGRAMMA_ID]
),

-- Aggregated course results with joins to dimension tables
aggregated_results AS (
	SELECT base_data.[D_CROHO_ACTUEEL_ID]
		,base_data.[D_OPLEIDING_ID]
		,base_data.[D_STUDENT_ID]
		,base_data.[D_STUDIEJAAR_ID]
		,base_data.[D_VORM_ID]
		,base_data.[D_FASE_ID]
		,phase.[FASE_CD]
		,base_data.[COHORT_OPLEIDING]
		,base_data.[CURSUS_COLLEGEJAAR]
		,base_data.[D_EXAMENPROGRAMMA_ID]
		,base_data.[D_TIJD_DAG_STUD_OPL_AANVANGSDATUM_ID]
		,organization.[L4_ORGANISATIE_CD]
		,MAX(organization.[D_ORGANISATIE_ID]) AS [D_ORGANISATIE_ID]
		,CAST(LEFT(RIGHT(base_data.D_TIJD_DAG_STUD_OPL_AANVANGSDATUM_ID, 4), 2) AS INT) AS STARTMAAND
		,student.[STUDENTNUMMER] AS Studentnummer
		,SUM(base_data.[CURSUS_PUNTEN]) AS STUDIEPUNTEN_COLLEGEJAAR
		,base_data.[MINIMUM_PUNTEN] AS NOMINALE_PUNTEN_EXAMENPROGRAMMA
	FROM base_student_cursus AS base_data
	LEFT JOIN [DM].[VW_DM_D_STUDENT] AS student ON base_data.[D_STUDENT_ID] = student.[D_STUDENT_ID]
	LEFT JOIN [DM].[VW_DM_D_ORGANISATIE] AS organization ON base_data.[D_COOR_OND_ORGANISATIE_ID] = organization.[D_ORGANISATIE_ID]
	LEFT JOIN [DM].[VW_DM_D_FASE] AS phase ON base_data.[D_FASE_ID] = phase.[D_FASE_ID]
	WHERE base_data.[CURSUS_COLLEGEJAAR] > YEAR(GETDATE()) - 10
		AND base_data.[CURSUS_GELDIG] = 1
		AND base_data.[CURSUS_RESULTAAT] <> 'VRY-O'
	GROUP BY base_data.[D_CROHO_ACTUEEL_ID]
		,base_data.[D_OPLEIDING_ID]
		,base_data.[D_STUDENT_ID]
		,base_data.[D_STUDIEJAAR_ID]
		,base_data.[D_VORM_ID]
		,base_data.[D_FASE_ID]
		,phase.[FASE_CD]
		,base_data.[MINIMUM_PUNTEN]
		,base_data.[COHORT_OPLEIDING]
		,base_data.[CURSUS_COLLEGEJAAR]
		,base_data.[D_EXAMENPROGRAMMA_ID]
		,organization.[L4_ORGANISATIE_CD]
		,student.[STUDENTNUMMER]
		,base_data.[D_TIJD_DAG_STUD_OPL_AANVANGSDATUM_ID]
),

-- Base query for calculating nominal points per education program
nominal_points_base AS (
	SELECT student_course_results.[D_OPLEIDING_ID]
		,student_course_results.[D_STUDENT_ID]
		,student_course_results.[D_FASE_ID]
		,student_course_results.[CURSUS_GELDIG]
		,student_course_results.[COHORT_OPLEIDING]
		,student_course_results.[D_EXAMENPROGRAMMA_ID]
		,student_course_results.[D_COOR_OND_ORGANISATIE_ID]
		,exam_program.[MINIMUM_PUNTEN]
	FROM [DM].[VW_DM_F_STUDENT_CURSUS_RESULTAAT] AS student_course_results
	LEFT JOIN [DM].[VW_DM_D_EXAMENPROGRAMMA] AS exam_program ON student_course_results.[D_EXAMENPROGRAMMA_ID] = exam_program.[D_EXAMENPROGRAMMA_ID]
),

-- Grouped nominal points with phase information
nominal_points_grouped AS (
	SELECT base_data.[D_OPLEIDING_ID]
		,base_data.[D_STUDENT_ID]
		,phase.[FASE_CD]
		,base_data.[D_FASE_ID]
		,base_data.[COHORT_OPLEIDING]
		,base_data.[MINIMUM_PUNTEN]
	FROM nominal_points_base AS base_data
	LEFT JOIN [DM].[VW_DM_D_STUDENT] AS student ON base_data.[D_STUDENT_ID] = student.[D_STUDENT_ID]
	LEFT JOIN [DM].[VW_DM_D_FASE] AS phase ON base_data.[D_FASE_ID] = phase.[D_FASE_ID]
	WHERE base_data.[COHORT_OPLEIDING] > YEAR(GETDATE()) - 10
		AND base_data.[CURSUS_GELDIG] = 1
	GROUP BY base_data.[D_OPLEIDING_ID]
		,base_data.[D_STUDENT_ID]
		,phase.[FASE_CD]
		,base_data.[D_FASE_ID]
		,base_data.[MINIMUM_PUNTEN]
		,base_data.[COHORT_OPLEIDING]
),

-- Final calculation of nominal points per education program
nominal_points_opleiding AS (
	SELECT [D_OPLEIDING_ID]
		,[D_STUDENT_ID]
		,SUM(MINIMUM_PUNTEN) AS NOMINALE_PUNTEN_OPLEIDING
	FROM nominal_points_grouped
	GROUP BY [D_OPLEIDING_ID]
		,[D_STUDENT_ID]
),

-- Base query for exemption points calculation
exemption_points_base AS (
	SELECT student_course_results.[D_OPLEIDING_ID]
		,student_course_results.[D_STUDENT_ID]
		,student_course_results.[D_FASE_ID]
		,student_course_results.[CURSUS_GELDIG]
		,student_course_results.[COHORT_OPLEIDING]
		,student_course_results.[D_EXAMENPROGRAMMA_ID]
		,student_course_results.[CURSUS_RESULTAAT]
		,student_course_results.[D_COOR_OND_ORGANISATIE_ID]
		,SUM(student_course_results.[CURSUS_PUNTEN]) AS CURSUS_PUNTEN
	FROM [DM].[VW_DM_F_STUDENT_CURSUS_RESULTAAT] AS student_course_results
	WHERE student_course_results.[CURSUS_GELDIG] = 1
		AND student_course_results.[CURSUS_RESULTAAT] = 'VRY-O'
	GROUP BY student_course_results.[D_OPLEIDING_ID]
		,student_course_results.[D_STUDENT_ID]
		,student_course_results.[D_FASE_ID]
		,student_course_results.[CURSUS_GELDIG]
		,student_course_results.[COHORT_OPLEIDING]
		,student_course_results.[D_EXAMENPROGRAMMA_ID]
		,student_course_results.[CURSUS_RESULTAAT]
		,student_course_results.[D_COOR_OND_ORGANISATIE_ID]
),

-- Final exemption points calculation
exemption_points AS (
	SELECT [D_OPLEIDING_ID]
		,[D_STUDENT_ID]
		,[COHORT_OPLEIDING]
		,SUM([CURSUS_PUNTEN]) AS STUDIEPUNTEN_VRIJSTELLING
		,1 AS VRIJSTELLING 
	FROM exemption_points_base
	GROUP BY [D_OPLEIDING_ID]
		,[D_STUDENT_ID]
		,[COHORT_OPLEIDING]
)

-- Main SELECT statement
SELECT TOP 10000 [D_CROHO_ACTUEEL_ID]
	,main_results.[D_OPLEIDING_ID]
	,main_results.[D_STUDENT_ID]
	,main_results.[D_EXAMENPROGRAMMA_ID]
	,[D_STUDIEJAAR_ID]
	,[D_VORM_ID]
	,[D_FASE_ID]
	,[FASE_CD]
	,main_results.[COHORT_OPLEIDING]
	,[CURSUS_COLLEGEJAAR]
	,[D_TIJD_DAG_STUD_OPL_AANVANGSDATUM_ID]
	,[D_ORGANISATIE_ID]
	,[L4_ORGANISATIE_CD]
	,[Studentnummer]
	,[STUDIEPUNTEN_VRIJSTELLING]
	,[VRIJSTELLING]
	,[STUDIEPUNTEN_COLLEGEJAAR]
  -- Running sum op het aantal studiepunten per collegejaar voor het examenprogramma. 
  -- Totaal aanal EC's per student, cohort, opleiding, collegejaar. 
	,SUM(STUDIEPUNTEN_COLLEGEJAAR) OVER (
		PARTITION BY [D_CROHO_ACTUEEL_ID]
		,main_results.[D_OPLEIDING_ID]
		,main_results.[D_STUDENT_ID]
		,Studentnummer
		,[D_VORM_ID]
		,[D_FASE_ID]
		,main_results.[COHORT_OPLEIDING] ORDER BY [CURSUS_COLLEGEJAAR]
		) AS STUDIEPUNTEN_COHORT_EXAMENPROGRAMMA
	,[NOMINALE_PUNTEN_EXAMENPROGRAMMA]
  
  -- Running sum op het aantal studiepunten per collegejaar voor de opleiding. 
  -- Totaal aanal EC's per student, cohort, opleiding, collegejaar. 
	,SUM(STUDIEPUNTEN_COLLEGEJAAR) OVER (
		PARTITION BY [D_CROHO_ACTUEEL_ID]
		,main_results.[D_OPLEIDING_ID]
		,main_results.[D_STUDENT_ID]
		,Studentnummer
		,[D_VORM_ID]
		,main_results.[COHORT_OPLEIDING] ORDER BY [CURSUS_COLLEGEJAAR]
		) AS STUDIEPUNTEN_COHORT_OPLEIDING

    -- Omdat de totale opleidingspunten in de bachelor fase verdeeld worden over propeudeuse plus hoofdfase.
    -- Us de som op de nominale punten voor de opleiding niet juist, hier wordt voor gecorrigeerd.
	,CASE 
		WHEN [FASE_CD] = 'D'
			OR [FASE_CD] = 'B'
			THEN 240
		ELSE nominal_points.[NOMINALE_PUNTEN_OPLEIDING]
		END AS [NOMINALE_PUNTEN_OPLEIDING]
FROM aggregated_results AS main_results

-- NOMINALE_PUNTEN_OPLEIDING berkend, som van minimum aantal benodigde punten per opleiding/student. 
-- Voor berekening van percentage behaald.
LEFT JOIN nominal_points_opleiding AS nominal_points ON main_results.[D_OPLEIDING_ID] = nominal_points.[D_OPLEIDING_ID]
	AND main_results.[D_STUDENT_ID] = nominal_points.[D_STUDENT_ID]

-- STUDIEPUNTEN_VRIJSTELLING totaal aantal punten behaald die als vrijstelling gemarkeerd zijn. 
-- Deze zijn nodig voor de berekening van de nominale studiepunten. Vrijstelling wordt van de nominale punten
-- afgehaald voor de berekining van percentatge behaald. 
LEFT JOIN exemption_points AS exemptions ON main_results.[D_OPLEIDING_ID] = exemptions.[D_OPLEIDING_ID]
	AND main_results.[D_STUDENT_ID] = exemptions.[D_STUDENT_ID]
	AND main_results.[COHORT_OPLEIDING] = exemptions.[COHORT_OPLEIDING]