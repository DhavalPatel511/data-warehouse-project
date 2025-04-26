----- Analyze sales performance over time

SELECT 
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

SELECT 
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

SELECT 
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-------Calculate the total sales per month and running total of sales over time
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY DATETRUNC(month, order_date)) as cumulative_total_sales
FROM
(SELECT 
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t;


SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_date ORDER BY DATETRUNC(month, order_date)) as cumulative_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) as moving_avg_price
FROM
(SELECT 
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t;

----- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales

WITH yearly_product_sales AS  (
SELECT
	YEAR(order_date) as order_year,
	p.product_name,
	SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(order_date),p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 Else 'Avg'
	END AS avg_flag,
	LAG(current_sales,1,current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_sales,
	current_sales - LAG(current_sales,1,current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_sales,
	CASE WHEN current_sales - LAG(current_sales,1,current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales,1,current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 Else 'No Change'
	END AS sales_flag
FROM yearly_product_sales;



------------ Which category contribute most to the overall sales

WITH category_sales AS (
SELECT
	category,
	SUM(sales_amount) total_sales
FROM gold.fact_sales s LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY category)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) *100,2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

----------Segment products into cost ranges and count how many products fall into each segment

WITH product_segemnts AS (
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END AS cost_range
FROM gold.dim_products)

SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segemnts
GROUP BY cost_range
ORDER BY total_products DESC;



------- Group customers into 3 segemnts based on spending behavior
-- VIP > at least 12 months of history and spending more than 5000
-- Regular > al least 12 months of history but spending 5000 or less
-- New > Customers with lifespan less than 12 months
----- Find the total number of customers by each group.

WITH customer_spending AS (
SELECT 
	c.customer_key,
	SUM(s.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan_months
FROM gold.fact_sales s LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key)


SELECT customer_segment,COUNT(customer_key) AS total_customers FROM
(SELECT
	customer_key,
	CASE WHEN total_spending > 5000 AND lifespan_months >= 12 THEN 'VIP'
		 WHEN total_spending <= 5000 AND lifespan_months >= 12 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment
FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers;


