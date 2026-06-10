PRINT'================================================================'
PRINT'-----------Check Raw data of bronze.erp_LOC_A101---------------'
PRINT'================================================================'

--Check CID data
SELECT 
REPLACE(CID,'-', '')CID,
CNTRY
FROM bronze.erp_LOC_A101
WHERE REPLACE(CID,'-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

---Check CNTRY data
SELECT DISTINCT
CNTRY,
CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
     WHEN CNTRY ='' OR CNTRY IS NULL THEN 'n/a'
     ELSE CNTRY
END CNTRY
FROM bronze.erp_LOC_A101

------------Final query------------------

SELECT 
REPLACE(CID,'-', '')CID,
CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
     WHEN CNTRY ='' OR CNTRY IS NULL THEN 'n/a'
     ELSE CNTRY
END CNTRY
FROM bronze.erp_LOC_A101;

PRINT'-------------------------END Check--------------------------------'
