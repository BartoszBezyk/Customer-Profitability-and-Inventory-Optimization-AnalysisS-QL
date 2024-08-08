# Customer-Profitability-and-Inventory-Optimization-Analysis-SQL
This project aims to analyze a database containing various tables related to customer orders, payments, and product information to derive insights that can help optimize inventory and marketing strategies.

Database Overview
The database consists of 8 tables: products, productlines, orders, orderdetails, customers, payments, employees, and offices. The tables are related through specific keys, enabling complex queries to extract meaningful insights.

Methods used in this project:
-  Common Table Expressions (CTEs)
-  JOIN Operations
-  Aggregations and Grouping
-  Subqueries
-  String Functions and Data Type Conversion
  
Conclusion

Based on our analysis, we have identified key products and customer segments to help optimize our inventory and marketing strategies. The products that require priority restocking are vintage cars and motorcycles, as they exhibit high sales frequency and performance. These include models like the 1968 Ford Mustang, 1911 Ford Town Car, 1928 Mercedes-Benz SSK, and several notable motorcycles such as the 1960 BSA Gold Star DBD34 and the 2002 Yamaha YZR M1.

In terms of customer segmentation, we have pinpointed our VIP customers who contribute the highest profits, including Diego Freyre from Madrid, Susan Nelson from San Rafael, and Jeff Young from NYC. These individuals should be the focus of our loyalty programs and personalized communication strategies. Conversely, we have also identified the least engaged customers, such as Mary Young from Glendale and Leslie Taylor from Brickhaven, who could benefit from targeted marketing efforts to increase their engagement. Furthermore, our Customer Lifetime Value (LTV) analysis reveals that an average customer generates $39,039.59 in profit, providing a benchmark for how much we can invest in acquiring new customers to ensure sustainable growth.
Our analysis of the cumulative profit by country along with the number of customers and average profit per customer has revealed the following key insights:

- USA: The USA is our most profitable market with a total profit of $1,308,815.59 from 35 customers, averaging $37,394.73 per customer.
- Spain: Despite having only 5 customers, Spain generates a significant total profit of $440,004.54, with an average profit per customer of $88,000.91, indicating a high profitability per customer.
- France: France has 12 customers with a total profit of $413,016.12, averaging $34,418.01 per customer.
- Australia: With a total profit of $222,207.18 from 5 customers, the average profit per customer in Australia is $44,441.44.
- New Zealand: New Zealand's total profit is $189,506.58 from 4 customers, averaging $47,376.65 per customer.
  
Other notable countries include the UK, Italy, Finland, Singapore, and Denmark, each contributing to the overall profitability with varying customer numbers and average profits.

Table Relations
- products and orderdetails are linked through productCode.
- products and productlines are linked through productLine.
- orders and orderdetails are linked through orderNumber.
- customers and orders are linked through customerNumber.
- customers and payments are linked through customerNumber.
- customers and employees are linked through employeeNumber or salesRepEmployeeNumber.
- employees table self-references for attributes employeeNumber and reportsTo.
- employees and offices are linked through officeCode.
