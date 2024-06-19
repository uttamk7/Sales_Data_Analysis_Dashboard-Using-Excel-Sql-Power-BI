--Q1. Number of orders by month based on order status (Delivered vs. canceled vs. etc.) - Split of order status by month

select count(ORDER_NUMBER) as No_of_Orders,MONTH(ORDER_DATE) as Order_Month,ORDER_STATUS 
	from [dbo].[Ordersdata]
	group by MONTH(ORDER_DATE),ORDER_STATUS
	order by MONTH(ORDER_DATE);

--Q2. Number of orders by month based on delivery status

select count(ORDER_NUMBER) as NO_of_Orders,MONTH(ORDER_DATE) as Order_Month,DELIVERY_STATUS from Ordersdata
	group by MONTH(ORDER_DATE),DELIVERY_STATUS
	order by MONTH(ORDER_DATE)

--Q3. Month-on-month growth in OrderCount and Revenue (from Nov’15 to July’16)

	SELECT 
    CONCAT(YEAR(order_date), '-', MONTH(order_date)) AS month_year,
    COUNT(*) AS order_count,
    SUM(order_total) AS total_revenue,
    (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))) AS order_count_growth,
    (SUM(order_total) - LAG(SUM(order_total)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))) AS revenue_growth
FROM 
    [dbo].[ordersdata]
WHERE 
    order_date >= '2015-11-01' AND order_date <= '2016-07-31'
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    YEAR(order_date), MONTH(order_date)

--Q4. Month-wise split of total order value of the top 50 customers (The top 50 customers need to identified based on their total order value)

SELECT top 50 [CUSTOMER_ID],MONTH([ORDER_DATE]) AS month,
        SUM([ORDER_TOTAL]) AS tot_order_value
    FROM 
      [dbo].[Customer_data] c
	   inner join [dbo].[ordersdata] o on o.[CUSTOMER_KEY]=c.[CUSTOMER_KEY]
    GROUP BY 
        [CUSTOMER_ID],MONTH([ORDER_DATE])
    ORDER BY 
        tot_order_value DESC

--Q5. Month-wise split of new and repeat customers. New customers mean, new unique customer additions in any given month

	SELECT 
    order_month,
    COUNT(DISTINCT CASE WHEN first_order_month = order_month THEN [CUSTOMER_KEY]END) AS new_customers,
    COUNT(DISTINCT CASE WHEN first_order_month != order_month THEN [CUSTOMER_KEY] END) AS repeat_customers
FROM (
    SELECT     
        MONTH(order_date) AS order_month,
      [CUSTOMER_KEY] ,
        MIN(MONTH(order_date)) OVER (PARTITION BY [CUSTOMER_KEY]) AS first_order_month
    FROM 
        [dbo].[ordersdata]
) AS subquery
GROUP BY 
    order_month
ORDER BY 
     order_month



	 /* Q6 Write stored procedure code which take inputs as location & month, and the output is total_order value and number
	 of orders by Gender, Delivered Status for given location & month. Test the code with different options*/

	 CREATE PROCEDURE GetOrderDataByLocationMonth
    @Location NVARCHAR(100),
    @Month INT
AS
BEGIN
    SELECT
        C.Gender,
        O.DELIVERY_STATUS,
        COUNT(*) AS OrderCount,
        SUM(O.ORDER_TOTAL) AS TotalOrderValue
    FROM 
        [dbo].[Ordersdata] O
    INNER JOIN 
        Customer_data C ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
    WHERE 
        C.Location = @Location
        AND MONTH(O.ORDER_DATE) = @Month
    GROUP BY 
        C.Gender, O.DELIVERY_STATUS;
END;


 EXEC GetOrderDataByLocationMonth @Location = 'Bangalore', @Month = 5;
  --Test the code with different options--
 EXEC GetOrderDataByLocationMonth @Location = 'New York', @Month = 8;



--Q7. Create Customer 360 File with Below Columns using Orders Data & Customer Data (12 Marks)

with Customer360 as (select C.CUSTOMER_ID,C.CONTACT_NUMBER,C.Referred_Other_customers,C.Gender,C.[Location],C.Acquired_Channel,
	count(O.ORDER_NUMBER) as No_of_Orders,
	sum(O.ORDER_TOTAL) as Total_Order_Value,
	sum(case when O.DISCOUNT>0 then 1 else 0 end) as Total_No_Of_Orders_With_Discount,
	sum(case when O.DELIVERY_STATUS='LATE' then 1 else 0 end) as Total_No_Of_Orders_Received_Late,
	sum(case when O.ORDER_TOTAL<0 then 1 else 0 end) as Total_No_Of_Orderd_Returned,
	max(O.ORDER_TOTAL) as Max_Order_Value,
	min(O.ORDER_DATE) as First_Transaction_Date,
	max(O.ORDER_DATE) as Last_Transaction_Date,
	DATEDIFF(MONTH,min(O.ORDER_DATE),max(O.ORDER_DATE)) as Tenure_Montths,
	sum(case when O.ORDER_TOTAL=0 then 1 else 0 end) as No_Of_Orders_With_ZeroValue
	from [dbo].[Customer_data] C
	left join [dbo].[Ordersdata] O on O.CUSTOMER_KEY=C.CUSTOMER_KEY
	group by C.CUSTOMER_ID,C.CONTACT_NUMBER,C.Referred_Other_customers,C.Gender,C.[Location],C.Acquired_Channel)
select * from Customer360

