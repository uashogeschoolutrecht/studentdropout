Research considerations
===============

## Business objective
The objective of this project is to develop an early warning tool that uses enrollment data to proactively identify students at risk of dropping out. By providing timely and tailored interventions, Hogeschool Utrecht aims to enhance student success, reduce dropout rates, and promote equitable educational outcomes.

**Research Question: **
Can we identify a correlation between enrollment data from Studielink or osiris and student dropout rates at Hogeschool Utrecht, and can we develop a predictive model to accurately forecast which students are at risk of dropping out?


## Data Understanding

The discussion with Financy Control and Analytics focused on using historical student data to predict dropout risks, involving data sources such as Osiris and Studielink, and ensuring compliance with privacy regulations.

- **Data Sources and Attributes**:
    - **Osiris**: Provides comprehensive student registration history, including demographics, enrollment status, and academic performance.
    - **Studielink**: Contains initial application data, useful for early risk assessment. However it is not very specific. 

- **Data Processing and Tools**:
    - **Azure Data Factory**: Utilized for data transformation and integration. This will be our data source. 
    - **Research Cloud**: Used for secure data analysis and running predictive models.

- **Privacy and Data Access**:
    - Coordination with the privacy officer is necessary to ensure compliance with privacy regulations.
    - Potential use of anonymized or aggregated data to protect student privacy.

- **Next Steps**:
    - Perform exploratory data analysis (EDA) on sample datasets from Osiris and Studielink.
    - Identify and select relevant features for the predictive model.
    - Clean and preprocess the data, ensuring it is suitable for modeling.
    - Regularly review findings and ensure compliance with privacy regulations throughout the process.


## Data from osiris database

ODS.OSS_STUDENT_INSCHRIJFHIST Table

