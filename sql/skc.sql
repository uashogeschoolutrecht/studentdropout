------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- SKC advies op basis van SKC tabel aangeleverd door Harald.
-- SKC per student nummer, collegejaar en opleiding. 
-- Query written by Bram Versteeg (Marketing & Student analytics)
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
SELECT 
      SINH_ID
      ,[SKC_DATUM]
      ,[SKC_RESULT]
      ,[ADVIES_DEF]
  FROM [Marketing].[202501_SKC] skc
 
  WHERE 1=1
  AND ODS_ACTUEEL_IND = 1
  AND skc.COLLEGEJAAR >= 2018 
  AND skc.COLLEGEJAAR <= 2024
  --AND INSCHRIJVING = 'JA'     # This values seems no longer to be filled in 2024, so disabled.
  AND VOLTIJD_DEELTIJD = 'V'
  ORDER BY SKC_DATUM DESC