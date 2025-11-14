/*
 * ============================================================================
 * STUDENT DEGREE AND DROP-OUT ANALYSIS WITH POSTAL CODE
 * ============================================================================
 * 
 * Purpose:
 * --------
 * Retrieves comprehensive student enrollment and drop-out information for 
 * first-year bachelor students at HU University of Applied Sciences Utrecht.
 * Includes student postal codes at the start of their degree program.
 * 
 * Scope:
 * ------
 * - Academic years: 2018-2023
 * - Student type: First-year bachelor students
 * - Program type: Full-time (Voltijd) programs
 * - Phase: Propaedeutic (first year)
 * - Start date: September 1st enrollments only
 * - Excludes: Exchange students, minor programs
 * 
 * Key Features:
 * -------------
 * 1. Student postal code at enrollment start (Dutch addresses only)
 * 2. Multiple drop-out classifications:
 *    - With propaedeutic certificate
 *    - Without propaedeutic certificate
 *    - Transfer to other HU degree
 *    - Temporary drop-out
 * 3. De-enrollment date tracking
 * 
 * Output Columns:
 * ---------------
 * - SINH_ID: Student enrollment history ID
 * - COLLEGEJAAR: Academic year
 * - degree: Degree name (English)
 * - degree_code_letters: Letter-based degree code
 * - degree_code: CROHO code (official Dutch degree identifier)
 * - enrollment_date: Date of enrollment request
 * - degree_start_date: Start date of degree program
 * - degree_end_date: End date of degree program
 * - de_enrollment_date: Date student requested to stop (if applicable)
 * - drop_out_with_propedeuse: Binary flag (1 = dropped out with certificate)
 * - drop_out_without_propedeuse: Binary flag (1 = dropped out without certificate)
 * - drop_out_to_other_degree_in_HU: Binary flag (1 = transferred to other HU program)
 * - drop_out_temporary: Binary flag (1 = temporary leave)
 * - drop_out: Binary flag (1 = any type of drop-out)
 * - POSTCODE: 4-digit postal code (Dutch addresses only)
 * - POSTAL_COUNTRY_NL: Binary flag (1 = Dutch address, 0 = foreign)
 * 
 * Business Rules:
 * ---------------
 * - Only enrolled students (actiefcode = '4')
 * - Bachelor programs only (CROHO code starts with '3')
 * - Excludes exchange students (bekostiging <> 'U')
 * - Excludes minor programs (opleiding not starting with 'K')
 * - Full-time programs only (vorm_cd = 'V')
 * - First-year students only (collegejaar = cohort_opleiding)
 * - Propaedeutic phase only (fase_cd = 'D')
 * - September 1st start dates only (D_TIJD_DAG_INGANG_ID % 10000 = 901)
 * 
 * Data Sources:
 * -------------
 * - DM.F_STUDENT_INSCHRIJFHIST: Main enrollment history fact table
 * - ODS.OSS_H_S_ADRES: Student address history
 * - ODS.OSS_STUDENT_INSCHRIJFHIST: Enrollment stop requests
 * - Various dimension tables (D_OPLEIDING, D_STUDENT, D_CROHO, etc.)
 * 
 * ============================================================================
 */

/*
 * ============================================================================
 * CTE: AddressAtStart
 * ============================================================================
 * 
 * Purpose:
 * --------
 * Determines the student's postal code at the start of their degree program
 * by finding the most recent address record before or at the enrollment date.
 * 
 * Logic:
 * ------
 * 1. Retrieves student addresses of type 'ST' (student address)
 * 2. Filters addresses with mutation date <= degree start date
 * 3. Uses ROW_NUMBER to rank addresses by mutation date (most recent first)
 * 4. Extracts first 4 digits of postal code for Dutch addresses only
 * 5. Flags whether address is in the Netherlands (NL)
 * 
 * Output Fields:
 * --------------
 * - STUDENTNUMMER: Student number
 * - POSTCODE: First 4 digits of postal code (NULL if not Dutch address)
 * - POSTAL_COUNTRY_NL: 1 if address is in NL, 0 otherwise
 * - MUTATIE_DATUM: Date address was last modified
 * - D_TIJD_DAG_INGANG_ID: Degree start date ID
 * - rn: Row number (1 = most recent address at enrollment)
 * 
 * ============================================================================
 */
