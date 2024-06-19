use Case_Study

--Q1 START--
select SUM([ORDER_TOTAL]) as Total_Revenue 
from [dbo].[Ordersdata]
where [ORDER_TOTAL] > 0
--Q1 END--

--Q2 START--
select sum(TotalRevenue) AS TotalRevenueBy25Customers
FROM (SELECT TOP 25 sum([ORDER_TOTAL]) as TotalRevenue,[CUSTOMER_KEY]
FROM [dbo].[Ordersdata]
WHERE [ORDER_TOTAL] > 0
Group By [CUSTOMER_KEY]
Order By sum([ORDER_TOTAL]) desc) as Top25Customerinfo
--Q2 END--

--Q3 START--
select count([ORDER_NUMBER]) as Total_Orders
from [dbo].[Ordersdata]
--Q3 END--

--Q4 START--
select  top 10 [CUSTOMER_KEY], COUNT(*) AS total_orders
FROM [dbo].[Ordersdata] o
GROUP BY [CUSTOMER_KEY]
ORDER BY total_orders DESC
--Q4 END--

--Q6 START--
SELECT COUNT(*) AS num_customers_ordered_once
FROM (
    SELECT [CUSTOMER_KEY]
    FROM [dbo].[Ordersdata]
    GROUP BY [CUSTOMER_KEY]
    HAVING COUNT(*) = 1
) AS single_order_customers;
--Q6 END--

--Q7 START--
SELECT count(*) AS no_of_customers
FROM (
    SELECT [CUSTOMER_KEY]
    FROM [dbo].[Ordersdata]
    GROUP BY [CUSTOMER_KEY]
    HAVING COUNT(*) > 1
) AS multiple_order_customers;
--Q7 END--

--Q8 START--
select count([Referred_Other_customers]) as no_customers_referred
from [dbo].[Customer_data]
where [Referred_Other_customers]='1'
--Q23 END--

--Q9 START--
select top 1 month([ORDER_DATE]) as month, SUM([ORDER_TOTAL]) as total_revenue
from [dbo].[Ordersdata]
group by MONTH([ORDER_DATE])
order by total_revenue desc
--Q23 END--

--Q10 START--
SELECT count(DISTINCT CUSTOMER_KEY) AS InactiveCustomersList
	FROM [dbo].[Ordersdata]
	WHERE CUSTOMER_KEY NOT IN (SELECT DISTINCT CUSTOMER_KEY FROM [dbo].[Ordersdata]
		                       WHERE ORDER_DATE>=DATEADD(DAY,-60,(SELECT max(ORDER_DATE) 
							   FROM [dbo].[Ordersdata])));
--Q10 END--

--Q11 START--
select  (
	(count(case when month([ORDER_DATE]) = 7 and year([ORDER_DATE]) = 2016 then 1 end) 
	- count(case when month([ORDER_DATE]) = 11 and year([ORDER_DATE]) = 2015 then 1 end)) / 
	count(case when month([ORDER_DATE]) = 11 and year([ORDER_DATE]) = 2015 then 1 end)) * 100 AS per_growth_rate
from 
   [dbo].[Ordersdata]
where 
    ([ORDER_DATE]>= '2015-11-01' and [ORDER_DATE]< '2016-08-01')
--Q11 END--

--Q12 START--
select
    (
	(sum(case when MONTH([ORDER_DATE])= 7 AND YEAR([ORDER_DATE]) 
	= 2016 then [ORDER_TOTAL] else 0 end) - sum(case when MONTH([ORDER_DATE]) 
	= 11 AND YEAR([ORDER_DATE]) = 2015 THEN [ORDER_TOTAL] ELSE 0 END)) / SUM(CASE WHEN MONTH([ORDER_DATE]) 
	= 11 AND YEAR([ORDER_DATE]) = 2015 THEN [ORDER_TOTAL] ELSE 0 END)) * 100 AS growth_rate_percentage
from
   [dbo].[Ordersdata]
where 
    ( [ORDER_DATE]>= '2015-11-01' AND [ORDER_DATE] < '2016-08-01')
--Q12 END--

--Q13 START--
  select  
    (count(case when [Gender]= 'M' then 1 end) * 100) / count(*) as per_male_customers
from [dbo].[Customer_data]
    
--Q13 END--

--Q14 START--

select top 1 [Location],
    count(*) as total_customers
FROM  [dbo].[Customer_data]
GROUP BY [Location]
ORDER BY 
    total_customers desc
--Q14 END--

--Q15 START--

select 
    count(*) as order_returned
from [dbo].[Ordersdata]

where 
    [ORDER_TOTAL] < 0
--Q15 END--

--Q16 START--

select [Acquired_Channel],
    COUNT(*) AS acquired_customers,
    (COUNT(*) * 100.0 / (select COUNT(*) from [dbo].[Customer_data])) as acquisition_rate
from [dbo].[Customer_data]
    group by [Acquired_Channel]
    order by  acquisition_rate desc
--Q16 END--

--Q17 START--
select top 1 [Location],
    count(*) as orders_with_discount
from [dbo].[Customer_data] c
inner join [dbo].[Ordersdata]  o on o.[CUSTOMER_KEY]=c.CUSTOMER_KEY
where [DISCOUNT] > 0
group by [Location]
order by orders_with_discount desc

