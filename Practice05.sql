--ex1:
select 
a.continent, floor(avg(b.population))
from country as a
inner join city as b
on a.code = b.countrycode
group by a.continent

  
--ex2
select 
round(cast(count(b.email_id) as decimal)/count(a.email_id),2) as activation_rate
from emails as a
left join texts as b
on a.email_id = b.email_id
and b.signup_action = 'Confirmed'


--ex3
/*output: sending_perc = time spent sending / (Time spent sending + Time spent opening)
open_perc = Time spent opening / (Time spent sending + Time spent opening)
group by age
*/
SELECT 
b.age_bucket,
round(sum(case when a.activity_type = 'send' then a.time_spent else 0 end)
/(sum(case when a.activity_type = 'open' then a.time_spent else 0 end)
+sum(case when a.activity_type = 'send' then a.time_spent else 0 end))*100.0,2) as send_perc,

round(sum(case when a.activity_type = 'open' then a.time_spent else 0 end)/
(sum(case when a.activity_type = 'open' then a.time_spent else 0 end)
+sum(case when a.activity_type = 'send' then a.time_spent else 0 end))*100.0,2) as open_perc

FROM activities as a
left join age_breakdown as b 
on a.user_id = b.user_id


--ex4
/*output
customer_id
count unique product_category
group by customer_id
SELECT * FROM customer_contracts;
*/
select
a.customer_id
from customer_contracts as a 
left join products as b
on a.product_id = b.product_id
group by a.customer_id
having count(distinct b.product_category) = (SELECT COUNT(DISTINCT(product_category)) FROM products)


--ex5
/* output: id+name of manager, the number of their employee, the average age of the reports
rounded to the nearest integer */
select 
a.employee_id,
a.name as name,
count(b.reports_to) as reports_count,
round(avg(b.age)) as avg_age
from Employees as a
left join Employees as b
on a.employee_id = b.reports_to
group by a.employee_id
having count(b.reports_to) >=1


--ex6
select 
a.product_name,
sum(b.unit) as unit
from Products as a
inner join Orders as b
on a.product_id = b.product_id
where b.order_date between '2020-02-01' and '2020-02-29'
group by a.product_id, a.product_name
having sum(b.unit) >= 100


--ex7
SELECT 
a.page_id
FROM pages as a 
left join page_likes as b
on a.page_id = b.page_id
group by a.page_id
having count(b.user_id) = 0


--Mid-course test

--q1  
select distinct replacement_cost from film;
select min(replacement_cost) from film

--q2
select 
case 
	when replacement_cost between 9.99 and 19.99 then 'low'
	when replacement_cost between 20.00 and 24.99 then 'medium'
	when replacement_cost between 25.00 and 29.99 then 'high'
end as category,
count(film_id) as quantity 
from film
group by category

--q3
select
a.title, a.length, c.name
from film as a
join film_category as b on a.film_id = b.film_id
join category as c on b.category_id = c.category_id
where c.name = 'Drama' or c.name = 'Sports'
order by a.length desc

--q4
select
count(a.film_id) as count, c.name as category
from film as a
join film_category as b on a.film_id = b.film_id
join category as c on b.category_id = c.category_id
group by c.category_id
order by count(a.film_id) desc

--q5
select 
a.first_name, a.last_name, 
count(b.film_id)
from actor as a
join film_actor as b on a.actor_id = b.actor_id
group by a.first_name, a.last_name
order by count(b.film_id) desc

--q6
select 
count(a.address_id)
from address as a
left join customer as b on a.address_id = b.address_id
where b.customer_id is null

--q7
select
a.city,
sum(d.amount)
from city as a
join address as b on a.city_id = b.city_id
join customer as c on b.address_id = c.address_id
join payment as d on c.customer_id = d.customer_id
group by a.city
order by sum(d.amount) desc

--q8
select 
(a.city || ',' || ' ' || b.country) as city_country,
sum(e.amount) as revenue
from city as a
join country as b on a.country_id = b.country_id
join address as c on a.city_id = c.city_id
join customer as d on c.address_id = d.address_id
join payment as e on d.customer_id = e.customer_id
group by (a.city || ',' || ' ' || b.country)
order by sum(e.amount)