--Q8. Total Revenue, total orders by each location

select sum(O.ORDER_TOTAL) as Total_Revenue,count(O.ORDER_NUMBER) as Total_Orders,C.[Location]
	from Customer_data C
	left join Ordersdata O on O.CUSTOMER_KEY=C.CUSTOMER_KEY
	group by C.[Location];

--Q9. Total revenue, total orders by customer gender

select sum(O.ORDER_TOTAL) as Total_Revenue,count(O.ORDER_NUMBER) as Total_Orders,C.Gender
	from Customer_data C
	left join Ordersdata O on O.CUSTOMER_KEY=C.CUSTOMER_KEY
	group by C.Gender;

--Q10. Which location of customers cancelling orders maximum?

select top 1 C.[Location],count(O.ORDER_NUMBER) as No_Of_Cancelled_Orders from Customer_data C
	left join Ordersdata O on O.CUSTOMER_KEY=C.CUSTOMER_KEY
	where ORDER_STATUS='Cancelled'
	group  by C.[Location]
	order by count(O.ORDER_NUMBER) desc;

--Q11. Total customers, Revenue, Orders by each Acquisition channel

select C.Acquired_Channel,count(O.CUSTOMER_KEY) as Total_Customers,sum(O.ORDER_TOTAL) as Total_Revenue,count(O.ORDER_NUMBER) as Total_Orders
	from Customer_data C
	left join Ordersdata O on O.CUSTOMER_KEY=C.CUSTOMER_KEY
	group by C.Acquired_Channel



--Q12. Which acquisition channel is good interms of revenue generation, maximum orders, repeat purchasers?

SELECT
    [Acquired_Channel],
    SUM([ORDER_TOTAL]) AS Total_Revenue,
    COUNT(*) AS Total_Orders,
    COUNT(DISTINCT [CUSTOMER_ID]) AS Total_Customers,
    SUM(CASE WHEN Customer_Order_Count > 1 THEN 1 ELSE 0 END) AS Repeat_Customers
FROM(
    SELECT
        C.[Acquired_Channel],
        O.[ORDER_TOTAL],
        C.[CUSTOMER_ID],
        COUNT(*) OVER (PARTITION BY C.[CUSTOMER_ID]) AS Customer_Order_Count
    FROM
        [dbo].[Ordersdata] O
        INNER JOIN [dbo].[Customer_data] C ON O.[CUSTOMER_KEY] = C.[CUSTOMER_KEY]
) AS OrderDetails
GROUP BY
    [Acquired_Channel]
ORDER BY
    Total_Revenue DESC, Total_Orders DESC, Repeat_Customers DESC;


	/*Q13. Write User Defined Function (stored procedure) which can take input table which create two tables with numerical
	variables and categorical variables separately */
	
	CREATE PROCEDURE SplitVariables
    @InputTableName NVARCHAR(100)
AS
BEGIN
   
    DECLARE @NumericalTable TABLE (
        ColumnName NVARCHAR(100)
    );

    
    DECLARE @CategoricalTable TABLE (
        ColumnName NVARCHAR(100)
    );

    INSERT INTO @NumericalTable (ColumnName)
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @InputTableName
    AND DATA_TYPE IN ('int', 'decimal', 'numeric', 'float');

    INSERT INTO @CategoricalTable (ColumnName)
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @InputTableName
    AND DATA_TYPE NOT IN ('int', 'decimal', 'numeric', 'float');

    SELECT * FROM @NumericalTable;
    SELECT * FROM @CategoricalTable;
END


EXEC SplitVariables Ordersdata;

DROP PROCEDURE SplitVariables

	--Q14

	-- What is the percentage of customers who are males acquired by WEBSITE channel?


select (sum(case when [Gender]='M' then 1 else 0 end)*100/nullif(count(*),0)) as Percent_Males,
	sum(case when Gender='M' then 1 else 0 end) as Total_Males,
	count(*) as Total_Customers
	from Customer_data
	where Acquired_Channel='WEBSITE'


--Which location having maximum orders delivered in ON-TIME?

SELECT 
 top 1 [Location],
    COUNT(*) AS ONTIME_orders
FROM 
[dbo].[Customer_data] c
inner join  [dbo].[Ordersdata] o on o.[CUSTOMER_KEY]=c.CUSTOMER_KEY
WHERE 
   [DELIVERY_STATUS] = 'ON-TIME'
GROUP BY 
  [Location]
ORDER BY 
   ONTIME_orders DESC


--What is the percentage of orders got Delivered?
   SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN [ORDER_STATUS]= 'Delivered' THEN 1 ELSE 0 END) as Delivered_orders,
    (SUM(CASE WHEN [ORDER_STATUS]= 'Delivered' THEN 1 ELSE 0 END) * 100) / COUNT(*) AS Delivered_percentage
FROM [dbo].[Ordersdata]

--What is the percentage of Female customers exists?
  select  
    (count(case when [Gender]= 'F' then 1 end) * 100) / count(*) as per_female_customers
from
    [dbo].[Customer_data]
	



-- Which location having more orders with 50 discount amount?
select top 1 [Location],
    count(*) as fifty_discount
FROM  [dbo].[Customer_data] c
inner join [dbo].[Ordersdata]  o on o.[CUSTOMER_KEY]=c.CUSTOMER_KEY
WHERE 
    [DISCOUNT] =50
GROUP BY 
    [Location]
ORDER BY 
    fifty_discount DESC




	