| Column Name                   | Data Type      | Nullable | Description |
|-------------------------------|----------------|----------|-------------|
| ODS_ID                        | int            | NOT NULL | Primary key identifier |
| ODS_ID_HASH                   | binary(32)     | NULL     | Hash of ODS ID |
| ODS_COLUMNS_HASH              | binary(32)     | NULL     | Hash of all column data |
| ODS_START_DTS                 | datetime       | NULL     | Start datetime stamp |
| ODS_EIND_DTS                  | datetime       | NULL     | End datetime stamp |
| ODS_ACTUEEL_IND               | int            | NULL     | Indicator of current data |
| META_LAAD_DTS                 | datetime       | NULL     | Metadata load datetime |
| META_LEVEL1_RUN_ID            | nvarchar(max)  | NULL     | Metadata run identifier |
| STUDENTNUMMER                 | nvarchar(255)  | NULL     | Student number |
| OPLEIDING                     | nvarchar(255)  | NULL     | Program of study |
| HOOFD_OPLEIDING               | nvarchar(255)  | NULL     | Main program of study |
| COLLEGEJAAR                   | bigint         | NULL     | Academic year |
| INGANGSDATUM                  | datetime2(7)   | NULL     | Start date |
| AFLOOPDATUM                   | datetime2(7)   | NULL     | End date |
| SOORT_INSCHRIJVING_FAC        | nvarchar(255)  | NULL     | Type of enrollment |
| EXAMENTYPE_CSA                | nvarchar(255)  | NULL     | Exam type |
| VOLTIJD_DEELTIJD              | nvarchar(255)  | NULL     | Full-time/Part-time indicator |
| ACTIEFCODE_OPLEIDING_CSA      | nvarchar(255)  | NULL     | Active code of program |
| MUTATIEDATUM_ACTIEFCODE       | datetime2(7)   | NULL     | Date of last modification of active code |
| INTREKKING_VOORAANMELDING     | datetime2(7)   | NULL     | Date of withdrawal of pre-registration |
| BEEINDIGINGSREDEN             | nvarchar(255)  | NULL     | Reason for termination |
| CROHO                         | nvarchar(255)  | NULL     | Official register of higher education programs in NL |
| DATUM_BEWIJS_INSCHRIJVING     | datetime2(7)   | NULL     | Date of registration proof |
| BRINCODE                      | nvarchar(255)  | NULL     | Institution code |
| VESTIGINGSPLAATS              | nvarchar(255)  | NULL     | Place of establishment |
| DATUM_VERZOEK_INSCHR          | datetime2(7)   | NULL     | Date of enrollment request |
| INSCHRIJVINGSTATUS            | nvarchar(255)  | NULL     | Enrollment status |
| WERKZAAMHEDEN                 | nvarchar(255)  | NULL     | Employment details |
| AANVULLENDE_EISEN             | nvarchar(255)  | NULL     | Additional requirements |
| STATUS_VOOROPLEIDING          | nvarchar(255)  | NULL     | Status of prior education |
| TAALTOETS                     | nvarchar(255)  | NULL     | Language test results |
| HOGEREJAARS_VERZOEK           | nvarchar(255)  | NULL     | Request for upper-year students |
| HOGEREJAARS_GEACCEPTEERD      | nvarchar(255)  | NULL     | Accepted upper-year students |
| LOTINGVORM                    | nvarchar(255)  | NULL     | Form of lottery |
| DECENTRALE_SELECTIE_RESULTAAT | nvarchar(255)  | NULL     | Result of decentralized selection |
| DECENTRALE_SELECTIE_VOLGNUMMER| bigint         | NULL     | Follow-up number for decentralized selection |
| LOTINGRESULTAAT               | nvarchar(255)  | NULL     | Lottery result |
| LOTING_REDEN_VOORBEHOUD       | nvarchar(1)    | NULL     | Reason for reservation in lottery |
| LOTING_IBG_STATUS             | nvarchar(255)  | NULL     | Status in lottery system |
| LOTING_REDEN_AFKEUR           | nvarchar(255)  | NULL     | Reason for rejection in lottery |
| DATUM_VERZOEK_STOPPEN         | datetime2(7)   | NULL     | Date of request to stop |
| GEWENSTE_EINDDATUM            | datetime2(7)   | NULL     | Desired end date |
| VERZOEK_STOPPEN_REDEN         | nvarchar(255)  | NULL     | Reason for stopping request |
| VERZOEK_STOPPEN_TOELICHTING   | nvarchar(1000) | NULL     | Explanation for stopping request |
| VERZOEK_RESTITUTIE            | nvarchar(255)  | NULL     | Request for restitution |
| VERZOEK_STOPPEN_GEHONOREERD   | nvarchar(255)  | NULL     | Honored stop request |
| RECHTSTREEKS_TOELAATBAAR      | nvarchar(255)  | NULL     | Directly admissible |
| INSTROOMMOMENT                | nvarchar(255)  | NULL     | Moment of entry |
| SINH_ID                       | decimal(18, 0) | NULL     | Unique SINH identifier |
| MUTATIE_APPLICATIE            | nvarchar(255)  | NULL     | Application of mutation |
| MUTATIE_DATUM                 | datetime2(7)   | NULL     | Date of mutation |
| MUTATIE_GEBRUIKER             | nvarchar(255)  | NULL     | User of mutation |
| BEKOSTIGING                   | nvarchar(1)    | NULL     | Financing |
| HANDMATIG_NBSA                | nvarchar(255)  | NULL     | Manual NBSA status |
| BETAALVORM                    | nvarchar(255)  | NULL     | Payment form |
| SL_INSCHR_ID                  | nvarchar(255)  | NULL     | Enrollment ID |
| AANGEMELD_VOOR_DEADLINE       | nvarchar(255)  | NULL     | Registered before deadline |
| DATUM_EERSTE_INSCHR_VERZ_HO   | datetime2(7)   | NULL     | Date of first enrollment request |
| DEELNAME_STUDIEKEUZECHECK     | nvarchar(255)  | NULL     | Participation in study choice check |
| DATUM_STUDIEKEUZECHECK        | datetime2(7)   | NULL     | Date of study choice check |
| RESULT_STUDIEKEUZECHECK       | nvarchar(255)  | NULL     | Result of study choice check |
| TOELAATB_STUDIEKEUZECHECK     | nvarchar(255)  | NULL     | Admission study choice check |
| CREATIE_GEBRUIKER             | nvarchar(255)  | NULL     | Creator user |
| CREATIE_APPLICATIE            | nvarchar(255)  | NULL     | Creator application |
| CREATIE_DATUM                 | datetime2(7)   | NULL     | Creation date |
| OPMERKING                     | nvarchar(255)  | NULL     | Remarks |
| TOELAATBAAR_QUA_AMD           | nvarchar(255)  | NULL     | Admissible AMD |
| AANTAL_TE_BETALEN_ECTS_PM     | bigint         | NULL     | Number of ECTS to be paid per month |
| TOELATINGGEVENDE_VOOROPL      | nvarchar(255)  | NULL     | Admitting prior education |
| BRONHO_INSCHR_ID              | nvarchar(20)   | NULL     | Source higher education enrollment ID |
| VRIJST_COLLEGEGELD_BESTUURSF  | nvarchar(1)    | NULL     | Tuition fee exemption |
| DEELNAME_FLEXSTUDEREN         | nvarchar(10)   | NULL     | Participation in flexible studying |
| AANTAL_ECTS_FLEXSTUDEREN      | bigint         | NULL     | Number of ECTS for flexible studying |
| DATUM_BEWIJS_UITSCHRIJVING    | datetime2(7)   | NULL     | Date of proof of de-registration |
| GEBRUIKER_INTR_VOORAANMELDING | nvarchar(100)  | NULL     | User involved in pre-registration |
| INTENSIEF_PROGRAMMA           | nvarchar(1)    | NULL     | Intensive program |


