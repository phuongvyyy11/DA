--ex1
SELECT DISTINCT CITY FROM STATION
WHERE ID%2 = 0

--ex2
SELECT (COUNT(CITY) - COUNT(DISTINCT CITY)) AS DIFFERENCE
FROM STATION

--ex3
select 
round(cast(sum(item_count*order_occurrences) / sum (order_occurrences) as decimal),1)
from items_per_order

--ex4
SELECT candidate_id 
from candidates
where skill in ('Python','Tableau', 'PostgreSQL' )
group by candidate_id
order by candidate_id

--ex5
SELECT candidate_id 
from candidates
where skill in ('Python','Tableau', 'PostgreSQL' )
group by candidate_id
having count(skill) = 3
order by candidate_id

--ex6
select user_id, 
max(post_date :: date) - min(post_date :: date) as days
from posts
where post_date between '01-01-2021 00:00:00' and '01-01-2022 00:00:00'
group by user_id
having count(post_id) > 1

--ex7
select card_name,
max(issued_amount) - min(issued_amount) as difference
from monthly_cards_issued
group by card_name
order by max(issued_amount) - min(issued_amount) DESC

--ex8
select 
  manufacturer,
  count(drug) as drug_count,
  abs(sum(total_sales - cogs)) as total_loss
from pharmacy_sales
where total_sales - cogs < 0
group by manufacturer
order by total_loss DESC

--ex9
select *
from Cinema
where id%2 = 1 and description not like 'boring'
order by rating DESC

--ex10
select
    teacher_id,
    count(distinct subject_id) as count_subject
from Teacher
group by teacher_id

--ex11
select 
    user_id,
    count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

--ex12
select 
    class
from Courses
group by class
having count(student) >= 5


