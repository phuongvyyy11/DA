--q1
SELECT
productline, 
year_id,
dealsize, 
sum(sales) as revenue
FROM SALES_DATASET_RFM_PRJ_CLEAN
group by productline, 
year_id,
dealsize

--q2
select 
month_id,
ordernumber,
sum(sales) as revenue
from sales_dataset_rfm_prj_clean
group by month_id, ordernumber 
order by revenue desc

--q3
select 
month_id,
ordernumber,
productline,
sum(sales) as revenue
from sales_dataset_rfm_prj_clean
where month_id = 11
group by 
productline, month_id, ordernumber
order by revenue desc

--q4
with cte as(
select 
year_id,
productline, 
sum(sales) as revenue,
dense_rank() over (partition by year_id order by sum(sales) desc) as rank
from sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, productline
	)	
select *
from cte
where rank = 1

--q5
with rfm as(
select 
contactfullname,
current_date - max(orderdate) as R,
count(ordernumber) as F,
sum(sales) as M
from sales_dataset_rfm_prj_clean
group by contactfullname
	),
rfm_score as (
select	
contactfullname,
ntile(5) over(order by R desc) as r_score,
ntile(5) over(order by F) as f_score,
ntile(5) over(order by M) as m_score
from rfm
	)
select a.*,
b.segment
from (select 
contactfullname,
cast(r_score as varchar) || cast(f_score as varchar) || cast(m_score as varchar) as final_score
from rfm_score) as a 
JOIN segment_score AS b ON a.final_score=b.scores
