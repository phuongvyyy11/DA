--ad-hoc tasks
--q1
with cte as (
select 
format_date('%Y-%m',delivered_at) as month_year,
count(order_id) as total_orders,
count(distinct user_id) as total_users,
status as order_status
from bigquery-public-data.thelook_ecommerce.orders
group by format_date('%Y-%m',delivered_at), status
)
select 
month_year,total_orders,total_users
from cte 
where month_year >= '2019-1' and month_year <= '2022-4' and order_status = 'Complete'
order by month_year desc;
--số lượng user và đơn hàng tăng dần theo thời gian

--q2
with tb as (
select 
format_date('%Y-%m',a.delivered_at) as month_year,
count(distinct a.user_id) as distinct_users,
sum(b.sale_price)/count(a.order_id) as avg_order_value,
a.status as order_status
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.order_items as b 
on a.order_id = b.order_id
group by format_date('%Y-%m',a.delivered_at), a.status
)
select
month_year,
distinct_users,
avg_order_value
from tb
where month_year >= '2019-1' and month_year <= '2022-4' and order_status = 'Complete' 
order by month_year desc
--số lượng user tăng dần theo thời gian, trong khi giá trị đơn hàng trung bình k tăng theo, giao động trong khoảng $48-$67

--q3
/*tìm min(age), max(age) cho mỗi giới tính + trong thời gian yêu cầu 
  ->tìm các user trong bảng có độ tuổi thuộc min(age), max(age)
  -> gắn tag bằng pivot table
*/

with f_age as (
select
min(age) as f_min_age,
max(age) as f_max_age
from bigquery-public-data.thelook_ecommerce.users
where gender = 'F' and created_at between '2019-01-01' and '2022-05-01')
,
m_age as (
select
min(age) as m_min_age,
max(age) as m_max_age
from bigquery-public-data.thelook_ecommerce.users
where gender = 'M' and created_at between '2019-01-01' and '2022-05-01')
,
age_group as (
select a.first_name, a.last_name, a.gender, a.age 
from bigquery-public-data.thelook_ecommerce.users as a
join f_age as b on a.age = b.f_min_age or a.age = b.f_max_age
where a.gender = 'F' and a.created_at between '2019-01-01' and '2022-05-01'
UNION ALL
select c.first_name, c.last_name, c.gender, c.age 
from bigquery-public-data.thelook_ecommerce.users as c
join m_age as d on c.age = d.m_min_age or c.age = d.m_max_age
where c.gender = 'M' and c.created_at between '2019-01-01' and '2022-05-01'
),
age_tag as (
select *,
case 
when age in (select min(age) as min_age from bigquery-public-data.thelook_ecommerce.users
where gender = 'F' or gender = 'M') then 'youngest'
else 'oldest' end as tag
from age_group
)
select 
gender, tag, count(*) as user_count
from age_tag
group by gender, tag

/* cả 2 giới tính đều có độ tuổi lớn nhất là 70, độ tuổi nhỏ nhất là 12
trong đó:
- giói tính nữ: 571 người dùng lớn tuổi nhất, 487 người dùng trẻ tuổi nhất
- giói tính nam: 504 người dùng lớn tuổi nhất, 491 người dùng trẻ tuổi nhất
*/

--q4
with cte as (
select
format_date('%Y-%m',a.delivered_at) as month_year,
a.product_id, b.name as product_name,
sum(a.sale_price) as sales,
sum(b.cost) as cost,
sum(a.sale_price) -sum(b.cost) as profit
from bigquery-public-data.thelook_ecommerce.order_items as a
join bigquery-public-data.thelook_ecommerce.products as b on a.product_id = b.id
where a.status = 'Complete'
group by format_date('%Y-%m',a.delivered_at), a.product_id,  b.name
),
rank_product_cte as (
select * ,
dense_rank() over (partition by month_year order by month_year, profit desc) as rank
from cte)
select * from rank_product_cte
where rank <=5
order by month_year

--q5
select 
format_date('%Y-%m-%d',a.delivered_at) as dates,
b.product_category as product_categories,
sum(a.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as a
join bigquery-public-data.thelook_ecommerce.inventory_items as b on a.product_id = b.product_id
where a.status='Complete' and a.delivered_at between '2022-01-15 00:00:00' and '2022-04-16 00:00:00'
group by format_date('%Y-%m-%d',a.delivered_at), b.product_category
order by dates
