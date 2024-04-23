--ex1
SELECT NAME FROM CITY
WHERE  COUNTRYCODE = 'USA' AND POPULATION > 120000

--ex2
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN'

--ex3
SELECT CITY, STATE FROM STATION

--ex4
SELECT DISTINCT CITY FROM STATION 
WHERE CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%' 

--ex5
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE '%a' OR CITY LIKE '%e' OR CITY LIKE '%i' OR CITY LIKE '%o' OR CITY LIKE '%u'

--ex6
SELECT DISTINCT CITY FROM STATION 
WHERE NOT (CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%' )

--ex7
SELECT name FROM Employee
ORDER BY name 

--ex8
SELECT name FROM Employee
WHERE salary > 2000 AND months < 10
ORDER BY employee_id ASC;

--ex9
SELECT product_id FROM Products
WHERE low_fats = 'Y' AND recyclable = 'Y'

--ex10
SELECT name FROM Customer
WHERE referee_id != 2 OR referee_id IS NULL

--ex11
SELECT name, population, area FROM World
WHERE area >= 3000000 OR population >= 25000000

--ex12
SELECT DISTINCT author_id AS id FROM Views
WHERE author_id = viewer_id
ORDER BY author_id ASC;

--ex13
SELECT part, assembly_step FROM parts_assembly
WHERE assembly_step >= 1 AND finish_date IS NULL

--ex14
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary >= 30000;

--ex15
select advertising_channel from uber_advertising
where year = 2019 and money_spent > 100000