WITH AddressAtStart AS (
    SELECT 
        s.STUDENTNUMMER,
        CASE WHEN ad.POSTCODE IS NULL or LAND <> 'NL' THEN NULL ELSE LEFT(ad.POSTCODE, 4) END [POSTCODE],
		CASE WHEN ad.LAND = 'NL' THEN 1 ELSE 0 END [POSTAL_COUNTRY_NL],
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
), 
/*
 * ============================================================================
 * CTE: CTE_STOPVERZOEK
 * ============================================================================
 * 
 * Purpose:
 * --------
 * Retrieves the date when students submitted a de-enrollment (stop) request
 * that was honored by the institution.
 * 
 * Description:
 * ------------
 * This query extracts student enrollment history records where students have
 * submitted a stop request that has been honored. It only includes current records
 * where the stop request date is valid and occurs before or on the expiration date.
 * 
 * Returns:
 * --------
 * - SINH_ID: Student enrollment history ID
 * - DATUM_VERZOEK_STOPPEN: Stop request date (formatted as dd-MM-yyyy)
 * 
 * Business Rules:
 * ---------------
 * 1. Only current records (ODS_ACTUEEL_IND = 1)
 * 2. Stop request date must be present
 * 3. Stop request must be honored (not rejected with 'N')
 * 4. Stop request date must be before or on the expiration date of degree
 * 
 * ============================================================================
 */
CTE_STOPVERZOEK AS (
SELECT
    SINH_ID
    , FORMAT(DATUM_VERZOEK_STOPPEN, 'dd-MM-yyyy') AS DATUM_VERZOEK_STOPPEN
FROM ODS.OSS_STUDENT_INSCHRIJFHIST
WHERE ODS_ACTUEEL_IND = 1                                       -- Only current/active records
    AND DATUM_VERZOEK_STOPPEN IS NOT NULL                       -- Stop request date must exist
    AND VERZOEK_STOPPEN_GEHONOREERD <> 'N'                      -- Request must be honored (not rejected)
    AND DATEDIFF(DAY, DATUM_VERZOEK_STOPPEN, AFLOOPDATUM) >= 0  -- Stop request date must be on or before expiration date of degree
)

/*
 * ============================================================================
 * MAIN QUERY
 * ============================================================================
 * 
 * Purpose:
 * --------
 * Combines enrollment data with address information and stop requests to create
 * a comprehensive dataset for student drop-out analysis.
 * 
 * Drop-Out Classifications:
 * -------------------------
 * 1. drop_out_with_propedeuse:
 *    - Student left (with/without diploma) AND completed propaedeutic phase
 * 
 * 2. drop_out_without_propedeuse:
 *    - Student left without diploma AND did NOT complete propaedeutic phase
 * 
 * 3. drop_out_to_other_degree_in_HU:
 *    - Student left (with/without diploma) AND switched to another HU program
 * 
 * 4. drop_out_temporary:
 *    - Student took temporary leave (may return)
 * 
 * 5. drop_out (overall flag):
 *    - ANY of the above conditions (left without diploma, with diploma, or temporary)
 * 
 * Joins:
 * ------
 * - LEFT JOIN to dimension tables to enrich enrollment data
 * - LEFT JOIN to AddressAtStart CTE (rn=1 for most recent address)
 * - LEFT JOIN to CTE_STOPVERZOEK for de-enrollment dates
 * 
 * Filters:
 * --------
 * - Enrolled students only (actiefcode = '4')
 * - Bachelor programs (CROHO starts with '3')
 * - Excludes exchange students (bekostiging <> 'U')
 * - Excludes minor programs (opleiding not starting with 'K')
 * - Full-time programs (vorm_cd = 'V')
 * - Academic years 2018-2023
 * - First-year students (collegejaar = cohort_opleiding)
 * - Propaedeutic phase (fase_cd = 'D')
 * - September 1st start dates (D_TIJD_DAG_INGANG_ID % 10000 = 901)
 * 
 * ============================================================================
 */
