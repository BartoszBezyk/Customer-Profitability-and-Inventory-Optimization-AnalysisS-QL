/*
This Database contains 8 tables named 
products,productlines,orders,orderdetails,customers,payments,employees and offices.
*/

-- Table information:
/*
    Customers: customer data
    Employees: all employee information
    Offices: sales office information
    Orders: customers' sales orders
    OrderDetails: sales order line for each sales order
    Payments: customers' payment records
    Products: a list of scale model cars
    ProductLines: a list of product line categories */
	
-- Table Relations:
/* products and orderdetails tables are linked through "productCode".
   products and productlines tables are linked through "productLine".
   orders and orderdetails tables are linked through "orderNumber".
   customers and orders tables are linked through "customerNumber".
   customers and payments tables are linked through "customerNumber".
	 customers and employees tables are linked through "employeeNumber" or " salesRepEmployeeNumber".
	 employees  table  self reference the table itself for attributes "employeeNumber" and "reportsTo".
	 employees and offices tables are linked through "officeCode".*/
  

-- First, create a table that shows how many columns and rows are in each table 

SELECT 'Customers' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('customers')) AS number_of_attributes,
        COUNT(*) as num_rows
    FROM customers
    
UNION ALL

SELECT 'Employees' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('employees')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM employees
    
UNION ALL

SELECT 'Offices' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('offices')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM offices
    
UNION ALL

SELECT 'OrderDetails' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('orderdetails')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM orderdetails

UNION ALL

SELECT 'Orders' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('orders')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM orders
    
UNION ALL

SELECT 'Payments' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('payments')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM payments
    
UNION ALL

SELECT 'ProductLines' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('productlines')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM productlines
    
UNION ALL 

SELECT 'Products' AS table_name,
    (SELECT COUNT(*)
        FROM pragma_table_info('product')) AS number_of_attributes,
        COUNT(*) AS num_rows
    FROM products;
    
-- The first question is: Which Products Should We Order More of or Less of?
/* To answer this question we need to calculate 2 attributes (low stock and  product performance). 
This should tell us which products are high rated by users and we should not run off from them.
* The low stock represents the quantity of the sum of each product divided by the quantity of product in stock.
The product performance represents the sum of sales per product.
Priority products for restocking are those with high product performance that are on the brink of being out of stock. */

WITH low_stock AS (
SELECT p.productCode, p.productName, SUM(o.quantityOrdered)/p.quantityInStock AS low_stock
    FROM products AS p
    JOIN orderdetails AS o
    ON p.productCode = o.productCode
    GROUP BY p.productCode, p.productName),
    
product_performance AS (
SELECT p.productCode, ROUND(SUM(o.quantityOrdered * o.priceEach),2) AS product_performance
    FROM products AS p
    JOIN orderdetails AS o
    ON p.productCode = o.productCode
    GROUP BY p.productCode)
    
SELECT l.productName, l.low_stock, p.product_performance
FROM low_stock AS l
JOIN product_performance AS P
ON l.productCode = p.productCode
ORDER BY low_stock DESC, product_performance DESC
LIMIT 10;

-- The second question is: How should we match marketing and communication strategies to customer behaviors?
/* For example, we could organize some events to drive loyalty for the VIPs and launch a campaign for the less engaged.
This involves categorizing customers into VIP's and less engaged customers. 
To do that, we need to compute how much profit each customer generates. */


-- TOP 5 customers
WITH profit AS (

SELECT o.customerNumber, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)),2) AS profit
    FROM orders AS o
    JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
    JOIN products as p
    ON od.productCode = p.productCode
    GROUP BY o.customerNumber)
    
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, p.profit
    FROM customers AS c
    JOIN profit AS p
    ON c.customerNumber = p.customerNumber
    ORDER BY profit DESC
    LIMIT 5;
    
--TAIL 5 customers
WITH profit AS (

SELECT o.customerNumber, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)),2) AS profit
    FROM orders AS o
    JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
    JOIN products as p
    ON od.productCode = p.productCode
    GROUP BY o.customerNumber)
    
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, p.profit
    FROM customers AS c
    JOIN profit AS p
    ON c.customerNumber = p.customerNumber
    ORDER BY profit 
    LIMIT 5;
    
-- We can check wchich country is the best for finding new customers by computing averge profit per customer in each country.

WITH profit AS (

SELECT o.customerNumber, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)),2) AS profit,
       COUNT(DISTINCT c.customerNumber) AS number_of_customers,
       ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) / COUNT(DISTINCT c.customerNumber), 2) AS avg_profit_per_customer
    FROM orders AS o
    JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
    JOIN products as p
    ON od.productCode = p.productCode
    JOIN customers AS c
    ON o.customerNumber = c.customerNumber
    GROUP BY c.country)
    
SELECT  c.country, p.profit, p.number_of_customers, p.avg_profit_per_customer
    FROM customers AS c
    JOIN profit AS p
    ON c.customerNumber = p.customerNumber
    ORDER BY profit DESC
    

