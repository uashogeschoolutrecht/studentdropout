WITH st_adr AS (
    SELECT
        sa.studentnummer,
        sa.adrestype,
        sa.postcode,
		sa.land,
        sa.ods_start_dts,
        sa.ods_eind_dts
    FROM VW_ODS_OSS_STUDENT_ADRES sa
    WHERE sa.adrestype IN ('GV', 'WO')
),

st_opl AS (
    SELECT
        s.studentnummer,
        si.sinh_id,
        si.collegejaar,
        o.opleiding,
        v.vorm_cd,
        td.dag as datum_verzoek_ins
    FROM VW_DM_F_STUDENT_INSCHRIJFHIST si
    JOIN VW_DM_D_STUDENT s ON si.D_STUDENT_ID = s.D_STUDENT_ID
    JOIN VW_DM_D_OPLEIDING o ON si.D_OPLEIDING_ACTUEEL_ID = o.D_OPLEIDING_ID
    JOIN VW_DM_D_VORM v ON si.D_VORM_ID = v.D_VORM_ID
    JOIN VW_DM_D_TIJD_DAG td ON si.d_tijd_dag_verzoek_ins_id = td.D_TIJD_DAG_ID
    WHERE SI.COLLEGEJAAR = SI.COHORT_OPLEIDING
      AND SI.COLLEGEJAAR BETWEEN 2018 AND 2023
)

SELECT *
FROM (
    SELECT
        so.*,
        sa.adrestype,
        sa.postcode,
		sa.land,
        sa.ods_start_dts,
        sa.ods_eind_dts,
        ROW_NUMBER() OVER (
            PARTITION BY so.studentnummer, so.opleiding, so.vorm_cd, so.collegejaar
            ORDER BY
                -- Geef voorrang aan adressen geldig op datum_verzoek_ins
                CASE
                    WHEN sa.ODS_START_DTS <= so.datum_verzoek_ins
                         AND (sa.ODS_EIND_DTS > so.datum_verzoek_ins OR sa.ODS_EIND_DTS IS NULL)
                    THEN 1
                    ELSE 2
                END,
                sa.ODS_START_DTS DESC,  -- Meest recent
                CASE sa.ADRESTYPE WHEN 'GV' THEN 1 ELSE 2 END
        ) AS rn
    FROM st_opl so
    LEFT JOIN st_adr sa ON so.studentnummer = sa.studentnummer
) s
WHERE rn = 1
--and postcode is null
--and land = 'NL'
ORDER BY studentnummer;
