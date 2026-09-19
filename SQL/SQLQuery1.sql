select * from train;
------------------------------------------------------------------------------------------
-- order store type from high value to less-----------------------------------------------
------------------------------------------------------------------------------------------
select
	StoreType, avg(Cast(Sales as bigint)) avg_sales, 
	avg(Customers) Avg_customers,count (distinct Store) as totalBranshes ,
	    AVG(CAST(Sales AS FLOAT)) / NULLIF(AVG(CAST(Customers AS FLOAT)), 0) AS sales_per_customer
from train
WHERE [Open] = 1
group by StoreType
order by avg_sales desc , Avg_customers desc;
--------------------------------------------------------------------------------------------------
--Best Store type each month ---------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
with CTE as(
select 
	YEAR,MONTH,
	StoreType ,avg(Sales)as [avg Sales],
	Avg(Customers)as [avg customers] 
from train
where [Open] = 1
group by year,month,StoreType
), ranking as(
select *,DENSE_RANK()over(partition by year, month order by [avg Sales] desc ,[avg customers] desc  ) as RK
from CTE 
)
select * from Ranking
where RK=1;
--------------------------------------------------------------------------------------------------
--Worst Store type each month --------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
with CTE as(
select YEAR,MONTH,
    StoreType ,avg(Sales)as [avg Sales],
    Avg(Customers)as [avg customers]
from train
where [Open] = 1
group by year,month,StoreType
), ranking as(
select *,DENSE_RANK()over(partition by year, month order by [avg Sales] desc ,[avg customers] desc  ) as RK
from CTE 
)
select * from Ranking
where RK=4;
---------------------------------------------------------------------------------------------------------------
--Time worst Counter for each Store type ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
WITH CTE AS (
    SELECT 
        [Year],
        [Month],
        StoreType,
        AVG(CAST(Sales AS FLOAT)) AS [avg Sales]
    FROM train
    WHERE [Open] = 1
    GROUP BY [Year], [Month], StoreType
),
Ranking AS (
    SELECT 
        *,
        DENSE_RANK() OVER (
            PARTITION BY [Year], [Month]
            ORDER BY [avg Sales] DESC
        ) AS RK
    FROM CTE
)
SELECT 
    StoreType,
    COUNT(*)         AS [Times_Worst],
    MIN([avg Sales]) AS [Min_Avg_Sales],
    AVG([avg Sales]) AS [Overall_Avg_Sales],
    MAX([avg Sales]) AS [Max_Avg_Sales]
FROM Ranking
WHERE RK = 4
GROUP BY StoreType
ORDER BY [Times_Worst] DESC;
------------------------------------------------------------------------------------------------------------
-- Promotion effection -------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
select IsPromoMonth, AVG(cast(Sales as bigint)) as[ Averege Sales],
AVG(Customers) as [ Averege Customers]
from train
group by IsPromoMonth;
----------------------------------------------------------------------------------------------
-- top 20 Store by AVG (Sales & Customers)----------------------------------------------------
----------------------------------------------------------------------------------------------
WITH StoreStats AS (
    SELECT 
        Store,
        AVG(CAST(Sales AS FLOAT)) AS avg_sales,
        AVG(CAST(Customers AS FLOAT)) AS avg_customers,
        COUNT(*) AS days_open
    FROM train
    WHERE [Open] = 1
    GROUP BY Store
),storetype as(
select Distinct store,StoreType from train
)
SELECT TOP 20 a.Store,b.StoreType,a.avg_sales,
    a.avg_customers,a.days_open
FROM StoreStats a join storetype b on a.Store=b.Store
ORDER BY avg_sales DESC;
------------------------------------------------------------------------------------------
-- Bottom 20 Store by AVG (Sales & Customers)---------------------------------------------
------------------------------------------------------------------------------------------
 WITH StoreStats AS (
    SELECT 
        Store,
        AVG(CAST(Sales AS FLOAT)) AS avg_sales,
        AVG(CAST(Customers AS FLOAT)) AS avg_customers,
        COUNT(*) AS days_open
    FROM train
    WHERE [Open] = 1
    GROUP BY Store
),storetype as(
select Distinct store,StoreType from train
)
SELECT TOP 20 a.Store,b.StoreType,a.avg_sales,
    a.avg_customers,a.days_open
FROM StoreStats a join storetype b on a.Store=b.Store
ORDER BY avg_sales Asc;
-------------------------------------------------------------------------------------------
-- Conreibution Pct -----------------------------------------------------------------------
-------------------------------------------------------------------------------------------
WITH TypeStats AS (
    SELECT 
        StoreType,
        SUM(CAST(Sales AS BIGINT)) AS total_sales
    FROM train
    WHERE [Open] = 1
    GROUP BY StoreType
),
Total AS (
    SELECT SUM(total_sales) AS grand_total FROM TypeStats
)
SELECT 
    t.StoreType,
    t.total_sales,
    t.total_sales * 100.0 / tt.grand_total AS contribution_pct
FROM TypeStats t
CROSS JOIN Total tt
ORDER BY contribution_pct DESC;
-----------------------------------------------------------------------------------------------
------Holidays Effections ---------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
SELECT 
    StateHoliday,
    SchoolHoliday,
   Round( AVG(CAST(Sales AS FLOAT)),2) AS avg_sales,
   ROUND( AVG(CAST(Customers AS FLOAT)),2) AS avg_customers,
    COUNT(*) AS num_days
FROM train
WHERE [Open] = 1
GROUP BY StateHoliday, SchoolHoliday
ORDER BY avg_sales desc ;
----------------------------------------------------------------------------------------------
-- Trend analysis ----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
WITH MonthlySales AS (
    SELECT 
        [Year], [Month],
        Round(AVG(CAST(Sales AS FLOAT)),2) AS avg_sales,
        Round(SUM(CAST(Sales AS BIGINT)),2) AS total_sales,
       Round( AVG(CAST(Customers AS FLOAT)),2) AS avg_customers
    FROM train
    WHERE [Open] = 1
    GROUP BY [Year], [Month]
)
SELECT 
    [Year], [Month],
    avg_sales,
  ROUND(  LAG(avg_sales) OVER (ORDER BY [Year], [Month]),2) AS prev_month_sales,
  Round(  avg_sales - LAG(avg_sales) OVER (ORDER BY [Year], [Month]),2) AS mom_change,
  Round(((avg_sales - LAG(avg_sales) OVER (ORDER BY [Year], [Month])) 
        / NULLIF(LAG(avg_sales) OVER (ORDER BY [Year], [Month]), 0)) * 100,4) AS mom_pct
FROM MonthlySales
ORDER BY [Year], [Month];