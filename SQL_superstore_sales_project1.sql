

SELECT*
FROM superstore_sales

-- group by the total sales over the four years
SELECT year, SUM(sales) as total_sales
FROM superstore_sales
GROUP BY year;

-- Group by sales by product 

SELECT product_name, SUM(sales) AS total_sales
FROM  superstore_sales
GROUP BY product_name;


-- Group sales by region
SELECT region, SUM(sales) AS total_sales
FROM  superstore_sales
GROUP BY region;

-- Group sales by category

SELECT category, SUM(sales) AS total_sales
FROM  superstore_sales
GROUP BY category;


-- Monthly sales trend
SELECT year,MONTH(order_date) AS month,SUM(sales) AS total_sales
FROM  superstore_sales
GROUP BY year,MONTH(order_date);


-- top selling products 
SELECT product_name, SUM(sales) AS total_sales 
FROM superstore_sales
GROUP BY product_name
ORDER BY total_sales DESC;


-- Group by customer , region
SELECT customer_name, region, COUNT(order_id) AS purchase_count
FROM superstore_sales
GROUP BY customer_name, region;

-- group by avaerge order avlue 

SELECT AVG(sales) AS average_order_value
FROM superstore_sales


-- profit margin by product 
SELECT product_name , SUM(profit)/SUM(sales)*100 AS profit_margin
FROM superstore_sales
GROUP by product_name;


-- time between order date , ship date in each state 

SELECT state, AVG(DATEDIFF(day, order_date, ship_date)) AS avg_days_to_ship
FROM superstore_sales
GROUP BY state;

-- Find the difference between the order date and the ship date in each country in specific to the sub_category

SELECT 
    country, 
    sub_category, 
    MAX(DATEDIFF(day, order_date, ship_date)) AS max_days_to_ship,
    MIN(DATEDIFF(day, order_date, ship_date)) AS min_days_to_ship
FROM 
    superstore_sales
GROUP BY 
    country, 
    sub_category;

-- Which product has the most profit and the shipping cost

	SELECT 
    product_name, 
    SUM(profit) AS total_profit
FROM 
    superstore_sales
GROUP BY 
    product_name
ORDER BY 
    total_profit DESC;


-- which catrogory has the highest order prirotiy in all years

SELECT 
    category, 
    order_priority, 
    COUNT(order_id) AS order_count
FROM 
    superstore_sales
GROUP BY 
    category, 
    order_priority
ORDER BY 
    order_count DESC;


	-- Find the cocrelation between the product name and the sales
	SELECT 
    product_name, 
    AVG(sales) AS avg_sales, 
    VAR(sales) AS sales_variance
FROM 
    superstore_sales
GROUP BY 
    product_name
ORDER BY 
    avg_sales DESC;


	-- Combine average shipping cost and variance per shipping mode
SELECT 
    ship_mode, 
    AVG(shipping_cost) AS avg_shipping_cost, 
    VAR(shipping_cost) AS shipping_cost_variance
FROM 
    superstore_sales
GROUP BY 
    ship_mode
ORDER BY 
    avg_shipping_cost DESC;

	-- Finding correlation between shipping cost and the shipping mode 
SELECT 
    ship_mode, 
    AVG(shipping_cost) AS avg_shipping_cost
FROM 
    superstore_sales
GROUP BY 
    ship_mode
HAVING 
    AVG(shipping_cost) > 5 
ORDER BY 
    avg_shipping_cost DESC;

	-- the distinct types of the columns

SELECT DISTINCT ship_mode, segment, state,country, market, region,product_name
FROM superstore_sales;

-- using collate to specify the case sensitivie comparision
SELECT *
FROM superstore_sales
WHERE product_name COLLATE Latin1_General_CS_AS = 'Product A';

-- using the LIKE operator to know all the  sales made by the customer
SELECT *
FROM superstore_sales
WHERE customer_name LIKE 'John%';

-- using union statment to combine the category office supplies and furniture
SELECT product_name
FROM superstore_sales
WHERE category = 'Office Supplies'
UNION
SELECT product_name
FROM superstore_sales
WHERE category = 'Furniture';


-- use the union all subcategories as paper , label
SELECT product_name
FROM superstore_sales
WHERE sub_category = 'Paper'
UNION
SELECT product_name
FROM superstore_sales
WHERE sub_category = 'Labels';



-- using the except syntax to find products which  are foun iin office supplies and not in furniture
SELECT product_name
FROM superstore_sales
WHERE category = 'Office Supplies'
EXCEPT
SELECT product_name
FROM superstore_sales
WHERE category = 'Furniture';

-- checking the data type 
SELECT 
    CAST(sales AS bigint) * quantity AS total_sales
FROM 
    superstore_sales;


--Using case expression to deviate the sales as high , medium and low
SELECT 
    order_id,
    order_date,
    ship_date,
	product_name,
    CASE 
        WHEN sales > 1000 THEN 'High Sales'
        WHEN sales BETWEEN 500 AND 1000 THEN 'Medium Sales'
        ELSE 'Low Sales'
    END AS sales_category
FROM 
    superstore_sales;


-- using case to differntiate between the consumable and non consumable in the category column
	SELECT 
    order_id,
    order_date,
    ship_date,
	product_name,
    CASE 
        WHEN segment='Consumer' THEN 'Consumable'
   
        ELSE 'Non consumable'
    END AS sales_category
FROM 
    superstore_sales;


	SELECT order_id, sales
FROM superstore_sales
WHERE sales > (SELECT AVG(sales) FROM superstore_sales);


-- subquery with where clause to  find the catrgoy furniture
SELECT order_id, product_id,product_name,state
FROM superstore_sales
WHERE product_id IN (SELECT product_id FROM superstore_sales WHERE category = 'Furniture');


-- using the griup by and the having clause to group by the rpoduct id , and the avg sales of each product id in furniture
SELECT product_id, AVG(sales) AS avg_sales
FROM (
    SELECT product_id, sales, category,product_name
    FROM superstore_sales
) AS subquery
GROUP BY product_id, category
HAVING category = 'Furniture';

-- using nested subquery to find the total sales (max) of the sepcific product id in a specific region
SELECT product_id, region, total_sales
FROM (
    SELECT product_id, region, SUM(sales) AS total_sales
    FROM superstore_sales
    GROUP BY product_id, region
) AS subquery
WHERE total_sales = (SELECT MAX(total_sales) FROM (SELECT product_id, region, SUM(sales) AS total_sales FROM superstore_sales GROUP BY product_id, region) AS nested_subquery);


-- using the where clause with exist and subquery to find the order where atleast one other order exist with a higher sales amount

SELECT order_id, sales
FROM superstore_sales s1
WHERE EXISTS (
    SELECT 1
    FROM superstore_sales s2
    WHERE s2.sales > s1.sales
);


-- To find customers who have not placed orders in furniture using the NOT IN subquery
SELECT product_id,product_name,customer_name
FROM superstore_sales
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM superstore_sales WHERE product_id IN (SELECT product_id FROM superstore_sales WHERE category = 'Furniture'));