**OSS_STUDENT_VOOROPLEIDING Table Schema**

This table contains the prior education details for students, which are crucial for initial assessments and educational pathway decisions.

| Column Name                  | Data Type          | Nullable | Description                             |
|------------------------------|--------------------|----------|-----------------------------------------|
| ODS_ID                       | int                | NOT NULL | Primary key identifier for the record.  |
| ODS_ID_HASH                  | binary(32)         | NULL     | Hash of ODS ID for security.            |
| ODS_COLUMNS_HASH             | binary(32)         | NULL     | Hash of all column data for integrity.  |
| ODS_START_DTS                | datetime           | NULL     | Start date and time of the record.      |
| ODS_EIND_DTS                 | datetime           | NULL     | End date and time of the record.        |
| ODS_ACTUEEL_IND              | int                | NULL     | Indicator if the record is current.     |
| META_LAAD_DTS                | datetime           | NULL     | Metadata load datetime.                 |
| META_LEVEL1_RUN_ID           | nvarchar(max)      | NULL     | Run ID for the metadata level 1.        |
| SVOO_ID                      | int                | NULL     | Student's prior education ID.           |
| STUDENTNUMMER                | nvarchar(max)      | NULL     | Student number.                         |
| VOOROPLEIDING                | nvarchar(max)      | NULL     | Description of prior education.         |
| SCHOOL_NAAM                  | nvarchar(max)      | NULL     | Name of the school.                     |
| SCHOOL_STRAATNAAM            | nvarchar(max)      | NULL     | School street name.                     |
| SCHOOL_NUMMER                | int                | NULL     | School number.                          |
| SCHOOL_TOEVOEGING_NUMMER     | nvarchar(max)      | NULL     | School number addition.                 |
| SCHOOL_POSTCODE              | nvarchar(max)      | NULL     | School postal code.                     |
| SCHOOL_PLAATS                | nvarchar(max)      | NULL     | School location.                        |
| SCHOOL_LAND                  | nvarchar(max)      | NULL     | Country of the school.                  |
| EINDEXAMENDATUM              | date               | NULL     | Date of final examination.              |
| SCHOOL                       | nvarchar(max)      | NULL     | School description.                     |
| DIPLOMA_BEHAALD              | nvarchar(max)      | NULL     | Indicates if the diploma was obtained.  |
| EXTENSIE_CODE                | nvarchar(max)      | NULL     | Extension code.                         |
| EXTENSIE_NAAM                | nvarchar(max)      | NULL     | Extension name.                         |
| EXTENSIE_LAND                | nvarchar(max)      | NULL     | Extension country.                      |
| STATUS_VERIFICATIE           | nvarchar(max)      | NULL     | Status of verification.                 |
| INSTELLING_VERIFICATIE       | nvarchar(max)      | NULL     | Verification institution.               |
| NAAM_INSTELLING_VERIFIC      | nvarchar(max)      | NULL     | Name of the verifying institution.      |
| DATUM_VERIFICATIE            | date               | NULL     | Date of verification.                   |
| GEBRUIKER_VERIFICATIE        | nvarchar(max)      | NULL     | User responsible for verification.      |
| INSTELLING                   | nvarchar(max)      | NULL     | Institution name.                       |
| EERSTE_VOOROPLEIDING         | nvarchar(max)      | NULL     | First prior education description.      |
| LAATSTE_MUTATIE_SL_DATUM     | date               | NULL     | Date of last modification.              |
| LAATSTE_MUTATIE_SL_DOOR      | nvarchar(max)      | NULL     | Last modified by.                       |
| CREATIE_GEBRUIKER            | nvarchar(max)      | NULL     | User who created the record.            |
| CREATIE_APPLICATIE           | nvarchar(max)      | NULL     | Application used to create the record.  |
| CREATIE_DATUM                | datetime2(7)       | NULL     | Date the record was created.            |
| MUTATIE_GEBRUIKER            | nvarchar(max)      | NULL     | User who last modified the record.      |
| MUTATIE_APPLICATIE           | nvarchar(max)      | NULL     | Application used for the last change.   |
| MUTATIE_DATUM                | datetime2(7)       | NULL     | Date of the last modification.          |


