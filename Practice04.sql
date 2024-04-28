--ex1
SELECT
sum(CASE
  when device_type in ('tablet','phone') then 1 else 0
end) as mobile_views,
sum(CASE
  when device_type in ('laptop') then 1 else 0
end) as laptop_views
from viewership


--ex2
select
x, y, z,
case
    when (x+y)>z and (x+z)>y and (y+z)>x then 'Yes' else 'No'
end as triangle
from Triangle

--ex3
select 
round(100.0* sum(CASE
when call_category is null or call_category ='n/a' then 1
else 0 end) /count(case_id),1) as   uncategorised_call_pct
from callers

--ex4
SELECT name 
FROM Customer
WHERE referee_id != 2 or referee_id is null

--ex5
select
survived,
sum(case when pclass = 1 then 1 else 0 end) as first_class,
sum(case when pclass = 2 then 1 else 0 end) as second_class,
sum(case when pclass = 3 then 1 else 0 end) as third_class
from titanic
group by survived
