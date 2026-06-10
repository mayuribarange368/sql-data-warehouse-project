PRINT'================================================================'
PRINT'-----------Check Raw data of bronze.erp_LOC_A101---------------'
PRINT'================================================================'

--Checking unwanted spaces
SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2
WHERE CAT !=TRIM(CAT) OR SUBCAT !=TRIM(SUBCAT) OR MAINTENANCE!= TRIM(MAINTENANCE)

--Checking standarization and consistency
SELECT DISTINCT
MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2

------------Final query------------------
SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2
WHERE CAT !=TRIM(CAT) OR SUBCAT !=TRIM(SUBCAT) OR MAINTENANCE!= TRIM(MAINTENANCE)

PRINT'-------------------------END Check--------------------------------'
-------------------------------------------------------------------------------------------------------------
