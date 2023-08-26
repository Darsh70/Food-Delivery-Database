/* 20 SQL Queries*/
--Query 1: Select all columns and all rows from one table SELECT * FROM CUSTOMER;
--Query 2: Select five columns and all rows from one table
SELECT restaurant_name, cuisine_type, restaurant_phone, restaurant_address,restaurant_zip FROM restaurant;
--Query 3: Select all columns from all rows from one view

SELECT * FROM customercontact; /*Customercontact was a view created in DDL*/
--Query 4: Using a join on 2 tables, select all columns and all rows from the tables without the use of a Cartesian product
SELECT * FROM restaurant
JOIN menu_item ON restaurant.restaurant_id = menu_item.restaurant_id;
-- Query 5: Select and order data retrieved from one table SELECT * FROM restaurant
ORDER BY cuisine_type;
-- Query 6: Using a join on 3 tables, select 5 columns from the 3 tables. Use syntax that would limit the output to 10 rows
SELECT c.cust_fname, c.cust_lname, m.item_name, m.item_price, om.item_quantity
FROM customer c
JOIN c_order co
ON c.cust_id = co.cust_id
JOIN order_menu_items om ON co.order_id = om.order_id
JOIN menu_item m
ON om.menu_item_id = m.menu_item_id
FETCH FIRST 10 ROWS ONLY;
-- Query 7: Select distinct rows using joins on 3 tables
SELECT c.cust_fname, c.cust_lname, COUNT(DISTINCT co.order_id) "Total Orders Placed", sum(DISTINCT om.item_quantity) "Items Ordered"
FROM customer c
JOIN c_order co
ON c.cust_id = co.cust_id
JOIN order_menu_items om ON co.order_id = om.order_id
GROUP BY c.cust_fname, c.cust_lname

ORDER BY "Total Orders Placed" DESC;
-- Query 8: Use GROUP BY and HAVING in a select statement using one or more tables
SELECT r.cuisine_type "Cuisine Type", ROUND(AVG(m.item_price),2) "Average Price"
FROM restaurant r
JOIN c_order co
ON r.restaurant_id = co.restaurant_id
JOIN order_menu_items om ON co.order_id = om.order_id
JOIN menu_item m
ON om.menu_item_id = m.menu_item_id
GROUP BY r.cuisine_type HAVING AVG(m.item_price)>= 15 ORDER BY "Average Price" DESC;
-- Query 9: Use IN clause to select data from one or more tables
SELECT * FROM restaurant
WHERE restaurant.restaurant_zip IN (75080);
-- Query 10: Select length of one column from one table
SELECT d.driver_id, LENGTH (d.driver_fname) "Driver Name Length" FROM driver d
ORDER BY "Driver Name Length" DESC;
-- Query 11: Delete one record from one table. Use select statements to demonstrate the table contents before and after the DELETE statement. Make sure you use ROLLBACK afterwards so that the data will not be physically removed
ALTER TABLE order_menu_items
DROP CONSTRAINT FK_order_menu_item_order;
SELECT * FROM c_order; DELETE FROM c_order

WHERE order_id = 44; SELECT * FROM c_order; ROLLBACK;
ALTER TABLE order_menu_items
ADD CONSTRAINT FK_order_menu_item_order FOREIGN KEY(order_id) REFERENCES c_order (order_id);
--Query 12: Update one record from one table. Use select statements to demonstrate the table contents before and after the UPDATE statement. Make sure you use ROLLBACK afterwards so that the data will not be physically removed
SELECT * FROM c_order; UPDATE c_order
SET order_total = '85.65' WHERE order_id = 1; SELECT * FROM c_order; ROLLBACK;
--Perform 8 Additional Advanced Queries
--Query 13: List the number of orders, revenue generated and the difference between revenue and average revenue for each restaurant. Sort the result in descending order by the revenue generated.
SELECT r.restaurant_name, COUNT(o.order_id) AS num_orders, SUM(o.order_total) AS total_revenue, SUM(o.order_total) - (SELECT AVG(total_revenue)
FROM (SELECT r1.restaurant_name, SUM(o1.order_total) as total_revenue
FROM restaurant r1
JOIN c_order o1 ON o1.restaurant_id = r1.restaurant_id
GROUP BY r1.restaurant_name)) AS revenue_difference_from_average
FROM restaurant r
JOIN c_order o ON o.restaurant_id = r.restaurant_id GROUP BY r.restaurant_name
ORDER BY total_revenue DESC;
--Query 14: List the top 10 menu items by the number of orders and revenue generated for each restaurant.
SELECT r.restaurant_name, m.item_name, COUNT(m.menu_item_id) AS num_orders, SUM(m.item_price * om.item_quantity) AS revenue
FROM restaurant r
JOIN menu_item m ON r.restaurant_id = m.restaurant_id
JOIN order_menu_items om ON m.menu_item_id = om.menu_item_id

