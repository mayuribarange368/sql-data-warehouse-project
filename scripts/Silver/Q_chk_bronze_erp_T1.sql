PRINT'================================================================'
PRINT'-----------Check Raw data of bronze.erp_CUST_AZ12---------------'
PRINT'================================================================'

SELECT 
CID,
BDATE,
GEN
FROM bronze.erp_CUST_AZ12;

SELECT * FROM silver.crm_cust_info;

-- Check CID matching in sliver.crm_cust_info
SELECT 
CID,
CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID ,4,LEN(CID))
     ELSE CID
END AS CID
FROM bronze.erp_CUST_AZ12;

--Check BDATE
SELECT 
BDATE,
CASE 
    WHEN BDATE> GETDATE() THEN NULL
    ELSE BDATE
END AS BDATE
FROM bronze.erp_CUST_AZ12;

--Check gender
SELECT DISTINCT
GEN,
CASE 
    WHEN UPPER(TRIM(GEN)) IN ('F','Female') THEN 'Female'
    WHEN UPPER(TRIM(GEN)) IN ('M','Male') THEN 'Male'
    ELSE 'n/a'
END AS GEN
FROM bronze.erp_CUST_AZ12;
-------------------------Final query -----------------------------------
SELECT 
CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID ,4,LEN(CID))
     ELSE CID
END AS CID,
CASE 
    WHEN BDATE> GETDATE() THEN NULL
    ELSE BDATE
END AS BDATE,
CASE 
    WHEN UPPER(TRIM(GEN)) IN ('F','Female') THEN 'Female'
    WHEN UPPER(TRIM(GEN)) IN ('M','Male') THEN 'Male'
    ELSE 'n/a'
END AS GEN
FROM bronze.erp_CUST_AZ12;
PRINT'-------------------------END Check--------------------------------'

---------------------------------------------------------------------------------------------------------

PRINT '====================================================='
PRINT 'INSERTING CLEAN DATA INTO silver.erp_CUST_AZ12 TABLE'
PRINT '====================================================='

-----Additional column with correct data type updated to the table

IF OBJECT_ID ('silver.erp_CUST_AZ12', 'U') IS NOT NULL
   DROP TABLE silver.erp_CUST_AZ12;

CREATE TABLE silver.erp_CUST_AZ12(
CID NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-----Insert data into Silver.erp_CUST_AZ12 Table------------------
TRUNCATE TABLE silver.erp_CUST_AZ12;

 INSERT INTO silver.erp_CUST_AZ12(
   CID,
   BDATE,
   GEN
)

SELECT 
CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID ,4,LEN(CID))
     ELSE CID
END AS CID,
CASE 
    WHEN BDATE> GETDATE() THEN NULL
    ELSE BDATE
END AS BDATE,
CASE 
    WHEN UPPER(TRIM(GEN)) IN ('F','Female') THEN 'Female'
    WHEN UPPER(TRIM(GEN)) IN ('M','Male') THEN 'Male'
    ELSE 'n/a'
END AS GEN
FROM bronze.erp_CUST_AZ12;

PRINT '====================================================='
PRINT 'CLEAN DATA INSERTED INTO silver.erp_CUST_AZ12  TABLE'
PRINT '====================================================='
