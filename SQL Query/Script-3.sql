-- Data Exploration --
select * from saas_sales ss;

-- Renaming Sales column to Revenue -- 
select * from saas_sales ss;
alter table saas_sales 
rename "Sales" to "Revenue";

-- Checking for items which haven't sold --
select "Quantity"  from saas_sales ss 
where "Quantity" =  0

-- Total Revenue --
select SUM("Revenue")as "Total Revenue"
from saas_sales ss;

-- Total Revenue & Profit by Segement -- 
select SUM("Revenue") as "Total Revenue",
SUM("Profit") as "Total Profit",
"Segment"
from saas_sales ss
group by "Segment"
order by "Total Revenue" desc;

-- MoM % Revenue/Profit Change -- 
WITH MonthlySales AS (
    -- Step 1: Aggregate data by month
    SELECT 
        DATE_TRUNC('month', "Date Key")::date AS sales_month,
        SUM("Revenue") AS current_revenue,
        SUM("Profit") AS current_profit
    FROM saas_sales
    GROUP BY 1
),
Comparison AS (
    -- Step 2: Use LAG to see last month next to this month
    SELECT 
        sales_month,
        current_revenue,
        LAG(current_revenue) OVER (ORDER BY sales_month) AS prev_revenue,
        current_profit,
        LAG(current_profit) OVER (ORDER BY sales_month) AS prev_profit
    FROM MonthlySales
)
-- Step 3: Final Calculation with Type Casting
SELECT 
    sales_month,
    current_revenue,
    ROUND(
        (((current_revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100)::numeric, 
        2
    ) AS revenue_mom_pct,
    current_profit,
    ROUND(
        (((current_profit - prev_profit) / NULLIF(prev_profit, 0)) * 100)::numeric, 
        2
    ) AS profit_mom_pct
FROM Comparison
ORDER BY sales_month DESC;
