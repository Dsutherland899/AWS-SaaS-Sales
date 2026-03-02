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
-- Step 3: Final Calculation
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

-- YoY% Revenue/Profit Change -- 
WITH YearlySales AS (
    -- Step 1: Aggregate data by year
    SELECT 
        DATE_TRUNC('year', "Date Key")::date AS sales_year,
        SUM("Revenue") AS current_revenue,
        SUM("Profit") AS current_profit
    FROM saas_sales
    GROUP BY 1
),
YComparison AS (
    -- Step 2: Use LAG to see last month next to this month
    SELECT 
        sales_year,
        current_revenue,
        LAG(current_revenue) OVER (ORDER BY sales_year) AS prev_revenue,
        current_profit,
        LAG(current_profit) OVER (ORDER BY sales_year) AS prev_profit
    FROM YearlySales
)
-- Step 3: Final Calculation
SELECT 
    sales_year,
    current_revenue,
    ROUND(
        (((current_revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100)::numeric, 
        2
    ) AS revenue_yoy_pct,
    current_profit,
    ROUND(
        (((current_profit - prev_profit) / NULLIF(prev_profit, 0)) * 100)::numeric, 
        2
    ) AS profit_yoy_pct
FROM YComparison
ORDER BY sales_year DESC;


-- Pricing Strategy --

-- Price per Product & Cost per Product --
with PriceperProduct as (
	select "Product",
	SUM("Revenue") as "Total Revenue", 
	SUM("Quantity") as "Total Quantity", 		-- establishing totals of each business metric
	SUM("Profit") as "Total Profit", 
ROUND(
        AVG(("Revenue" / "Quantity") / (1 - "Discount"))::numeric, 	-- working out price through divding revenue by quantity and then removing disoc
        2
    ) AS "Unit Price"
from saas_sales ss 
group by "Product"
),
CostperProduct AS (
    -- This is your second "step"
    SELECT 
        ss."Product",
        ROUND(AVG(ss."Profit")::numeric, 2) AS "avg_profit",
        -- Subtracting the average profit from the average sticker price
        ROUND((p."Unit Price" - AVG(ss."Profit"))::numeric, 2) AS "Unit Cost"
    FROM saas_sales ss
    JOIN PriceperProduct p ON ss."Product" = p."Product" -- THE KEY: Linking the two
    GROUP BY ss."Product", p."Unit Price"
)
SELECT * FROM CostperProduct
ORDER BY "Unit Cost" DESC;