-- Main query to retrieve degree and drop-out information
SELECT
      -- Identifiers
      i.SINH_ID                               -- Student enrollment history ID (unique key)
	, i.COLLEGEJAAR                           -- Academic year of enrollment
    
    -- Degree information
    , o.naam_en AS degree                     -- Degree name in English
    , o.opleiding AS degree_code_letters      -- Letter-based degree code
    , c.croho AS degree_code                  -- Official CROHO registration code
    
    -- Important dates
    , i.D_TIJD_DAG_VERZOEK_INS_ID AS enrollment_date      -- Date enrollment was requested
    , i.D_TIJD_DAG_INGANG_ID AS degree_start_date         -- Date degree program started
	, i.D_TIJD_DAG_AFLOOP_ID AS degree_end_date           -- Date degree program ended
    , sv.DATUM_VERZOEK_STOPPEN AS de_enrollment_date      -- Date student requested to stop
	
    -- Drop-out classifications (binary flags)
	, CASE 
		WHEN (i.UITSTROOM_ZONDER_DIPLOMA = 1 OR i.UITSTROOM_MET_DIPLOMA = 1) AND IND_PROPEDEUSE_BEHAALD = 1 
		THEN 1 
		ELSE 0
		END AS drop_out_with_propedeuse           -- Dropped out after completing first year certificate
	, CASE
		WHEN i.UITSTROOM_ZONDER_DIPLOMA = 1 AND IND_PROPEDEUSE_BEHAALD = 0
		THEN 1
		ELSE 0
		END AS drop_out_without_propedeuse        -- Dropped out without first year certificate
	, CASE
		WHEN (i.UITSTROOM_ZONDER_DIPLOMA = 1 OR i.UITSTROOM_MET_DIPLOMA = 1) AND i.OPLEIDING_SWITCH_UIT = 1
		THEN 1
		ELSE 0
		END AS drop_out_to_other_degree_in_HU     -- Transferred to another program within HU
	, i.TIJDELIJKE_UITSTROOM as drop_out_temporary    -- Temporary leave of absence
    , CASE 
        WHEN i.UITSTROOM_ZONDER_DIPLOMA = 1 
          OR i.UITSTROOM_MET_DIPLOMA = 1 
		  OR i.TIJDELIJKE_UITSTROOM = 1
        THEN 1 ELSE 0 
      END AS drop_out                             -- Overall drop-out flag (any type)
    
    -- Address information at enrollment
    , aa.POSTCODE                                 -- 4-digit postal code (Dutch addresses only)
	, aa.[POSTAL_COUNTRY_NL]                      -- Flag: 1=Netherlands, 0=foreign address

-- Data source: Main enrollment history fact table
FROM [DM].[F_STUDENT_INSCHRIJFHIST] i

-- Join dimension tables for descriptive attributes
LEFT JOIN DM.VW_DM_D_OPLEIDING o ON i.d_opleiding_id = o.d_opleiding_id          -- Degree information
LEFT JOIN DM.VW_DM_D_VORM v ON i.d_vorm_id = v.d_vorm_id                         -- Study form (full-time/part-time)
LEFT JOIN DM.VW_DM_D_FASE f ON i.d_fase_id = f.d_fase_id                         -- Study phase (propaedeutic/main)
LEFT JOIN DM.VW_DM_D_BEKOSTIGING b ON i.d_bekostiging_id = b.d_bekostiging_id    -- Funding type
LEFT JOIN DM.VW_DM_D_STUDENT s ON i.d_student_id = s.d_student_id                -- Student details
LEFT JOIN DM.VW_DM_D_CROHO c ON i.d_croho_id = c.d_croho_id                      -- CROHO registration codes
LEFT JOIN DM.VW_DM_D_ACTIEFCODE ac ON i.d_actiefcode_opleiding_id = ac.d_actiefcode_id  -- Enrollment status

-- Join to CTE for most recent address at enrollment start
LEFT JOIN AddressAtStart aa ON aa.STUDENTNUMMER = s.STUDENTNUMMER 
    AND aa.D_TIJD_DAG_INGANG_ID = i.D_TIJD_DAG_INGANG_ID 
    AND aa.rn = 1  -- Only the most recent address before/at enrollment

-- Join to CTE for de-enrollment request information
LEFT JOIN CTE_STOPVERZOEK sv ON sv.SINH_ID = i.SINH_ID

-- Apply business filters
WHERE ac.actiefcode = '4'                       -- Only enrolled students (active enrollment status)
  AND c.croho LIKE '3%'                         -- Only bachelor programs (CROHO codes starting with 3)
  AND b.bekostiging NOT IN ('U')                -- Exclude exchange/visiting students
  AND o.opleiding NOT LIKE 'K%'                 -- Exclude minor programs (codes starting with K)
  AND v.vorm_cd = 'V'                           -- Only full-time programs (Voltijd)
  AND collegejaar BETWEEN 2018 AND 2023         -- Academic years 2018-2023
  AND collegejaar = cohort_opleiding            -- Only first-year students (enrollment year = cohort year)
  AND fase_cd = 'D'                             -- Only propaedeutic phase (first year)
  AND i.D_TIJD_DAG_INGANG_ID % 10000 = 901      -- Only September 1st start dates (date ID ending in 0901)

-- Sort results by enrollment history ID for consistent ordering
ORDER BY i.SINH_ID;