/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;
    BEGIN TRY
            SET @batch_start_time = GETDATE();
            PRINT '==================================================='
            PRINT 'Loading Bronze Layer'
            PRINT '==================================================='
    
            PRINT '---------------------------------------------------'
            PRINT 'Loading CRM Tables'
            PRINT '---------------------------------------------------'
    
    
            --Truncating and Inserting bulk data in cust_info table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.crm_cust_info';
            TRUNCATE TABLE bronze.crm_cust_info; 
    
            PRINT'>>> Inserting Table: bronze.crm_cust_info';
            BULK INSERT bronze.crm_cust_info
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
            WITH (
                  FIRSTROW =2,
                  FIELDTERMINATOR =',',
                  TABLOCK
                  );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'

            ----Truncating and Inserting bulk data in prd_info table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.crm_prd_info';
            TRUNCATE TABLE bronze.crm_prd_info; 
    
            PRINT'>>> Inserting Table: bronze.crm_prd_info';
            BULK INSERT bronze.crm_prd_info
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
            WITH (
                  FIRSTROW =2,
                  FIELDTERMINATOR =',',
                  TABLOCK
                  );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'
    
            --Truncating and Inserting bulk data in sales_details table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.crm_sales_details';
            TRUNCATE TABLE bronze.crm_sales_details; 
    
            PRINT'>>> Inserting Table: bronze.crm_sales_details';
            BULK INSERT bronze.crm_sales_details
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
            WITH (
                  FIRSTROW =2,
                  FIELDTERMINATOR =',',
                  TABLOCK
                  );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'
    
            PRINT '---------------------------------------------------'
            PRINT 'Loading ERP Tables'
            PRINT '---------------------------------------------------'
    
            --Truncating and Inserting bulk data in erp_CUST_AZ12 table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.erp_CUST_AZ12';
            TRUNCATE TABLE bronze.erp_CUST_AZ12;
    
            PRINT'>>> Inserting Table: bronze.erp_CUST_AZ12';
            BULK INSERT bronze.erp_CUST_AZ12
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
            WITH (
                  FIRSTROW= 2,
                  FIELDTERMINATOR =',',
                  TABLOCK
                  );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'
    
            --Truncating and Inserting bulk data in bronze.erp_LOC_A101 table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.erp_LOC_A101';
            TRUNCATE TABLE bronze.erp_LOC_A101;
    
            PRINT'>>> Inserting Table: bronze.erp_LOC_A101';
            BULK INSERT bronze.erp_LOC_A101
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
            WITH(
                 FIRSTROW =2,
                 FIELDTERMINATOR =',',
                 TABLOCK
                 );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'
    
            --Truncating and Inserting bulk data in bronze.erp_PX_CAT_G1V2 table
            SET @start_time = GETDATE();
            PRINT'>>> Truncating Table: bronze.erp_PX_CAT_G1V2';
            TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
    
            PRINT'>>> Inserting Table: bronze.erp_PX_CAT_G1V2';
            BULK INSERT bronze.erp_PX_CAT_G1V2 
            FROM 'C:\Tutorial\DataWarehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
            WITH (
                  FIRSTROW =2,
                  FIELDTERMINATOR =',',
                  TABLOCK
                  );
            SET @end_time = GETDATE();
            PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
            PRINT'----------------------------------------------------'


             SET @batch_end_time = GETDATE();
             PRINT'==================================================='
             PRINT'Loading Bronze layer is completed'
             PRINT'>>> Load duration:' +CAST(DATEDIFF(Second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
             PRINT'==================================================='

    END TRY
         
          BEGIN CATCH 
            PRINT '==================================================='
            PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
            PRINT 'Error Message' + ERROR_MESSAGE();
            PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
            PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
            PRINT '==================================================='
          END CATCH

END

EXEC bronze.load_bronze