**OSS_STUDENT_EXAMEN Table Schema**

This table contains records related to the examinations and academic assessments of students, including scheduled exams, outcomes, and related administrative actions.

| Column Name                   | Data Type          | Nullable | Description                                               |
|-------------------------------|--------------------|----------|-----------------------------------------------------------|
| ODS_ID                        | int                | NOT NULL | Primary key identifier for the record.                    |
| ODS_ID_HASH                   | binary(32)         | NULL     | Hash of ODS ID for security purposes.                     |
| ODS_COLUMNS_HASH              | binary(32)         | NULL     | Hash of all column data for integrity checks.             |
| ODS_START_DTS                 | datetime           | NULL     | Start date and time of the record.                        |
| ODS_EIND_DTS                  | datetime           | NULL     | End date and time of the record.                          |
| ODS_ACTUEEL_IND               | int                | NULL     | Indicator if the record is current.                       |
| META_LAAD_DTS                 | datetime           | NULL     | Metadata load datetime.                                   |
| META_LEVEL1_RUN_ID            | nvarchar(max)      | NULL     | Run ID for the metadata level 1 process.                  |
| SEXA_ID                       | bigint             | NULL     | Examination instance identifier.                          |
| STUDENTNUMMER                 | nvarchar(max)      | NULL     | Student number.                                           |
| OPLEIDING                     | nvarchar(max)      | NULL     | Name of the program associated with the exam.             |
| EXAMENTYPE                    | nvarchar(max)      | NULL     | Type of exam administered.                                |
| AANVANGSDATUM                 | date               | NULL     | Date when the exam starts.                                |
| EXAMENPROGRAMMA               | nvarchar(max)      | NULL     | Program details of the exam.                              |
| UITSTEL_DIPLOMA_TOT           | date               | NULL     | Extended deadline for diploma issuance.                   |
| VOORGESTELDE_EXAMENDATUM      | date               | NULL     | Proposed date for the exam.                               |
| VOORGESTELDE_JUDICIUM         | nvarchar(max)      | NULL     | Proposed judgment or decision for the exam results.       |
| EXAMENDATUM                   | date               | NULL     | Actual date the exam was conducted.                       |
| JUDICIUM                      | nvarchar(max)      | NULL     | Final judgment or result of the exam.                     |
| EERSTE_GRAAD                  | nvarchar(max)      | NULL     | First-degree classification if applicable.                 |
| AANMELDDATUM                  | date               | NULL     | Date of registration for the exam.                        |
| EXAMEN_GEWIJZIGD_OP           | date               | NULL     | Date when the exam details were last modified.            |
| EXAMEN_GEWIJZIGD_DOOR         | nvarchar(max)      | NULL     | User who last modified the exam details.                  |
| AANMELDDATUM_IBG              | date               | NULL     | Date of registration with IB-Groep.                       |
| VERZONDEN_NAAR_DUO            | nvarchar(max)      | NULL     | Indicates if the exam details were sent to DUO.           |
| STUVO_BEVROREN                | nvarchar(max)      | NULL     | Indicates if the student's status is frozen.              |
| GEBRUIKER_STUVO_ONTDOOIEN     | nvarchar(max)      | NULL     | User who can unfreeze the student's status.               |
| DATUM_STUVO_ONTDOOIEN         | date               | NULL     | Date when the student's status was unfrozen.              |
| GELDIGHEIDSDUUR_STUDIEDUUR    | date               | NULL     | Validity period for the course of study.                  |
| TOELICHTING                   | nvarchar(max)      | NULL     | Additional explanations or notes related to the exam.     |
| DEELNAME_HONOURS              | nvarchar(max)      | NULL     | Indicates participation in an honours program.            |
| STARTDATUM_HONOURS            | date               | NULL     | Start date of the honours program.                        |
| STAKINGSDATUM_HONOURS         | date               | NULL     | Date when participation in the honours program was halted.|
| BEEINDIGINGSREDEN_HONOURS     | nvarchar(max)      | NULL     | Reason for ending participation in the honours program.   |
| BRONMBO_RES_ID                | int                | NULL     | Resource ID from MBO background.                          |
| BRONVAVO_RES_ID               | int                | NULL     | Resource ID from VAVO background.                         |
| EXCM_ID                       | bigint             | NULL     | Exam metadata identifier.                                 |
| BRONHO_RES_ID                 | nvarchar(max)      | NULL     | Resource ID from higher education background.             |
| CREATIE_DATUM                 | datetime2(7)       | NULL     | Date when the record was created.                         |
| MUTATIE_DATUM                 | datetime2(7)       | NULL     | Date when the record was last modified.                   |
| MUTATIE_GEBRUIKER             | nvarchar(max)      | NULL     | User who last modified the record.                        |
| CREATIE_GEBRUIKER             | nvarchar(max)      | NULL     | User who created the record.                              |
| CREATIE_APPLICATIE            | nvarchar(max)      | NULL     | Application used to create the record.                    |
| MUTATIE_APPLICATIE            | nvarchar(max)      | NULL     | Application used to last modify the record.               |

