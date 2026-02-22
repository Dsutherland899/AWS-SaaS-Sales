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
 with "Monthly Sales" as (
 select date_trunc('month', "Date Key")::date as sales_month
