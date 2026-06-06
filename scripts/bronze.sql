/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

-- Create table for source crm
--Cust_info table
CREATE TABLE bronze.crm_cust_info(
  cst_id INT,
  cst_key NVARCHAR(50),
  cst_firstname NVARCHAR(50),
  cst_lastname NVARCHAR(50),
  cst_marital_status NVARCHAR(50),
  cst_gndr NVARCHAR(50),
  cst_create_date DATE
);
GO
  
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

--Prd_info table
CREATE TABLE bronze.crm_prd_info(
  prd_id INT,
  prd_key NVARCHAR(50),
  prd_nm NVARCHAR(50),
  prd_cost INT,
  prd_line NVARCHAR(50),
  prd_start_dt DATE,
  prd_end_dt DATE
);
GO


IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

--Sales_details table
CREATE TABLE bronze.crm_sales_details(
  sls_ord_num NVARCHAR(50),
  sls_prd_key NVARCHAR(50),
  sls_cust_id INT,
  sls_order_dt INT,
  sls_ship_dt INT,
  sls_due_dt INT,
  sls_sales INT,
  sls_quantity INT,
  sls_price INT
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

--Create table for source erp
--erp_CUST_AZ12 table
CREATE TABLE bronze.erp_CUST_AZ12(
 CID NVARCHAR(50),
 BDATE DATE,
 GEN NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

--erp_LOC_A101 table
CREATE TABLE bronze.erp_LOC_A101(
  CID NVARCHAR(50),
  CNTRY NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

--erp_PX_CAT_G1V2 table
CREATE TABLE bronze.erp_PX_CAT_G1V2(
  ID NVARCHAR(50),
  CAT NVARCHAR(50),
  SUBCAT NVARCHAR(50),
  MAINTENANCE NVARCHAR(50)
);
GO
/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script inserts raw data into all the tables in bronze, truncatind existing data in tables 
    if they already exist.
	  Run this script to insert bul data to 'bronze' Tables
===============================================================================
*/
  
--Inserting bulk data in cust_info table
  
TRUNCATE TABLE bronze.crm_cust_info; 

BULK INSERT bronze.crm_cust_info
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH (
      FIRSTROW =2,
      FIELDTERMINATOR =',',
      TABLOCK
      );

---Checking bulk data in cust_info table
SELECT * FROM bronze.crm_cust_info;
SELECT COUNT(*) FROM bronze.crm_cust_info;

--Inserting bulk data in prd_info table

TRUNCATE TABLE bronze.crm_prd_info; 

BULK INSERT bronze.crm_prd_info
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH (
      FIRSTROW =2,
      FIELDTERMINATOR =',',
      TABLOCK
      );

--Checking bulk data in prd_info table
 SELECT * FROM bronze.crm_prd_info;
 SELECT COUNT(*) FROM bronze.crm_prd_info;

--Inserting bulk data in sales_details table
TRUNCATE TABLE bronze.crm_sale_details; 

BULK INSERT bronze.crm_sales_details
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH (
      FIRSTROW =2,
      FIELDTERMINATOR =',',
      TABLOCK
      );

--Checking bulk data in sales_details table
SELECT * FROM bronze.crm_sales_details;
SELECT  COUNT(*) FROM bronze.crm_sales_details;

--Inserting bulk data in erp table

------ Inserting bulk data in  bronze.erp_CUST_AZ12 table
TRUNCATE TABLE bronze.erp_CUST_AZ12;

BULK INSERT bronze.erp_CUST_AZ12
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH (
      FIRSTROW= 2,
      FIELDTERMINATOR =',',
      TABLOCK
      );

--Checking bulk data in bronze.erp_CUST_AZ12 table
SELECT * FROM bronze.erp_CUST_AZ12;
SELECT COUNT(*)FROM bronze.erp_CUST_AZ12;

-- Inserting bulk data in bronze.erp_LOC_A101 table

TRUNCATE TABLE bronze.erp_LOC_A101;

BULK INSERT bronze.erp_LOC_A101
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH(
     FIRSTROW =2,
     FIELDTERMINATOR =',',
     TABLOCK
     );

-- Checking bulk data in bronze.erp_LOC_A101 table
SELECT * FROM bronze.erp_LOC_A101;
SELECT COUNT(*)FROM bronze.erp_LOC_A101;

---- Inserting bulk data in bronze.erp_PX_CAT_G1V2 table

TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

BULK INSERT bronze.erp_PX_CAT_G1V2 
FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
      FIRSTROW =2,
      FIELDTERMINATOR =',',
      TABLOCK
      );

-- Checking bulk data in bronze.erp_PX_CAT_G1V2 table
SELECT * FROM bronze.erp_PX_CAT_G1V2;
SELECT COUNT(*)FROM bronze.erp_PX_CAT_G1V2;

     
