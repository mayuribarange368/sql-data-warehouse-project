--Change -over-time Analysis
--Analyze Sales Preformance Over Time.
SELECT
Year(order_date) AS order_year,
Month(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY  Year(order_date),Month(order_date) 
ORDER BY Year(order_date),Month(order_date) 

--Using DATETRUNC 
--Analyze Sales Preformance Over Time.
SELECT
DATETRUNC(month,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date) 
ORDER BY DATETRUNC(month,order_date) 

--Cumulative Analysis
--Calculate the total sales per month
--and the running total of the sales over time

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY Year(order_date) ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(Month,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(Month,order_date)
)t

--Over year
--Moving average price
SELECT
order_date,
total_sales,
SUM(total_sales) OVER( ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(Year,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(Year,order_date)
)t

--Performance Analysis
/*Analyze the yearly performance of the products by comparing their sales to both
the average sales performance of the product and the previous year's sales*/

WITH Yearly_product_sales AS
(
	SELECT 
	Year(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key=f.product_key
	WHERE  f.order_date IS NOT NULL
	GROUP BY Year(f.order_date),
	p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales -AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales -AVG(current_sales) OVER (PARTITION BY product_name)>0 THEN 'Above Avg'
     WHEN current_sales -AVG(current_sales) OVER (PARTITION BY product_name)<0 THEN 'Below Avg'
END avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)>0 THEN 'Increase'
     WHEN current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)<0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM Yearly_product_sales
ORDER BY product_name,order_year
  
--Part-to-whole Analysis
--Which categories contribute to the most to overall sales?
WITH category_sales AS(
SELECT 
p.category,
SUM(f.sales_amount)AS Total_Sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
GROUP BY p.category
)
SELECT 
category,
Total_Sales,
SUM(Total_Sales) OVER() Overall_Sales,
CONCAT(ROUND((CAST(Total_Sales AS FLOAT)/SUM(Total_Sales) OVER())*100,2),'%') AS percentage_of_total
FROM category_sales
ORDER BY Total_Sales DESC
  
--Data Segmentation
/*Group customers into three segments based on their spending behavior:
-VIP: at least 12months of the history and spending more than 5000.
-Regular:at least 12 months of history but spending 5000 or less
-New:lifespan less than 12 months
And find total number of customers by each group
*/
WITH customer_spending AS
(
	SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS last_order,
	DATEDIFF(Month, MIN(f.order_date),MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c 
	ON c.customer_key=f.customer_key
	GROUP BY c.customer_key
)
SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM(
		SELECT
		customer_key,
		total_spending,
		lifespan,
		CASE WHEN lifespan >=12 AND total_spending>5000 THEN 'VIP'
			 WHEN lifespan >=12 AND total_spending<=5000 THEN 'Regular'
			 ELSE 'New'
		END customer_segment
		FROM customer_spending
     )t
GROUP BY customer_segment
ORDER BY total_customers DESC

