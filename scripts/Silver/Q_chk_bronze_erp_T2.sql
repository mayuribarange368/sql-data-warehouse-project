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
     
--------------------------------------------------------------------------------------------------------
     
PRINT '====================================================='
PRINT 'INSERTING CLEAN DATA INTO silver.erp_LOC_A101 TABLE'
PRINT '====================================================='

-----Additional column with correct data type updated to the table

IF OBJECT_ID ('silver.erp_LOC_A101', 'U') IS NOT NULL
   DROP TABLE silver.erp_LOC_A101;

CREATE TABLE silver.erp_LOC_A101(
CID NVARCHAR(50),
CNTRY NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-----Insert data into Silver.crm_sales_details------------------
TRUNCATE TABLE silver.erp_LOC_A101;

 INSERT INTO silver.erp_LOC_A101(
   CID,
   CNTRY
)

SELECT 
REPLACE(CID,'-', '')CID,
CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
     WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
     WHEN CNTRY ='' OR CNTRY IS NULL THEN 'n/a'
     ELSE CNTRY
END CNTRY
FROM bronze.erp_LOC_A101;

PRINT '====================================================='
PRINT 'CLEAN DATA INSERTED INTO silver.erp_LOC_A101 TABLE'
PRINT '====================================================='
