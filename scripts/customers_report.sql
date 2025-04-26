------ Customer Report -------------
CREATE VIEW gold.report_customers AS 
WITH base_query AS (
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) as customr_name,
	DATEDIFF(YEAR,c.birthdate,GETDATE()) AS age
FROM gold.fact_sales s LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL ),

customer_agg AS (
SELECT 
	customer_key,
	customer_number,
	customr_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date, 
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan_months
FROM base_query
GROUP BY customer_key,customer_number,customr_name,age )

SELECT
	customer_key,
	customer_number,
	customr_name,
	age,
	CASE WHEN age < 20 THEN 'Under 20'
		 WHEN age Between 20 and 29 THEN '20-29'
		 WHEN age Between 30 and 39 THEN '30-39'
		 WHEN age Between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
	END AS age_group,
	CASE WHEN total_sales > 5000 AND lifespan_months >= 12 THEN 'VIP'
		 WHEN total_sales <= 5000 AND lifespan_months >= 12 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment,
	DATEDIFF(MONTH,last_order_date,GETDATE()) AS recency,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_value,
	CASE WHEN lifespan_months = 0 THEN total_sales
		 ELSE total_sales/lifespan_months
	END AS avg_monthly_spends
FROM customer_agg;
