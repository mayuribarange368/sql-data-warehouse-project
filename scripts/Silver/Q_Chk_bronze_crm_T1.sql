PRINT'================================================================'
PRINT'-----------Check Raw data of bronze.crm_cust_info---------------'
PRINT'================================================================'
    
-----Check raw data bronze.crm_cust_info
SELECT *
FROM bronze.crm_cust_info;

--Check Primary key(Any NULL or duplicates present)
--Expectation : No result
SELECT
cst_id,
COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
having COUNT(*) >1 OR cst_id IS NULL

--Correction Query
SELECT *
FROM
(SELECT 
*,
ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
)t 
WHERE flag_last =1;

SELECT COUNT(cst_id) FROM bronze.crm_cust_info;

--Check unwanted spaces in string value
--Expectation : No result
SELECT 
cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)
    
----------FINAL Clean data query for T1---------------------
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE
    WHEN UPPER(TRIM( cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM( cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END cst_marital_status,
CASE 
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM 
    (SELECT 
        *,
        ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date DESC ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
    )t 
WHERE flag_last =1;

PRINT'-------------------------END Check--------------------------------'
    
-----------------------------------------------------------------------------------------------------

PRINT '====================================================='
PRINT 'INSERTING CLEAN DATA INTO silver.crm_cust_info TABLE'
PRINT '====================================================='
-----Additional column with correct data type updated to the table
    
IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
    DROP TABLE(silver.crm_cust_info);

CREATE TABLE silver.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
    );

-----Insert data into silver.crm_cust_info------------------   

TRUNCATE table silver.crm_cust_info;

INSERT INTO silver.crm_cust_info ( 
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE
    WHEN UPPER(TRIM( cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM( cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END cst_marital_status,
CASE 
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM 
    (SELECT 
        *,
        ROW_NUMBER() OVER ( PARTITION BY cst_id ORDER BY cst_create_date DESC ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
    )t 
WHERE flag_last =1;

PRINT '====================================================='
PRINT 'CLEAN DATA INSERTED INTO silver.crm_cust_info TABLE'
PRINT '====================================================='
