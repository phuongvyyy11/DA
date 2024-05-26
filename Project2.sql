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


--III
--dataset
create or replace view vw_ecommerce_analyst as
(
with cte as 
(
select
format_date('%Y-%m', a.created_at) as month,
format_date('%Y', a.created_at) as year,
b.category as product_category,
sum(c.sale_price) as TPV,
sum(c.order_id) as TPO,
sum(b.cost) as total_cost,
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.products as b on a.order_id = b.id
join bigquery-public-data.thelook_ecommerce.order_items as c on b.id = c.order_id
group by month, year, product_category
)
select month, year, product_category, TPV, TPO,
round(100.00*(TPV-(lag(TPV) over (partition by product_category order by year, month)))/(lag(TPV) over (partition by product_category order by year, month)),2) || '%' as revenue_growth,
round(100.00*(TPO-(lag(TPO) over (partition by product_category order by year, month)))/(lag(TPO) over (partition by product_category order by year, month)),2) || '%' as order_growth,
total_cost,
TPV-total_cost as total_profit,
(TPV-total_cost)/total_cost as profit_to_cost_ratio
from cte
order by month, year, product_category
)

--cohort index
With cte1 as (
select 
user_id, 
sale_price as amount,
min(created_at) over (partition by user_id) as first_purchase_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items
),
cte2 as (select 
user_id, amount,
format_date('%Y-%m', first_purchase_date) as cohort_month,
(extract(year from created_at)-extract(year from first_purchase_date))*12 + (extract(month from created_at)-extract(month from first_purchase_date))+1 as index
from cte1),
cohort_data as (
select 
count(distinct user_id) as user_count,
sum(amount) as revenue,
cohort_month,
index
from cte2
group by cohort_month, index
order by index),

--customer cohort
user_cohort as (
select 
cohort_month,
sum(case when index = 1 then user_count else 0 end) as m1,
sum(case when index = 2 then user_count else 0 end) as m2,
sum(case when index = 3 then user_count else 0 end) as m3,
sum(case when index = 4 then user_count else 0 end) as m4
from cohort_data
group by cohort_month
order by cohort_month
),
  
--retention cohort
retention_cohort as
(select 
cohort_month,
(m1/m1)*100.00 || '%' as m1,
round((m2/m1)*100.00,2) || '%' as m2,
round((m3/m1)*100.00,2) || '%' as m3,
round((m4/m1)*100.00,2) || '%' as m4
from user_cohort
)
  
--churn rate
select 
cohort_month,
(100 - round((m1/m1)*100.00,2)) || '%' as m1,
(100 - round((m2/m1)*100.00,2)) || '%' as m2,
(100 - round((m3/m1)*100.00,2)) || '%' as m3,
(100 - round((m4/m1)*100.00,2)) || '%' as m4
from user_cohort




