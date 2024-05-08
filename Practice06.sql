--ex1
with job_count_table as 
(
select company_id, title, description,
count(job_id) as job_count
from job_listings
group by company_id, title, description)

select count(distinct company_id) as duplicate_job from  job_count_table
where job_count > 1

--ex2
/*
output:top 2 in 2022
- category, product (available)
- total spend not availabl = sum(spend)
*/
with spend_tb as (
select category, product,
sum(spend) as total_spend,
RANK() over (PARTITION BY category ORDER BY SUM(spend) DESC) AS product_ranking
from product_spend
where extract(year from transaction_date) = 2022
group by category, product)

select category, product, total_spend
from spend_tb
where product_ranking <=2
order by category, product_ranking

--ex3
/*
output: how many UHG policy holders
filter: made three, or more calls
1. number of total calls of each user
2. filter 
SELECT * FROM callers;
*/
with calls_tb as 
(select 
policy_holder_id,
count(case_id)  as calls
from callers
group by policy_holder_id)
select count(policy_holder_id) as count
from calls_tb
where calls >=3

--ex4
SELECT 
a.page_id
FROM pages as a 
left join page_likes as b
on a.page_id = b.page_id
group by a.page_id
having count(b.user_id) = 0


--ex5
/*output: total mau: not available
filter month in 7
count(active user) not available
active user = user in the current month + previous month
*/

with jun_active_users as (SELECT
event_date,
user_id 
from user_actions
where extract(month from event_date) = 6),

jul_active_user as (SELECT
event_date,
user_id 
from user_actions
where extract(month from event_date) = 7),

total_active_user as (select distinct a.user_id
from jun_active_users as a   
join jul_active_user as b on a.user_id = b.user_id)

select 
7 as month,
count(user_id)
from total_active_user


--ex6
select 
substr(trans_date, 1, 7) AS month,
country,
count(id) as trans_count,
sum(case when state = 'approved' then 1 else 0 end) as approved_count,
sum(amount) as trans_total_amount,
sum(case when state = 'approved' then amount else 0 end) as approved_total_amount
from Transactions
group by month, country

--ex7
with products_in_1st_year_tb as (
select
product_id, min(year) as first_year
from Sales
group by product_id)

select a.product_id, a.first_year, b.quantity, b.price
from products_in_1st_year_tb as a
left join Sales as b on a.product_id = b.product_id

--ex8
select
customer_id
from Customer
group by customer_id
having count(product_key) = (select count(product_key) from Product)

--ex9
select employee_id
from Employees
where salary < 30000 
and manager_id not in 
(select employee_id from Employees )
order by employee_id

--ex10 is a duplicate of ex1?
with job_count_table as 
(
select company_id, title, description,
count(job_id) as job_count
from job_listings
group by company_id, title, description)

select count(distinct company_id) as duplicate_job from  job_count_table
where job_count > 1

--ex11
/*output:  the name of the user, filter by who has rated the greatest number of movies
the movie name, filter by the highest average rating, in feb 2020*/

(select 
b.name as results
from MovieRating as a
left join Users as b on a.user_id = b.user_id
group by b.name
order by count(a.movie_id) desc
limit 1)
union
(select
d.title as results
from MovieRating as c
left join Movies as d on c.movie_id = d.movie_id
where extract(year_month from created_at) = 202002
group by d.title
order by avg(c.rating) DESC, d.title
limit 1)

--ex12
with tb as
( 
select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted
 )

select id, count(id) as num
from tb
group by id
order by num desc
limit 1

