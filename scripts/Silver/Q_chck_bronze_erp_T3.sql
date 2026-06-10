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

PRINT'-------------------------END Check--------------------------------'
-------------------------------------------------------------------------------------------------------------
PRINT '====================================================='
PRINT 'INSERTING CLEADN DATA INTO silver.erp_LOC_A101 TABLE'
PRINT '====================================================='

-----Additional column with correct data type updated to the table

IF OBJECT_ID ('silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
   DROP TABLE silver.erp_PX_CAT_G1V2;

CREATE TABLE silver.erp_PX_CAT_G1V2(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-----Insert data into Silver.crm_sales_details------------------
TRUNCATE TABLE silver.erp_PX_CAT_G1V2;

 INSERT INTO silver.erp_PX_CAT_G1V2(
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
)

SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_PX_CAT_G1V2

PRINT '====================================================='
PRINT 'CLEADN DATA INSERTED INTO silver.erp_CUST_AZ12  TABLE'
PRINT '====================================================='
