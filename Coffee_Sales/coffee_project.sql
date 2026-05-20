use project;

create table customers (customer_id int, customer_name varchar(30), city_id int);
create table products (product_id int, product_name varchar(100), price int);
create table sales (sale_id int, sale_date date, product_id int, customer_id int, total int, rating int);
create table city (city_id int, city_name varchar(20), population int, estimated_rent int, city_rank int);

show tables;

load data infile 'A:/1. Data Analyst_Science Prep 2026/MYSQL/Coffee Project/customers.csv'
into table customers
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'A:/1. Data Analyst_Science Prep 2026/MYSQL/Coffee Project/sales.csv'
into table sales
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'A:/1. Data Analyst_Science Prep 2026/MYSQL/Coffee Project/city.csv'
into table city
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'A:/1. Data Analyst_Science Prep 2026/MYSQL/Coffee Project/products.csv'
into table products
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Add constraints
alter table city add constraint primary key pm_key (city_id);
alter table customers add constraint primary key pm_key_cust (customer_id);
alter table products add constraint primary key pm_key_prod (product_id);
alter table sales add constraint primary key pm_key_sale (sale_id);

alter table customers add constraint foreign key fk_city (city_id) references city(city_id);
alter table sales add constraint foreign key fk_prod (product_id) references products(product_id);
alter table sales add constraint foreign key fk_cust (customer_id) references customers(customer_id);

-- Reports and Data Analysis
-- Q1.  Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select 
	city_name, 
    round((population*0.25)/1000000,2) as consumer, 
    city_rank, rank() over(order by population desc) as top_5
from city order by 4 limit 5; 


-- Q2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across top 5 cities in the last quarter of 2023?

with max_qtr as (
	select max(quarter(sale_date) ) as max_q from sales 
    where year(sale_date)=2023
)
select city.city_name, sum(sales.total) as Revenue
from sales
join customers on sales.customer_id = customers.customer_id
join city on customers.city_id = city.city_id
where year(sale_date)=2023 and quarter(sale_date)= (select max_q from max_qtr)
group by city.city_name
order by 2 desc limit 5;

-- Q3. Sales Count for Each Product
-- How many units of each coffee product have been sold?

select products.product_name, count(sales.sale_id) as times_sold
from products 
join sales on products.product_id = sales.product_id
group by products.product_name
order by 2 desc;

-- Q4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select city.city_name,
	count(distinct customers.customer_id) as total_customers,
	round(sum(sales.total),0) as total_sales,
   round(sum(sales.total)/count(distinct customers.customer_id),0) as avg_sales
from city 
join customers on  city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
group by city.city_name
order by 4 desc;

-- Q5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

select 
	city.city_name, 
	round((city.population * 0.25)/1000000,2) as coffee_con,
    count(distinct sales.customer_id) as reg_con
from city 
join customers on  city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
group by city.city_name, city.population
order by 2 desc;


-- Q6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

with top_products as(
select city.city_name, products.product_name, count(sales.product_id) as total_sold,
row_number() over(partition by city_name order by count(sales.product_id) desc) as ranking
from city
join customers on city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
join products on products.product_id = sales.product_id
group by city_name, product_name)

select * from top_products where ranking in(1,2,3);

-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select city.city_name, count(distinct (sales.customer_id)) as total_cust from city
join customers on city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
join products on products.product_id = sales.product_id
where sales.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by city_name
order by total_cust desc;

-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

select city.city_name, count(distinct sales.customer_id) as total_cust, city.estimated_rent,
round((city.estimated_rent/count(distinct sales.customer_id)),0) as average_rent,
round((sum(sales.total)/count(distinct sales.customer_id)),0) as average_sale
from city
join customers on city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
join products on products.product_id = sales.product_id
group by city_name, estimated_rent;

-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

with sale_pct as(
select city.city_name, month(sales.sale_date) as Months, year(sales.sale_date) as years, sum(sales.total) as total_sale
from sales
join customers on customers.customer_id = sales.customer_id
join city on city.city_id = customers.city_id
group by city_name, Months, years),

new_prev_sale
as
(select * , lag(total_sale,1) over(partition by city_name order by years, months) as prev_sale
from sale_pct)

select *, ((coalesce(total_sale,0)-coalesce(prev_sale,0))/coalesce(prev_sale,0))*100 as pct_gth from new_prev_sale
;

-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

select city.city_name, sum(sales.total) as total_revenue, city.estimated_rent, count(distinct customers.customer_id) as total_cust,
round((city.population*0.25)/1000000,0) as coffee_consumer_million,
round((city.estimated_rent/count(distinct sales.customer_id)),0) as average_rent,
round((sum(sales.total)/count(distinct sales.customer_id)),0) as average_sale
from city
join customers on city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
join products on products.product_id = sales.product_id
group by 1,3,5
order by total_revenue desc;
