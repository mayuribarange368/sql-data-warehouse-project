PRINT'================================================================'
PRINT'---------Check Raw data of bronze.crm_sales_details-------------'
PRINT'================================================================'

--Check sls_ord_num
--Expected output: No value
SELECT 
  sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--Check can we connect sls_prd_key & sls_cust_id with customer and product table

SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info )

SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info )

--Check sls_order_dt ,sls_ship_dt, sls_due_dt
--Expected Result :Cleaned data
--check Part1 for order date
SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt >20500101 
OR sls_order_dt <=19990101

--Final query for order date
SELECT
CASE 
    WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt
FROM bronze.crm_sales_details

 
--Check part 1 for ship date
SELECT 
 sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt<=0 OR LEN(sls_ship_dt) !=8

--Final query for ship date
SELECT
CASE 
    WHEN sls_ship_dt =0 OR LEN(sls_ship_dt) !=8 THEN NULL
    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt
FROM bronze.crm_sales_details

--Check part 1 for duendate
SELECT 
 sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt<=0 OR LEN(sls_due_dt)!=8

--Final query for due date
SELECT
CASE 
    WHEN sls_due_dt =0 OR LEN(sls_due_dt) !=8 THEN NULL
    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt
FROM bronze.crm_sales_details

--Order date must always be earlier than the shipping date or due date
--Result : No date
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check sls_sales , sls_quantity & sls_price 
SELECT Distinct
sls_sales,
sls_quantity, 
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
      OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
      OR sls_sales<= 0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity, sls_price 

-- Rules
-- is sales is -ve,0 or null, derive it using quantity & products
--Price is 0 or null, Calulate is from sales and quantity
--price is -ve make it +ve

SELECT Distinct
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE 
    WHEN sls_sales IS NULL OR sls_sales<=0  OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
CASE 
    WHEN sls_price IS NULL OR sls_price <=0
    THEN sls_sales / NULLIF(sls_quantity ,0)
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details

PRINT'-------------------------END Check--------------------------------'

----------------------------Final cleaned data query---------------------

SELECT 
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      CASE 
            WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
      END AS sls_order_dt,
      CASE 
            WHEN sls_ship_dt =0 OR LEN(sls_ship_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
      END AS sls_ship_dt,
      CASE 
            WHEN sls_due_dt =0 OR LEN(sls_due_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
      END AS sls_due_dt,
      sls_sales AS old_sls_sales,
      sls_quantity,
      sls_price AS old_sls_price,
      CASE 
            WHEN sls_sales IS NULL OR sls_sales<=0  OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
      END AS sls_sales,
      CASE 
            WHEN sls_price IS NULL OR sls_price <=0
            THEN sls_sales / NULLIF(sls_quantity ,0)
            ELSE sls_price
      END AS sls_price
FROM bronze.crm_sales_details
------------------------------------------------------------------------------------------------------------------
PRINT '====================================================='
PRINT 'INSERTING CLEADN DATA INTO silver.crm_sales_deatils TABLE'
PRINT '====================================================='

-----Additional column with correct data type updated to the table

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details(
  sls_ord_num NVARCHAR(50),
  sls_prd_key NVARCHAR(50),
  sls_cust_id INT,
  sls_order_dt DATE,
  sls_ship_dt DATE,
  sls_due_dt DATE,
  sls_sales INT,
  sls_quantity INT,
  sls_price INT,
  dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-----Insert data into Silver.crm_sales_details------------------

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details(
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
)

SELECT 
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      CASE 
            WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
      END AS sls_order_dt,
      CASE 
            WHEN sls_ship_dt =0 OR LEN(sls_ship_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
      END AS sls_ship_dt,
      CASE 
            WHEN sls_due_dt =0 OR LEN(sls_due_dt) !=8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
      END AS sls_due_dt,
      CASE 
            WHEN sls_sales IS NULL OR sls_sales<=0  OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
      END AS sls_sales,
      sls_quantity,
      CASE 
            WHEN sls_price IS NULL OR sls_price <=0
            THEN sls_sales / NULLIF(sls_quantity ,0)
            ELSE sls_price
      END AS sls_price
  FROM bronze.crm_sales_details


PRINT '====================================================='
PRINT 'CLEADN DATA INSERTED INTO silver.crm_cust_info TABLE'
PRINT '====================================================='






