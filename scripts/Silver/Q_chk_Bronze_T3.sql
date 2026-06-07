

SELECT 
sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

--Check dates
SELECT
sls_order_dt,
NULLIF (sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) !=8
OR sls_order_dt >20500101 
OR sls_order_dt <=19990101

SELECT
sls_order_dt,
CASE 
    WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
    ELSE CAST(CAST(sls_order_dt) AS VARCHAR) AS

FROM bronze.crm_sales_details