**OSS_STUDENT Table Schema**

This table contains the primary student data, tracking both personal and academic information critical for administrative and educational use at Hogeschool Utrecht.

| Column Name             | Data Type      | Nullable | Description                                     |
|-------------------------|----------------|----------|-------------------------------------------------|
| ODS_ID                  | int            | NOT NULL | Primary key identifier for the student record.  |
| ODS_ID_HASH             | binary(32)     | NULL     | Hash of ODS ID to ensure data integrity.        |
| ODS_COLUMNS_HASH        | binary(32)     | NULL     | Hash of all column data for integrity checks.   |
| ODS_START_DTS           | datetime       | NULL     | Start date and time of the record.              |
| ODS_EIND_DTS            | datetime       | NULL     | End date and time of the record.                |
| ODS_ACTUEEL_IND         | int            | NULL     | Indicator if the record is current.             |
| META_LAAD_DTS           | datetime       | NULL     | Metadata load datetime.                         |
| META_LEVEL1_RUN_ID      | nvarchar(max)  | NULL     | Run ID for the metadata level 1 process.        |
| STUD_ID                 | bigint         | NULL     | Unique student identifier.                      |
| STUDENTNUMMER           | nvarchar(255)  | NULL     | Student number as used internally.              |
| ACHTERNAAM              | nvarchar(255)  | NULL     | Student's surname.                              |
| VOORVOEGSELS            | nvarchar(255)  | NULL     | Prefixes in student's name, if any.             |
| VOORLETTERS             | nvarchar(255)  | NULL     | Initials of the student.                        |
| VOORNAMEN               | nvarchar(255)  | NULL     | Full first names of the student.                |
| ROEPNAAM               | nvarchar(255)  | NULL     | Nickname or commonly used name.                 |
| GEBOORTEDATUM           | date           | NULL     | Date of birth of the student.                   |
| GESLACHT                | nvarchar(255)  | NULL     | Gender of the student.                          |
| NATIONALITEIT           | nvarchar(255)  | NULL     | Nationality of the student.                     |
| AANVANGSJAAR_UU_STUDENT | int            | NULL     | The year the student started at the university. |
| E_MAIL_ADRES            | nvarchar(255)  | NULL     | Student's email address.                        |
| OVERLIJDENSDATUM        | date           | NULL     | Date of death, if applicable.                   |
| STUDIELINK_EMAIL_ADRES  | nvarchar(255)  | NULL     | Email address registered in Studielink.         |
| STUDIELINKNUMMER        | int            | NULL     | Studielink number associated with the student.  |

## Data from studielink 

## ANM_TELBESTAND_SL Table Schema

This table is from studielink. It does not provide very specific data from students. 