-- Question 3: How much can we spend on acquiring new customers?
/* First, we should find the number of new customers arriving each month. That way we can chceck if it's worth spending money
on acquiring new customers */

WITH 
-- CTE with column formed by adding year and month into one string
payment_with_year_month_table AS (
    SELECT *, 
        CAST(SUBSTR(paymentDate,1,4) AS INTEGER) * 100 + CAST(SUBSTR(paymentDate, 6,7) AS INTEGER) AS year_month
    FROM payments AS p
),

-- CTE with columns representing num. of customers and total profit each month and year
customers_by_month_table AS (
    SELECT p1.year_month, 
           COUNT(*) AS number_of_customers, 
           ROUND(SUM(p1.amount), 2) AS total
    FROM payment_with_year_month_table AS p1
    GROUP BY p1.year_month
),

-- CTE with columns representing number of new customers and their total profit each month and year,
-- as well as total number of customers and total profit for each month and year from previous CTE
new_customers_by_month_table AS (
    SELECT p1.year_month, 
           COUNT(DISTINCT customerNumber) AS number_of_new_customers,
           ROUND(SUM(p1.amount), 2) AS new_customer_total,
           (SELECT number_of_customers
            FROM customers_by_month_table AS c
            WHERE c.year_month = p1.year_month) AS number_of_customers,
           (SELECT total
            FROM customers_by_month_table AS c
            WHERE c.year_month = p1.year_month) AS total
    FROM payment_with_year_month_table AS p1
    WHERE p1.customerNumber NOT IN (
        SELECT customerNumber
        FROM payment_with_year_month_table AS p2
        WHERE p2.year_month < p1.year_month
    )
    GROUP BY p1.year_month
)

-- Final selection that calculates the proportion of new customers and their total profit for each month and year
SELECT year_month, 
       ROUND(number_of_new_customers * 100 / number_of_customers, 1) AS number_of_new_customers_props,
       ROUND(new_customer_total * 100 / total, 1) AS new_customers_by_month_table
FROM new_customers_by_month_table;

/*The number of clients has been decreasing since 2003, and in 2004, we had the lowest values. 
The year 2005, which is present in the database as well, isn't present in the table above, 
this means that the store has not had any new customers since September of 2004.
 This means it makes sense to spend money acquiring new customers. */
 
/*To determine how much money we can spend acquiring new customers, we can compute the Customer Lifetime Value (LTV), 
which represents the average amount of money a customer generates. We can then determine how much we can spend on marketing. */

WITH customer_profit AS (

SELECT o.customerNumber, ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)),2) AS profit
    FROM orders AS o
    JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
    JOIN products as p
    ON od.productCode = p.productCode
    GROUP BY o.customerNumber)
    
SELECT ROUND(AVG(p.profit),2) AS avg_profit
    FROM customer_profit as p;
    
--Conclusion

/* Based on our analysis, we have identified key products and customer segments to help optimize our inventory and marketing strategies. 
The products that require priority restocking are vintage cars and motorcycles, as they exhibit high sales frequency and performance. 
These include models like the 1968 Ford Mustang, 1911 Ford Town Car, 1928 Mercedes-Benz SSK, and several 
notable motorcycles such as the 1960 BSA Gold Star DBD34 and the 2002 Yamaha YZR M1. In terms of customer segmentation, 
we have pinpointed our VIP customers who contribute the highest profits, including Diego Freyre from Madrid, 
Susan Nelson from San Rafael, and Jeff Young from NYC. These individuals should be the focus of our loyalty programs 
and personalized communication strategies. Conversely, we have also identified the least engaged customers, 
such as Mary Young from Glendale and Leslie Taylor from Brickhaven, who could benefit from targeted marketing efforts to increase their engagement. 
Furthermore, our Customer Lifetime Value (LTV) analysis reveals that an average customer generates $39,039.59 in profit, 
providing a benchmark for how much we can invest in acquiring new customers to ensure sustainable growth. 
Detailed Insights by Country
Our analysis of the cumulative profit by country along with the number of customers and average profit per customer has revealed the following key insights:
USA: The USA is our most profitable market with a total profit of $1,308,815.59 from 35 customers, averaging $37,394.73 per customer.
Spain: Despite having only 5 customers, Spain generates a significant total profit of $440,004.54, with an average profit per customer of $88,000.91, indicating a high profitability per customer.
France: France has 12 customers with a total profit of $413,016.12, averaging $34,418.01 per customer.
Australia: With a total profit of $222,207.18 from 5 customers, the average profit per customer in Australia is $44,441.44.
New Zealand: New Zealand's total profit is $189,506.58 from 4 customers, averaging $47,376.65 per customer.
Other notable countries include the UK, Italy, Finland, Singapore, and Denmark, each contributing to the overall profitability with varying customer numbers and average profits. */

