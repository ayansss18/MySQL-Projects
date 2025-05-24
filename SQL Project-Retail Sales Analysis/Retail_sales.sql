create database personal_project;
use personal_project;

create table retail_sales
						(
						transactions_id	INT,
						sale_date DATE,	
						sale_time TIME,
						customer_id	INT,
                        gender VARCHAR(10),
						age	INT,
						category VARCHAR(15),	
						quantiy	INT,
						price_per_unit	INT,
						cogs INT,	
						total_sale INT
						);
                        
alter table retail_sales rename column quantiy to quantity;
SELECT * FROM retail_sales LIMIT 70;

SELECT * FROM retail_sales where transactions_id=679;

select count(*) from retail_sales;

show columns from retail_sales;

-- DELETING THE NULL COLUMNS
DELETE FROM retail_sales where
transactions_id is NULL or
sale_date is NULL or
sale_time is null or
customer_id is null or
gender is null or
category is null or
quantity is null or
price_per_unit is null or
cogs is null or
total_sale is null;

-- Unique customers and categories we have
select count(distinct customer_id) as Total_Customers from retail_sales;

select distinct category as Total_Customers from retail_sales;

-- Main Business Problems --

-- Q1. write a sql query to retrieve all columns for sales made on 2022-11-05
-- Q2. write a sql query to show all transaction where the category is clothing and the quantity sold is more than 10 in month nov 1022
select * from retail_sales limit 10;

select * from retail_sales
where category="Clothing"
and quantity>2
and date_format(sale_date,'%Y-%m')= '2022-11';

-- Q3. Total sales group by category

select category, sum(total_sale) as Total_Sales from retail_sales
group by category
order by Total_Sales desc;

-- Q4. Sql query to find average age of customers from beauty category
select * from retail_sales;

select category, avg(age) as Average_Age
from retail_sales
group by category
having category='Beauty'; 

-- Q5. Calculate average sell of each month, find out the best selling month in each year
select * from retail_sales;

select year,max(Average) from(
select year(sale_date) as year, month(sale_date) as month, avg(total_sale) as Average
from retail_sales
group by 1,2
order by 1,2) as total
group by year;

-- Q.6 Calculate shift wise total sales

select * from retail_sales;

with total_shifts as
(
select *,
	case
		when hour(sale_time)<12 then 'Morning'
        when hour(sale_time) between 12 and 17 then 'Afternoon'
        else 'Evening'
	end as Shift
from retail_sales)
 select Shift , count(*) as Total_sale
 from total_shifts
 group by shift;