| Column Name   | Data Type          | Nullable | Description                                              |
|---------------|--------------------|----------|----------------------------------------------------------|
| ODS_ID        | int                | NOT NULL | Primary key identifier for the record.                   |
| ODS_ID_HASH   | binary(32)         | NULL     | Hash of ODS ID to ensure data integrity and privacy.     |
| ODS_COLUMNS_HASH | binary(32)      | NULL     | Hash of all column data for integrity checks.            |
| ODS_START_DTS | datetime           | NULL     | Start date and time of the data record.                  |
| ODS_EIND_DTS  | datetime           | NULL     | End date and time of the data record.                    |
| ODS_ACTUEEL_IND | int              | NULL     | Indicator if the record is current.                      |
| META_LAAD_DTS | datetime           | NULL     | Metadata load datetime.                                  |
| META_LEVEL1_RUN_ID | nvarchar(max) | NULL     | Run ID for the metadata level 1 process.                 |
| HBO_WO        | nvarchar(10)       | NULL     | Indicator of whether the education level is HBO or WO.   |
| BRINCODE      | nvarchar(10)       | NULL     | Institution code under the Dutch education system.       |
| BRIN_VOLGNR   | int                | NULL     | Sequence number for the BRIN code.                       |
| ISATCODE      | int                | NULL     | International SAT code associated with the student.      |
| TYPE_HO       | nvarchar(10)       | NULL     | Type of higher education institution.                    |
| OPL_VORM      | int                | NULL     | Form of the study program.                               |
| STUDIEJAAR    | int                | NULL     | Academic year of study.                                  |
| FIXUS         | nvarchar(10)       | NULL     | Status indicator for fixed university seat allocations.  |
| MAAND         | int                | NULL     | Month of the data entry.                                 |
| HERKOMST      | nvarchar(10)       | NULL     | Origin of the student (national/international).          |
| GESLACHT      | nvarchar(10)       | NULL     | Gender of the student.                                   |
| MEERCODE_V    | int                | NULL     | Additional code for verification purposes.               |
| MEERCODE_A    | int                | NULL     | Additional administrative code.                          |
| STATUS        | nvarchar(10)       | NULL     | Current status of the student in the system.             |
| HOGEREJAARS   | nvarchar(10)       | NULL     | Indicator if the student is an upperclassman.            |
| HERINSCHRIJVING | nvarchar(10)    | NULL     | Indicator of re-enrollment status.                       |
| 1CHO_L        | int                | NULL     | Code for primary choice of study location.               |
| 1CHO_K        | int                | NULL     | Code for primary choice of study field.                  |
| AANTAL        | int                | NULL     | Count of records or occurrences.                         |
| FILENAME      | nvarchar(max)      | NULL     | Name of the file where data was sourced.                 |
| PEILDATUM     | datetime2(7)       | NULL     | Reference date for the data provided.                    |
| VERSIE        | int                | NULL     | Version number of the data entry.                        |

## what is a student dropout?

1. **Definition of Dropout**: There are multiple definitions of dropouts depending on different institutions:
   - **Leaving a specific program**: A student leaves a particular course or program but might continue their education elsewhere or in another program.
   - **Switching within the same institution**: A student changes their study track within the same institution.
   - **Stopping studies altogether**: A student leaves their studies without enrolling in any other program or institution.

2. **Variations in Dropout Definitions**:
   - **Staying within the same field but at a different institution**: Not considered a dropout by some institutions.
   - **Shared first-year programs**: Some students might enroll in two study tracks simultaneously and decide on one after the first year, which might be wrongly registered as a dropout.

3. **Challenges in Data Registration**: The conversation highlights the difficulty in accurately capturing and labeling dropout data due to varying definitions and shared programs.

4. **Proposed Categories**:
   - **Dropout**: Students who leave their initial program and do not continue within the same institution or in the same field elsewhere.
   - **Non-dropout**: Students who continue their studies in the same program or institution.
   - **Transitioned**: Students who switch their study track within the same institution or move to another institution but in the same field.

5. **Special Cases**:
   - **Stepping Stone**: Students using their current program as a stepping stone to transfer to a university from a University of Applied Sciences. This category needs to be labeled separately to avoid confusion with dropouts.

6. **Data Management**:
   - Data access and labeling are crucial. There is a need for specific query-based data extraction due to strict data access policies.
   - The conversation suggests a need for defining the project scope and aligning it with existing academic references and definitions.

7. **Additional Considerations**:
   - Research on how other institutions define and handle dropout data.
   - Collaboration with experts and potentially involving external resources for better understanding and implementation.

8. **Administrative Note**: The conversation ends with a reminder about the need to establish a project code for tracking working hours.

## Data Preparation
## Modeling
## Evaluation
## Deployment


