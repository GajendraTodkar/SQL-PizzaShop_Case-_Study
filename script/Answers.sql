USE pizza_sale_analysis;

-- 1. Retrieve the total number of orders placed.
SELECT COUNT (distinct order_id) as total_orders
FROM orders;


-- 2. Calculate the total revenue generated from pizza sales.
SELECT SUM (o.quantity * p.price) as total_revenue
FROM order_detail as o
FULL JOIN pizza as p
ON o.pizza_id = p.pizza_id;


-- 3. Identify the highest-priced pizza.
SELECT TOP 1 t.name, p.price 
FROM pizza as p
JOIN type as t
ON p.pizza_type_id = t.pizza_type_id
ORDER BY price desc;

-- ALternate with CTE.
WITH cte as (
			SELECT type.name as 'Pizza name', pizza.price  as 'Price',
			RANK () OVER (ORDER BY price DESC) as rnk
			FROM pizza
			JOIN type ON
			type.pizza_type_id = pizza.pizza_type_id
			)
SELECT [Pizza name], Price FROM cte WHERE rnk = 1


-- 4. Identify the most common pizza size ordered.
SELECT  TOP 1 p.size, SUM (o.quantity) as 'Number of orders'
FROM order_detail as o
JOIN pizza as p
ON o.pizza_id  = p.pizza_id
GROUP BY p.size;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT  TOP 5 t.name, SUM (o.quantity) as 'Number of orders'
FROM order_detail as o
JOIN pizza as p
ON o.pizza_id  = p.pizza_id
JOIN type as t
ON p.pizza_type_id = t.pizza_type_id
GROUP BY t.name
ORDER BY [Number of orders] DESC;


-- 6. Find the total quantity of each pizza category ordered 
SELECT t.category 'Category', SUM(o.quantity) as 'Order qty'
FROM order_detail as o
JOIN pizza as p
ON o.pizza_id = p.pizza_id
JOIN type as t
ON p.pizza_type_id = t.pizza_type_id
GROUP BY t.category
ORDER BY [Order qty] DESC;
		

-- 7. Determine the distribution of orders by hour of the day 
-- (at which time the orders are maximum (for inventory management and resource allocation).
SELECT  DATEPART (HOUR, time) as hrs, COUNT (order_id) as ' Total Orders'
FROM orders
GROUP BY  DATEPART (HOUR, time)
ORDER BY [hrs];


-- 8. Find the category-wise distribution of pizzas (to understand customer behaviour).
SELECT category as 'Category', COUNT (DISTINCT pizza_type_id) as 'Number of Pizza' 
FROM type
GROUP BY category
ORDER BY [Number of Pizza];


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
WITH cte as (
			SELECT SUM(od.quantity) as total_order
			FROM orders as o
			JOIN order_detail as od
			ON o.order_id = od.order_id
			GROUP BY o.date
)
SELECT AVG(total_order) as 'Average order per day' FROM cte;


-- 10. Determine the top 3 most ordered pizza types based on revenue 
-- (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)
SELECT TOP 3 type.name,
SUM (order_detail.quantity * pizza.price) as 'total'
FROM order_detail
JOIN pizza
ON order_detail.pizza_id = pizza.pizza_id
JOIN type
ON type.pizza_type_id = pizza.pizza_type_id
GROUP BY type.name
ORDER BY [total] DESC;


-- 11. Calculate the percentage contribution of each pizza type to total revenue 
-- (to understand % of contribution of each pizza in the total revenue)
WITH cte AS (
			SELECT type.name, 
					SUM (order_detail.quantity * pizza.price) as revenue
			FROM order_detail
			JOIN pizza ON order_detail.pizza_id = pizza.pizza_id
			JOIN type ON type.pizza_type_id = pizza.pizza_type_id
			GROUP BY type.name
			)
SELECT name, revenue,
	   CAST((revenue/SUM(revenue) OVER ()) * 100 as DECIMAL (10,2)) as 'percentage of revenue'
FROM cte;


-- 12. Analyze the cumulative revenue generated over time.
WITH cte AS (
    SELECT
        orders.date AS order_date,
        SUM(order_detail.quantity * pizza.price) AS revenue
    FROM order_detail
    JOIN pizza
      ON order_detail.pizza_id = pizza.pizza_id
    JOIN orders
      ON orders.order_id = order_detail.order_id
    GROUP BY orders.date
	)
SELECT order_date, SUM (revenue) OVER (ORDER BY order_date) as Daily_revenue
FROM cte


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category
-- (In each category which pizza is the most selling)
WITH cte as (
			SELECT  type.name, type.category, SUM(order_detail.quantity * pizza.price) as revenue,
			ROW_NUMBER () OVER (PARTITION BY type.category ORDER BY SUM(order_detail.quantity * pizza.price) DESC) as rnk
			FROM order_detail
			JOIN pizza
			ON order_detail.pizza_id = pizza.pizza_id
			JOIN type
			ON pizza.pizza_type_id = type.pizza_type_id
			GROUP BY type.category,type.name
			)
SELECT category, name, revenue
FROM cte
WHERE rnk <= 3
ORDER BY category, revenue DESC