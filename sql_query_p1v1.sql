-- SQL Retail Sales Analysis: Project 1
CREATE DATABASE sql_project_p1;

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id	INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),	
				quantity	INT,
				price_per_unit FLOAT,	
				cogs FLOAT,	
				total_sale FLOAT
			);

-- Data Exploration
SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;

-- Looking for NULL values for all columns
SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id	IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	;

-- Data Cleaning
-- Removing the NULL records
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id	IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	;

-- Data Exploration
SELECT * FROM retail_sales;

-- How many sales we have?
SELECT COUNT(*) AS total_sale FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_customer FROM retail_sales;

-- How many unique categories we have?
SELECT COUNT(DISTINCT category) AS total_category FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

-- Data Analysis & Business Key Problems and Answers

-- My Analysis & Findings

-- Q1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * 
FROM retail_sales 
WHERE sale_date = '2022-11-05';

-- Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing' 
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantiy >= 4;

-- Q3. Write a SQL query to calculate the total sales (total_sale) and total orders for each category.
SELECT 
	category, 
	SUM(total_sale) AS total_sales,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1;

-- Q4. Write a SQL query to find the average age of customers by gender who purchased items from the 'Beauty' category.
SELECT 
	gender, 
	ROUND(AVG(age),0) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY 1;

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales 
WHERE total_sale > 1000;

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT 
	category, 
	gender, 
	COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY 1,2
ORDER BY 1;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
	year,
	month,
	avg_total_sales
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		ROUND(AVG(total_sale)::numeric, 2) AS avg_total_sales,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY 1,2
) AS t1
WHERE rank = 1
;

-- Q7 Alternative solution:
WITH monthly_avg AS (
	SELECT
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		ROUND(AVG(total_sale)::numeric,2) AS avg_sales
	FROM retail_sales
	GROUP BY 1,2
)

SELECT * 
FROM monthly_avg ma
WHERE avg_sales = (
	SELECT MAX(avg_sales) 
	FROM monthly_avg
	WHERE year = ma.year
	)
ORDER BY year,month;

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT 
	customer_id, 
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT 
	category, 
	COUNT(DISTINCT customer_id) AS count_unique_customer
FROM retail_sales
GROUP BY 1;

-- Q10. Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening >17)
WITH shift_table AS 
(
	SELECT *
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
	
SELECT shift, COUNT(*) AS num_of_orders
FROM shift_table
GROUP BY shift
ORDER BY 
	CASE 
		WHEN shift = 'Morning' THEN 1
		WHEN shift = 'Afternoon' THEN 2
		WHEN shift = 'Evening' THEN 3
	END;

-- End of project