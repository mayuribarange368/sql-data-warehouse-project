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
FROM bronze.erp_CUST_AZ12

PRINT'-------------------------END Check--------------------------------'
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