WHERE m.menu_item_id IN (
SELECT m.menu_item_id
FROM menu_item m
WHERE m.restaurant_id = r.restaurant_id GROUP BY m.menu_item_id
ORDER BY COUNT(*) DESC FETCH FIRST 10 ROWS ONLY )
GROUP BY r.restaurant_name, m.item_name ORDER BY num_orders DESC, revenue DESC FETCH FIRST 10 ROWS ONLY
--Query 15: List the revenue generated and the number of unique customers in each restaurant. Sort the result in descending order by the number of unique customers.
SELECT r.restaurant_name, SUM(o.order_total) AS total_revenue, COUNT(DISTINCT c.cust_id) AS unique_customers
FROM restaurant r
JOIN c_order o ON r.restaurant_id = o.restaurant_id
JOIN customer c ON o.cust_id = c.cust_id GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
--Query 16: Find the order ID, restaurant name, driver name, and tip for the order with the highest order total.
SELECT o.order_id, r.restaurant_name, d.driver_fname || ' ' || d.driver_lname AS driver_name, o.order_total, o.driver_tip
FROM c_order o
JOIN restaurant r ON o.restaurant_id = r.restaurant_id
JOIN driver d ON o.driver_id = d.driver_id WHERE o.order_total = (
SELECT MAX(order_total) FROM c_order
)
--Query 17: Find the customer who has the lowest order_total and the driver who delivered it.
SELECT c.cust_id, c.cust_fname || ' ' || c.cust_lname AS customer_name, d.driver_fname || ' ' || d.driver_lname AS driver_name, o.order_total
FROM c_order o
JOIN customer c ON o.cust_id = c.cust_id

JOIN driver d ON o.driver_id = d.driver_id WHERE o.order_total = (
SELECT MIN(order_total) FROM c_order
)
--Query 18: List the drivers who deliver from the restaurant with the highest items available in the menu. Display the restaurant name, number of items and the driver’s full name. Sort the result in ascending order according to driver name
SELECT r.restaurant_name, COUNT(DISTINCT m.menu_item_id) AS num_items, d.driver_fname || ' ' || d.driver_lname AS driver_name
FROM restaurant r
JOIN menu_item m ON r.restaurant_id = m.restaurant_id
JOIN c_order o ON r.restaurant_id = o.restaurant_id JOIN driver d ON o.driver_id = d.driver_id
WHERE r.restaurant_id IN (
SELECT r1.restaurant_id
FROM restaurant r1
JOIN menu_item m1 ON r1.restaurant_id = m1.restaurant_id GROUP BY r1.restaurant_id
ORDER BY COUNT(DISTINCT m1.menu_item_id) DESC
FETCH FIRST 1 ROWS ONLY
)
GROUP BY r.restaurant_name, d.driver_fname, d.driver_lname ORDER BY driver_name
--Query 19: Find the Average Driver Tip for Drivers with an Driver Rating of at least 3.5
SELECT DISTINCT(d.driver_fname || ' ' || d.driver_lname) "Driver Name", ROUND(AVG(o.driver_tip),2) "Average Tip"
FROM driver d
JOIN c_order o
ON o.driver_id = d.driver_id
WHERE o.driver_rating>=3.5
GROUP BY d.driver_fname || ' ' || d.driver_lname
--Query 20: List the customers who spent the most and least along with the tip they gave. Display the customer’s full name, total money spent and the tip
SELECT c.cust_fname || ' ' || c.cust_lname AS customer_name, COUNT(o.order_id) AS num_orders, SUM(o.order_total) AS total_spent, SUM(o.driver_tip) AS total_tip

FROM customer c
JOIN c_order o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_fname, c.cust_lname HAVING SUM(o.order_total) = (
SELECT MAX(total_spent) FROM (
SELECT cust_id, SUM(order_total) AS total_spent FROM c_order
GROUP BY cust_id
) )
OR SUM(o.order_total) = ( SELECT MIN(total_spent) FROM (
SELECT cust_id, SUM(order_total) AS total_spent FROM c_order
GROUP BY cust_id
) )
ORDER BY total_spent DESC;
