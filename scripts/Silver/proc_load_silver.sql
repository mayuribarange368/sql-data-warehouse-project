/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs ETL (Extract, Transform, Load) process to 
    populate the 'silver'schema tables from the 'bronze' schema.
    It performs the following actions:
    - Truncates the silver tables.
    - Inserts transformed and cleaned data from bronze into silver tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME ,@end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
    SET @batch_start_time= GETDATE();
    PRINT '====================================================='
    PRINT 'Loading Silver Layer'
    PRINT '====================================================='

    PRINT '====================================================='
    PRINT 'Loading CRM Tables'
    PRINT '====================================================='

    --Loading silver.crm_cust_info
    SET @start_time =GETDATE();
    PRINT'>>> Truncating Table :silver.crm_cust_info';
    TRUNCATE table silver.crm_cust_info;
    PRINT'>>> Inserting Data into Table :silver.crm_cust_info';
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
    WHERE flag_last =1; --Select the most recent record per customer
    SET @end_time =GETDATE();
    PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
    PRINT'>>> ----------------'
    
    --Loading silver.crm_prd_info
    SET @start_time =GETDATE();
    PRINT'>>> Truncating Table :silver.crm_prd_info';
    TRUNCATE table silver.crm_prd_info;
    PRINT'>>> Inserting Data into Table :silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info(
      prd_id,        
      cat_id,        
      prd_key,
      prd_nm,        
      prd_cost, 
      prd_line,
      prd_start_dt,    
      prd_end_dt  
    )
    
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS cat_id,  ---Extract category ID
        SUBSTRING(prd_key, 7,LEN(prd_key)) AS prd_key,       ---Extract product key
        prd_nm,
        ISNULL (prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
           WHEN 'M' THEN 'Mountain'
           WHEN 'R' THEN 'Road'
           WHEN 'S' THEN 'Other Sales'
           WHEN 'T' THEN 'Touring'
           ELSE 'n/a'
        END AS prd_line,  ---Map product lines codes to descriptive values
        prd_start_dt,
        DATEADD (
             DAY, 
             -1, 
             LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
         ) AS prd_end_date ---Calulate end date as one day before the next start date
    FROM bronze.crm_prd_info
    SET @end_time =GETDATE();
    PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
    PRINT'>>>----------------'

    --Loading silver.crm_sales_details
    SET @start_time =GETDATE();
    PRINT'>>> Truncating Table :silver.crm_sales_details';
    TRUNCATE table silver.crm_sales_details;
    PRINT'>>> Inserting Data into Table :silver.crm_sales_details';
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
          END AS sls_sales, ---Recalculate sales if orignal value is missing or incorrect
          sls_quantity,
          CASE 
                WHEN sls_price IS NULL OR sls_price <=0
                THEN sls_sales / NULLIF(sls_quantity ,0)
                ELSE sls_price ---Derive price if original value is invalid
          END AS sls_price
      FROM bronze.crm_sales_details;
      SET @end_time =GETDATE();
      PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
      PRINT'>>>----------------'

      PRINT '====================================================='
      PRINT 'Loading ERP Tables'
      PRINT '====================================================='

      --Loading silver.erp_CUST_AZ12
      SET @start_time =GETDATE();
      PRINT'>>> Truncating Table :silver.erp_CUST_AZ12';
      TRUNCATE table silver.erp_CUST_AZ12;
      PRINT'>>> Inserting Data into Table :silver.erp_CUST_AZ12';
      INSERT INTO silver.erp_CUST_AZ12(
          CID,
          BDATE,
          GEN
      )
            
      SELECT 
          CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID ,4,LEN(CID))  --Removes 'NAS' prefix if present
               ELSE CID
          END AS CID,
          CASE 
              WHEN BDATE> GETDATE() THEN NULL
              ELSE BDATE
          END AS BDATE,  ---set future birthdates to NULL
          CASE 
              WHEN UPPER(TRIM(GEN)) IN ('F','Female') THEN 'Female'
              WHEN UPPER(TRIM(GEN)) IN ('M','Male') THEN 'Male'
              ELSE 'n/a'
          END AS GEN  ---- Normalize gender values and handle unknown cases
      FROM bronze.erp_CUST_AZ12;
      SET @end_time =GETDATE();
      PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
      PRINT'>>>----------------'

      --Loading silver.erp_LOC_A101
      SET @start_time =GETDATE();
      PRINT'>>> Truncating Table :silver.erp_LOC_A101';
      TRUNCATE table silver.erp_LOC_A101;
      PRINT'>>> Inserting Data into Table:silver.erp_LOC_A101';
      INSERT INTO silver.erp_LOC_A101(
           CID,
           CNTRY
      )
             
      SELECT 
           REPLACE(CID,'-', '')CID,
           CASE WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN CNTRY ='' OR CNTRY IS NULL THEN 'n/a'
                ELSE CNTRY --Normalize and handle missing or blank country codes
           END CNTRY
      FROM bronze.erp_LOC_A101;
      SET @end_time =GETDATE();
      PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
      PRINT'>>>----------------'

      --Loading silver.erp_PX_CAT_G1V2
      SET @start_time =GETDATE();
      PRINT'>>> Truncating Table :silver.erp_PX_CAT_G1V2';
      TRUNCATE table silver.erp_PX_CAT_G1V2;
      PRINT'>>> Inserting Data into Table:silver.erp_PX_CAT_G1V2';
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
      FROM bronze.erp_PX_CAT_G1V2;
      SET @end_time =GETDATE();
      PRINT'>>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time , @end_time) AS NVARCHAR) + 'Seconds';
      PRINT'>>>----------------'

      SET @batch_end_time =GETDATE();
      PRINT '====================================================='
      PRINT 'Loading Silver Layer is completed';
      PRINT ' -Total Duration:' + CAST(DATEDIFF(SECOND,@batch_start_time , @batch_end_time) AS NVARCHAR) +'seconds';
      PRINT '====================================================='
   END TRY
   BEGIN CATCH
   PRINT '====================================================='
   PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
   PRINT 'Error Message' + ERROR_MESSAGE();
   PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
   PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
   PRINT '====================================================='
   END CATCH

END