--Q17 END--

--Q18 START--
SELECT 
 top 1 [Location],
    COUNT(*) AS late_orders
FROM 
[dbo].[Customer_data] c
inner join  [dbo].[Ordersdata] o on o.[CUSTOMER_KEY]=c.CUSTOMER_KEY
WHERE 
   [DELIVERY_STATUS] = 'LATE'
GROUP BY 
  [Location]
ORDER BY 
   late_orders DESC
--Q18 END--

--Q19 START--

select (sum(case when [Gender]='M' then 1 else 0 end)*100/nullif(count(*),0)) as Percent_Males,
	sum(case when Gender='M' then 1 else 0 end) as Total_Males,
	count(*) as Total_Customers
	from Customer_data
	where Acquired_Channel='APP'

--Q19 END--

--Q20 START--
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN  [ORDER_STATUS]= 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND((SUM(CASE WHEN [ORDER_STATUS] = 'cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS percentage_cancelled_orders
FROM [dbo].[Ordersdata]
--Q20 END--

--Q21 START--

SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN [Referred_Other_customers] = '1' THEN 1 ELSE 0 END) AS orders_by_happy_customers,
    ROUND((SUM(CASE WHEN [Referred_Other_customers] = '1' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS percentage_orders_by_happy_customers
FROM [dbo].[Customer_data]
	--Q21 END--

--Q22 START--
SELECT top 1 [Location],
    COUNT(*) AS refer_customers
FROM [dbo].[Customer_data]
where [Referred_Other_customers]='1'
GROUP BY 
  [Location]
ORDER BY 
    refer_customers DESC
	--Q22 END--

--Q23 START--
SELECT 
    SUM([ORDER_TOTAL]) AS total_order_value
FROM 
    [dbo].[Ordersdata] o
inner JOIN 
 [dbo].[Customer_data] c ON o.[CUSTOMER_KEY]= c.[CUSTOMER_KEY]
WHERE 
    c.[Location] = 'Chennai'
    AND c.gender = 'M'
    AND c.[Referred_Other_customers] = '1'
	--Q23 END--

--Q24 START--
SELECT 
  top 1  MONTH(o.[ORDER_DATE]) AS month,
    SUM(o.[ORDER_TOTAL]) AS total_order_value
FROM 
   [dbo].[Ordersdata] o
INNER JOIN 
   [dbo].[Customer_data]  c ON o.[CUSTOMER_KEY]= c.[CUSTOMER_KEY]
WHERE 
    c.[Location]= 'Chennai'
    AND c. [Gender]= 'M'
GROUP BY 
    MONTH(o.[ORDER_DATE])
ORDER BY 
    total_order_value DESC
--Q24 END--

--Q26 START--
--1 percentage of customers who are females acquired by APP channel?
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN [Gender] = 'F' AND  [Acquired_Channel]= 'APP' THEN 1 ELSE 0 END) AS male_customers,
    ROUND((SUM(CASE WHEN [Gender]= 'F' AND  [Acquired_Channel]= 'APP' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS percentage_male_customers
FROM [dbo].[Customer_data];


--2 How many Orders Delivered in the year of 2016
SELECT COUNT(*) AS Delivered_Orders
FROM [dbo].[ordersdata]
WHERE [ORDER_STATUS] = 'Delivered' 
AND YEAR([ORDER_DATE]) = 2016


--3-- Which location having minimum orders delivered in ON-TIME?
SELECT 
 top 1 [Location],
    COUNT(*) AS OnTime_orders
FROM 
[dbo].[Customer_data] c
inner join [dbo].[ordersdata]  o on o.[CUSTOMER_KEY]=c.CUSTOMER_KEY
WHERE 
   [DELIVERY_STATUS] = 'ON-TIME'
GROUP BY 
  [Location]
ORDER BY 
   OnTime_orders


   --4--How many customers got more than 100 discount in the year of 2016
SELECT COUNT(DISTINCT C.[CUSTOMER_ID]) AS Customer_Discount
FROM [dbo].[Customer_data] C
JOIN [dbo].[ordersdata] O ON C.[CUSTOMER_KEY] = O.[CUSTOMER_KEY]
WHERE O.Discount > 100
AND YEAR(O.[ORDER_DATE]) = 2016


--5--Which location of customers Cancelled orders maximum?
SELECT 
 top 1   [Location],
    COUNT(*) AS Cancelled_Orders
FROM 
  [dbo].[ordersdata]  o
	inner join [dbo].[Customer_data] c on c.[CUSTOMER_KEY]=o.[CUSTOMER_KEY]
WHERE 
   [ORDER_STATUS]  = 'Cancelled'
GROUP BY 
    [Location]
ORDER BY 
    Cancelled_Orders DESC

	
--Q25 START--
SELECT COUNT(*) AS discounted_orders
FROM [dbo].[Ordersdata] o
JOIN [dbo].[Customer_data] c ON o.[CUSTOMER_KEY] = c.[CUSTOMER_KEY]
WHERE c.Gender = 'F'
  AND c.[Acquired_Channel] = 'WEBSITE'
  AND c. [Location]= 'Bangalore'
  AND o. [DISCOUNT]> 0
  AND o. [DELIVERY_STATUS]= 'ON-TIME'
  --Q25 END--
