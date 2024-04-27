--ex1
select name 
from STUDENTS
where Marks > 75
order by right(Name, 3), ID

--ex2
select 
user_id,
concat(upper(left(lower(name),1)), lower(right(name,length(name)-1))) as name
from Users 

--ex3
select
manufacturer,
'$' || round((sum(total_sales))/1000000) || ' ' || 'million' as sale
from pharmacy_sales
group by manufacturer
order by sum(total_sales) DESC, manufacturer

--ex4
select
  extract(month from submit_date) as month,
  product_id,
  round(cast(avg(stars) as decimal),2) as avg_stars
from reviews
group by month, product_id
order by month, product_id

--ex5
/* 
output:
- the IDs of these 2 users
-  the total number of messages 
filter: highest number of messages, aug 2022
order: desc the count of messages
*/
select 
sender_id,
count(message_id) as message_count
from messages
where 
  extract(month from sent_date) = '8'
  and extract(year from sent_date) = '2022'
group by sender_id
order by count(message_id) DESC
limit 2

--ex6
/* output: id
filter: invalid tweets: total characters > 15
*/
select tweet_id
from Tweets
where length(content) > 15

--ex7
/*
output: daily active user count
filter: 30 days  ending 2019-07-27 inclusively
active: made as least 1 activity on the day
*/
select
activity_date as day,
count(distinct user_id) as active_users
from Activity
where
    activity_date between '2019-06-28' and '2019-07-27'
group by activity_date

--ex8
select
count(id)  as number_of_employee_hired
from employees
where extract (month from joining_date) between 1 and 7
and extract(year from joining_date) = 2022

--ex9
/* output: position of 'a'
filter: first name = 'Amitah'
*/
select 
position('a' in first_name) as position
from worker
where first_name = 'Amitah'

--ex10
/* output: year, title
year = 
filter: country = Macedonia
*/
select 
title,
cast (substring(title from length(winery)+2 for 4) as int)
from winemag_p2
where country = 'Macedonia'
