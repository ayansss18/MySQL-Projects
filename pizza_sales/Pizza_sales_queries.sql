create database pizzahut;
use pizzahut;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

select * from order_details;

-- Q1. Retrieve the total number of orders placed.
select count(order_id) as "Total order placed" from orders;

-- Q2. Calculate the total revenue generated from pizza sales.
select 
round(sum(order_details.quantity *pizzas.price),2) as "Total revenue"
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id;

-- Q3. Identify the highest-priced pizza.
select 
pizza_types.name,pizzas.price
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
order by price desc limit 1;

-- OR
select 
pizza_types.name,pizzas.price
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
where pizzas.price=(select max(pizzas.price) from pizzas);

-- Q4.Identify the most common pizza size ordered.
select quantity,count(quantity)
from order_details group by quantity;

select pizzas.size, count(order_details.order_details_id) as Common_size
from pizzas join order_details on
pizzas.pizza_id=order_details.pizza_id
group by pizzas.size 
order by common_size desc limit 1;

-- Q5 List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(order_details.quantity) as Quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on
order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by Quantity desc limit 5
;

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
select category, count(category)
from pizza_types group by category;

select pizza_types.category, sum(order_details.quantity) as Total_Order
from order_details join pizzas on
order_details.pizza_id=pizzas.pizza_id
join pizza_types on
pizzas.pizza_type_id=pizza_types.pizza_type_id
group by category;

-- Determine the distribution of orders by hour of the day.
select hour(order_time)as total_time, count(order_id) from orders
group by total_time;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(total) from
(select order_date, sum(quantity) as total from orders
join order_details on orders.order_id=order_details.order_id
group by order_date) as total_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(order_details.quantity*pizzas.price) as Total
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on
order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by Total desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
(sum(order_details.quantity*pizzas.price)/(select sum(order_details.quantity*pizzas.price)
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on
order_details.pizza_id=pizzas.pizza_id))*100 as contribution
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on
order_details.pizza_id=pizzas.pizza_id
group by category;

-- select sum(order_details.quantity*pizzas.price)
-- from pizza_types join pizzas on
-- pizza_types.pizza_type_id=pizzas.pizza_type_id
-- join order_details on
-- order_details.pizza_id=pizzas.pizza_id; -- for total, apply it to above

-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from order_details join orders on
order_details.order_id=orders.order_id
join pizzas on
order_details.pizza_id=pizzas.pizza_id
group by orders.order_date) as total_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select * from
(select category,name,revenue,rank() 
over(partition by category order by revenue desc) as ranking
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity*pizzas.price)as revenue from
order_details join pizzas on
order_details.pizza_id=pizzas.pizza_id
join pizza_types on
pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category,pizza_types.name) as total) as by_rank
where ranking =1 order by ranking limit 3;