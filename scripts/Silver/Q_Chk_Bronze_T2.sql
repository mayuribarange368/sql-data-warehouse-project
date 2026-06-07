-------------------Quality check for T2 ----------------------------------
---Check duplicate prd_id
SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1

SELECT DISTINCT ID FROM bronze.erp_PX_CAT_G1V2
---- To condition to check cat_id which is not present in bronze.erp_PX_CAT_G1V2 Table
WHERE REPLACE(SUBSTRING(prd_key,1,5), '-','_') NOT IN
(SELECT DISTINCT ID FROM bronze.erp_PX_CAT_G1V2)

--Check unwanted space in prd_nm
--Expectation :No Resuls

SELECT 
prd_nm
FROM bronze.crm_prd_info
Where prd_nm != TRIM(prd_nm)

--Check fo Nulls or Negative numbers
--Expectation :No Resuls
SELECT 
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL

--Check on prd_line
SELECT 
prd_line
FROM bronze.crm_prd_info
GROUP BY prd_line

--Check on Start and end dates
SELECT
prd_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt,
DATEADD (
    DAY, 
    -1, 
    LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
) AS prd_end_date_test
FROM bronze.crm_prd_info
WHERE prd_key IN ( 'AC-HE-HL-U509-R','AC-HE-HL-U509')

--------------------------END Check--------------------------------------------

-- ------------------Final clean data query for T2 ----------------------------
SELECT 
       prd_id,
       prd_key,
       REPLACE(SUBSTRING(prd_key,1,5), '-','_') AS Cat_id,
       SUBSTRING(prd_key, 7,LEN(prd_key)) AS prd_key,
       prd_nm,
       ISNULL (prd_cost,0) AS prd_cost,
       CASE UPPER(TRIM(prd_line))
          WHEN 'M' THEN 'Mountain'
          WHEN 'R' THEN 'Road'
          WHEN 'S' THEN 'Other Sales'
          WHEN 'T' THEN 'Touring'
          ELSE 'n/a'
       END AS prd_line,
       prd_start_dt,
       DATEADD (
            DAY, 
            -1, 
            LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
        ) AS prd_end_date
 FROM bronze.crm_prd_info

-------------------------------------------------------------------------------------------------------
